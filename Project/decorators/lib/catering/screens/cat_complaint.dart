
import 'package:decorators/catering/widgets/custom_catering_appbar.dart';
import 'package:decorators/main.dart';
import 'package:flutter/material.dart';



class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController feedbackController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> feedbackList = [];

  Future<void> submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      String? catId = supabase.auth.currentUser!.id;
      await supabase.from('tbl_complaint').insert({
        'complaint_title': feedbackController.text,
        'complaint_content': detailsController.text,
        'catering_id': catId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Feedback submitted',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      feedbackController.clear();
      detailsController.clear();
      await fetchfeedbackList(); // Refresh after insert
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchfeedbackList() async {
    try {
      String? catId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_complaint')
          .select()
          .eq('catering_id', catId)
          .order('created_at', ascending: false);
      setState(() {
        feedbackList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching feedbackList: $e');
    }
  }

  Future<void> deleteFeedback(int id) async {
    try {
      await supabase.from('tbl_complaint').delete().eq('id', id);
      await fetchfeedbackList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Feedback deleted'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error deleting feedback: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchfeedbackList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomCateringAppBar(isScrolled: false),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Icon(Icons.feedback,
                            size: 60, color: Color(0xFFbc6c25)),
                        const SizedBox(height: 10),
                        const Text(
                          'We value your feedback!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFbc6c25),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: feedbackController,
                          decoration: InputDecoration(
                            labelText: 'Feedback Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Title is required'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          minLines: 3,
                          maxLines: 6,
                          keyboardType: TextInputType.multiline,
                          controller: detailsController,
                          decoration: InputDecoration(
                            labelText: 'Details',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Details are required'
                                  : null,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : submitFeedback,
                            icon: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              isLoading ? 'Submitting...' : 'Submit Feedback',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xfff8f9fa),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFbc6c25),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
           Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Your Feedback",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFbc6c25),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                feedbackList.isEmpty
                    ? const Text(
                        "No feedback submitted yet.",
                        style: TextStyle(color: Colors.grey),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: feedbackList.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final fb = feedbackList[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Color(0xFFf6f6f6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        fb['complaint_title'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFFbc6c25),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                                      tooltip: 'Delete',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Feedback'),
                                            content: const Text('Are you sure you want to delete this feedback?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await deleteFeedback(fb['id']);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  fb['complaint_content'] ?? '',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 8),
                                if (fb['complaint_reply'] != null && fb['complaint_reply'].toString().trim().isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.reply, color: Colors.green, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            fb['complaint_reply'],
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
