import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController feedbackController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> feedbackList = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchfeedbackList();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    feedbackController.dispose();
    detailsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      String? userId = supabase.auth.currentUser!.id;
      await supabase.from('tbl_complaint').insert({
        'complaint_title': feedbackController.text,
        'complaint_content': detailsController.text,
        'user_id': userId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Feedback submitted',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF3E2723),
        ),
      );
      feedbackController.clear();
      detailsController.clear();
      await fetchfeedbackList();
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
      String? userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_complaint')
          .select()
          .eq('user_id', userId)
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
            content: Text('Feedback deleted'), backgroundColor: Color(0xFF3E2723)),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Feedback',
          style: GoogleFonts.lora(
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF8D6E63)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F6F2),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Icon(Icons.feedback, size: 60, color: Color(0xFF8D6E63)),
                        const SizedBox(height: 10),
                        Text(
                          'We value your feedback!',
                          style: GoogleFonts.lora(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: feedbackController,
                          decoration: InputDecoration(
                            labelText: 'Feedback Title',
                            labelStyle: GoogleFonts.openSans(
                              color: Colors.grey.shade600,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.title, color: Color(0xFF8D6E63)),
                          ),
                          style: GoogleFonts.openSans(),
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
                            labelStyle: GoogleFonts.openSans(
                              color: Colors.grey.shade600,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.description, color: Color(0xFF8D6E63)),
                          ),
                          style: GoogleFonts.openSans(),
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
                                : Icon(Icons.send, color: Colors.white),
                            label: Text(
                              isLoading ? 'Submitting...' : 'Submit Feedback',
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6D4C41),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Your Feedback",
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              feedbackList.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "No feedback submitted yet.",
                        style: GoogleFonts.openSans(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: feedbackList.length,
                      separatorBuilder: (_, __) => SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final fb = feedbackList[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      fb['complaint_title'] ?? '',
                                      style: GoogleFonts.lora(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Color(0xFF3E2723),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.redAccent, size: 22),
                                    tooltip: 'Delete',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Delete Feedback', style: GoogleFonts.lora()),
                                          content: Text(
                                            'Are you sure you want to delete this feedback?',
                                            style: GoogleFonts.openSans(),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text('Cancel', style: GoogleFonts.openSans()),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: Text(
                                                'Delete',
                                                style: GoogleFonts.openSans(color: Colors.redAccent),
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
                              const SizedBox(height: 4),
                              Text(
                                fb['complaint_content'] ?? '',
                                style: GoogleFonts.openSans(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (fb['complaint_reply'] != null && fb['complaint_reply'].toString().trim().isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF8D6E63).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.reply, color: Color(0xFF8D6E63), size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          fb['complaint_reply'],
                                          style: GoogleFonts.openSans(
                                            color: Color(0xFF8D6E63),
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
      ),
    );
  }
}