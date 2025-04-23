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
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Source Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                complaint['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            _buildSourceChip(complaint),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'From: ${complaint['name']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint['description'],
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const Spacer(),
                            Text(
                              complaint['status'] == 1 ? 'Resolved' : 'Pending',
                              style: TextStyle(
                                color: complaint['status'] == 1 ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (complaint['reply'].isNotEmpty) ...[
                          const Divider(height: 20),
                          Text(
                            'Reply: ${complaint['reply']}',
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        ],
                        if (complaint['status'] != 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.reply, size: 18),
                              label: const Text('Reply'),
                              onPressed: () => showReplyDialog(context, complaint['id']),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
  }
}

Widget _buildSourceChip(Map<String, dynamic> complaint) {
  String source = '';
  Color color = Colors.grey;
  if (complaint['user_id'] != null) {
    source = 'User';
    color = Colors.blue;
  } else if (complaint['decorator_id'] != null) {
    source = 'Decorator';
    color = Colors.purple;
  } else if (complaint['catering_id'] != null) {
    source = 'Catering';
    color = Colors.teal;
  }
  return Chip(
    label: Text(source, style: const TextStyle(color: Colors.white)),
    backgroundColor: color,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
  );
}