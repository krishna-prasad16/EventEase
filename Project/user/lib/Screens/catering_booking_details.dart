import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/Screens/payment.dart';

class CateringBookingDetails extends StatefulWidget {
  final int bookingId;
  const CateringBookingDetails({super.key, required this.bookingId});

  @override
  State<CateringBookingDetails> createState() => _CateringBookingDetailsState();
}

class _CateringBookingDetailsState extends State<CateringBookingDetails> with SingleTickerProviderStateMixin {
  Map<String, dynamic> booking = {};
  List<dynamic> foodList = [];
  bool isLoading = true;
  String? errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchBookingDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final bookingResponse = await Supabase.instance.client
          .from('tbl_cateringbooking')
          .select('id, catering_id, booking_fordate, booking_status, booking_budget, booking_venue, booking_total, booking_detail, tbl_eventtype(eventtype_name), tbl_user(user_name)')
          .eq('id', widget.bookingId)
          .single();

      final foodResponse = await Supabase.instance.client
          .from('tbl_bookingfood')
          .select('*, tbl_food(food_name, food_amount)')
          .eq('cateringbooking_id', widget.bookingId);

      setState(() {
        booking = bookingResponse;
        foodList = foodResponse;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching details: $e';
      });
    }
  }

  String getStatusLabel(int? status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Rejected by Caterers';
      case 3:
        return 'Payment Completed';
      case 4:
        return 'Rejected by User';
      case 5:
        return 'Completed';
      default:
        return 'N/A';
    }
  }

  Color getStatusColor(int? status) {
    switch (status) {
      case 0:
        return Color(0xFFFFCC80);
      case 1:
        return Color(0xFF64B5F6);
      case 2:
        return Color(0xFFE57373);
      case 3:
        return Color(0xFF81C784);
      case 4:
        return Color(0xFFE57373);
      case 5:
        return Color(0xFF81C784);
      default:
        return Colors.grey.shade600;
    }
  }

  Future<void> submitCateringRating(int ratingValue, String comment) async {
    try {
      await Supabase.instance.client.from('tbl_review').insert({
        'catering_id': booking['catering_id'],
        'review_rating': ratingValue,
        'review_content': comment,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully')),
      );
    } catch (e) {
      print("Error submitting rating: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating')),
      );
    }
  }

  Future<void> submitCateringComplaint(String title, String content) async {
    try {
      await Supabase.instance.client.from('tbl_complaint').insert({
        'catering_id': booking['catering_id'],
        'complaint_title': title,
        'complaint_content': content,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully')),
      );
    } catch (e) {
      print("Error submitting complaint: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting complaint')),
      );
    }
  }

  void showCateringRatingDialog() {
    int ratingValue = 0;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Catering', style: GoogleFonts.lora()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Rating:', style: GoogleFonts.openSans()),
            StatefulBuilder(
              builder: (context, setState) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < ratingValue ? Icons.star : Icons.star_border,
                      color: Color(0xFFFFCC80),
                    ),
                    onPressed: () {
                      setState(() {
                        ratingValue = index + 1;
                      });
                    },
                  );
                }),
              ),
            ),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Enter your comment (optional)',
                hintStyle: GoogleFonts.openSans(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.openSans(),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.openSans()),
          ),
          TextButton(
            onPressed: () {
              if (ratingValue > 0) {
                submitCateringRating(ratingValue, commentController.text);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a rating')),
                );
              }
            },
            child: Text('Submit', style: GoogleFonts.openSans(color: Color(0xFF6D4C41))),
          ),
        ],
      ),
    );
  }

  void showCateringComplaintDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Complaint', style: GoogleFonts.lora()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Complaint Title',
                hintStyle: GoogleFonts.openSans(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.openSans(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: 'Complaint Details',
                hintStyle: GoogleFonts.openSans(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.openSans(),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.openSans()),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                submitCateringComplaint(titleController.text, contentController.text);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
              }
            },
            child: Text('Submit', style: GoogleFonts.openSans(color: Color(0xFF6D4C41))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Catering Booking Details',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E2723),
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF8D6E63)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF8D6E63)),
            onPressed: fetchBookingDetails,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFF8D6E63)))
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          style: GoogleFonts.openSans(
                            color: Color(0xFFE57373),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: fetchBookingDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6D4C41),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Color(0xFFF9F6F2),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                icon: Icons.info,
                                label: 'Status',
                                value: getStatusLabel(booking['booking_status']),
                                valueColor: getStatusColor(booking['booking_status']),
                                isBold: true,
                              ),
                              const SizedBox(height: 16),
                              if (booking['booking_status'] == 1) ...[
                                _buildDetailRow(
                                  icon: Icons.attach_money,
                                  label: 'Estimated Value',
                                  value: '₹${booking['booking_total'] ?? 'N/A'}',
                                  isBold: true,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentGatewayScreen(
                                              id: booking['id'],
                                              amt: booking['booking_total'],
                                              isCatering: true,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF81C784),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      ),
                                      child: Text(
                                        'Accept and Pay',
                                        style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Reject Booking', style: GoogleFonts.lora()),
                                              content: Text(
                                                'Are you sure you want to reject this booking?',
                                                style: GoogleFonts.openSans(),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: Text('Cancel', style: GoogleFonts.openSans()),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    try {
                                                      await Supabase.instance.client
                                                          .from('tbl_cateringbooking')
                                                          .update({'booking_status': 4})
                                                          .eq('id', booking['id']);
                                                      Navigator.pop(context);
                                                      fetchBookingDetails();
                                                    } catch (e) {
                                                      print('Error rejecting booking: $e');
                                                    }
                                                  },
                                                  child: Text(
                                                    'Reject',
                                                    style: GoogleFonts.openSans(color: Color(0xFFE57373)),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFE57373),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      ),
                                      child: Text(
                                        'Reject',
                                        style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.event,
                                label: 'Event Type',
                                value: booking['tbl_eventtype']?['eventtype_name'] ?? 'N/A',
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.calendar_today,
                                label: 'Date',
                                value: booking['booking_fordate'] ?? 'N/A',
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.account_balance_wallet,
                                label: 'Budget',
                                value: '₹${booking['booking_budget'] ?? 'N/A'}',
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.location_on,
                                label: 'Venue',
                                value: booking['booking_venue'] ?? 'N/A',
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.description,
                                label: 'Details',
                                value: booking['booking_detail'] ?? 'N/A',
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.person,
                                label: 'Booked By',
                                value: booking['tbl_user']?['user_name'] ?? 'N/A',
                              ),
                              const SizedBox(height: 24),
                              Divider(color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'Food Details',
                                style: GoogleFonts.lora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              const SizedBox(height: 12),
                              foodList.isEmpty
                                  ? Text(
                                      'No food items selected.',
                                      style: GoogleFonts.openSans(
                                        color: Colors.grey.shade600,
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: foodList.length,
                                      itemBuilder: (context, index) {
                                        final food = foodList[index]['tbl_food'];
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            food?['food_name'] ?? '',
                                            style: GoogleFonts.openSans(
                                              fontSize: 14,
                                              color: Color(0xFF3E2723),
                                            ),
                                          ),
                                          trailing: Text(
                                            '₹${food?['food_amount'] ?? ''}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 14,
                                              color: Color(0xFF3E2723),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (booking['booking_status'] == 5)
                                    ElevatedButton.icon(
                                      onPressed: showCateringRatingDialog,
                                      icon: Icon(Icons.star, color: Colors.white),
                                      label: Text(
                                        'Rate',
                                        style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFFFCC80),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      ),
                                    ),
                                  if (booking['booking_status'] == 1 ||
                                      booking['booking_status'] == 3 ||
                                      booking['booking_status'] == 5)
                                    ElevatedButton.icon(
                                      onPressed: showCateringComplaintDialog,
                                      icon: Icon(Icons.report, color: Colors.white),
                                      label: Text(
                                        'Report Complaint',
                                        style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFE57373),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Color(0xFF8D6E63),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  color: valueColor ?? Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}