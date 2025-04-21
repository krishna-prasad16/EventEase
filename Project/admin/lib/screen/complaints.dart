import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Complaints extends StatefulWidget {
  const Complaints({super.key});

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  List<Map<String, dynamic>> complaints = [];

  Future<void> fetchComplaints() async {
    try {
      final response = await supabase.from('tbl_complaint').select(
          "*,tbl_user(user_name),tbl_decorators(dec_name),tbl_catering(cat_name)");
      List<Map<String, dynamic>> data = [];
      for (var item in response) {
        // Count how many of the IDs are not null
        int idCount = 0;
        if (item['user_id'] != null) idCount++;
        if (item['catering_id'] != null) idCount++;
        if (item['decorator_id'] != null) idCount++;

        // Only include if exactly one is set
        if (idCount == 1) {
          data.add({
            'id': item['id'],
            'name': (item['tbl_user']?['user_name']) ??
                (item['tbl_catering']?['cat_name']) ??
                (item['tbl_decorators']?['dec_name']) ??
                'Unknown',
            'title': item['complaint_title'],
            'description': item['complaint_content'],
            'status': item['complaint_status'],
            'reply': item['complaint_reply'] ?? "",
            'date': item['created_at'],
          });
        }
      }
      setState(() {
        complaints = data;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
    }
  }

  Future<void> submitReply(int complaintId, String reply) async {
    try {
      await supabase.from('tbl_complaint').update({
        'complaint_reply': reply,
        'complaint_status': 1,
      }).eq('id', complaintId);
      await fetchComplaints(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting reply: $e')),
      );
    }
  }

  void showReplyDialog(BuildContext context, int complaintId) {
    final TextEditingController replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reply'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(hintText: 'Enter your reply'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (replyController.text.isNotEmpty) {
                submitReply(complaintId, replyController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return complaints.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                // Format the date
                String formattedDate = '';
                try {
                  final dateTime = DateTime.parse(complaint['date']);
                  formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
                } catch (e) {
                  formattedDate = complaint['date'].toString();
                }
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      complaint['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${complaint['name']}'),
                        Text('Description: ${complaint['description']}'),
                        Text('Date: $formattedDate'),
                        Text('Status: ${complaint['status'] == 1 ? 'Resolved' : 'Pending'}'),
                        if (complaint['reply'].isNotEmpty)
                          Text('Reply: ${complaint['reply']}'),
                      ],
                    ),
                    trailing: complaint['status'] == 1
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : IconButton(
                            icon: const Icon(Icons.reply),
                            onPressed: () => showReplyDialog(context, complaint['id']),
                          ),
                  ),
                );
              },
            ),
          ],
        );
  }
}