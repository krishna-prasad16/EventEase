import 'package:decorators/catering/widgets/custom_catering_appbar.dart';
import 'package:decorators/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          backgroundColor: Color(0xFFA8C7FA), // Pastel blue
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
          content: Text('Feedback deleted'),
          backgroundColor: Color(0xFFA8C7FA), // Pastel blue
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting feedback: $e'),
          backgroundColor: Colors.red,
        ),
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
      backgroundColor: const Color(0xFFF5F6FA), // Pastel light grey
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomCateringAppBar(isScrolled: false),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600), // Web-friendly width
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Icon(
                            Icons.feedback,
                            size: 60,
                            color: const Color(0xFFB8D8D8), // Pastel teal
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'We value your feedback!',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3A3A3A),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: feedbackController,
                            decoration: InputDecoration(
                              labelText: 'Feedback Title',
                              labelStyle: GoogleFonts.poppins(
                                color: const Color(0xFF6B7280),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC), // Pastel off-white
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.title,
                                color: Color(0xFFB8D8D8), // Pastel teal
                              ),
                            ),
                            style: GoogleFonts.poppins(),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Title is required' : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            minLines: 3,
                            maxLines: 6,
                            keyboardType: TextInputType.multiline,
                            controller: detailsController,
                            decoration: InputDecoration(
                              labelText: 'Details',
                              labelStyle: GoogleFonts.poppins(
                                color: const Color(0xFF6B7280),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.description,
                                color: Color(0xFFB8D8D8),
                              ),
                            ),
                            style: GoogleFonts.poppins(),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Details are required' : null,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : submitFeedback,
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                isLoading ? 'Submitting...' : 'Submit Feedback',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA8C7FA), // Pastel blue
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Feedback",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3A3A3A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  feedbackList.isEmpty
                      ? Text(
                          "No feedback submitted yet.",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF6B7280),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: feedbackList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final fb = feedbackList[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC), // Pastel off-white
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          fb['complaint_title'] ?? '',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: const Color(0xFF3A3A3A),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 22,
                                        ),
                                        tooltip: 'Delete',
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(
                                                'Delete Feedback',
                                                style: GoogleFonts.poppins(),
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete this feedback?',
                                                style: GoogleFonts.poppins(),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: Text(
                                                    'Cancel',
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: Text(
                                                    'Delete',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.red,
                                                    ),
                                                  ),
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
                                  const SizedBox(height: 8),
                                  Text(
                                    fb['complaint_content'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (fb['complaint_reply'] != null &&
                                      fb['complaint_reply'].toString().trim().isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB8D8D8).withOpacity(0.2), // Pastel teal
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.reply,
                                            color: Color(0xFFB8D8D8),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              fb['complaint_reply'],
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFFB8D8D8),
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}