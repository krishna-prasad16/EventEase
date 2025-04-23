import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/Screens/payment.dart';

class Bookingdetails extends StatefulWidget {
  final int id;
  const Bookingdetails({super.key, required this.id});

  @override
  State<Bookingdetails> createState() => _BookingdetailsState();
}

class _BookingdetailsState extends State<Bookingdetails> with SingleTickerProviderStateMixin {
  Map<String, dynamic> _bookings = {};
  bool isLoading = true;
  String? errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchBookings();
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

  Future<void> fetchBookings() async {
    try {
      final data = await Supabase.instance.client
          .from('tbl_decorationbooking')
          .select(
              'decbook_id,decbook_detail,decbook_fordate,decbook_budget,decbook_venue,decbook_status,decbook_totalamnt,tbl_decorations(decorator_id),tbl_eventtype(eventtype_name),tbl_place(place_name,tbl_district(dist_name))')
          .eq('decbook_id', widget.id)
          .single();

      setState(() {
        _bookings = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching booking details: $e");
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load booking details. Please try again.';
      });
    }
  }

  Future<void> submitRating(int ratingValue, String comment) async {
    try {
      await Supabase.instance.client.from('tbl_review').insert({
        'decorator_id': _bookings['tbl_decorations']['decorator_id'],
        'review_rating': ratingValue,
        'review_content': comment,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully')),
      );
    } catch (e) {
      print("Error submitting rating: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating:')),
      );
    }
  }

  Future<void> submitComplaint(String title, String content) async {
    try {
      await Supabase.instance.client.from('tbl_complaint').insert({
        'decorator_id': _bookings['tbl_decorations']['decorator_id'],
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

  void showRatingDialog() {
    int ratingValue = 0;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Booking', style: GoogleFonts.lora()),
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
                submitRating(ratingValue, commentController.text);
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

  void showComplaintDialog() {
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
                submitComplaint(titleController.text, contentController.text);
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

  String getStatusLabel(int? status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Rejected by Decorators';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Booking Details',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E2723),
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF8D6E63)),
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
                          onPressed: fetchBookings,
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
                : SingleChildScrollView(
                    child: Center(
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Color(0xFFF9F6F2),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                icon: Icons.info,
                                label: 'Status',
                                value: getStatusLabel(_bookings['decbook_status']),
                                valueColor: getStatusColor(_bookings['decbook_status']),
                                isBold: true,
                              ),
                              const SizedBox(height: 16),
                              if (_bookings['decbook_status'] == 1) ...[
                                _buildDetailRow(
                                  icon: Icons.attach_money,
                                  label: 'Estimated Value',
                                  value: '₹${_bookings['decbook_totalamnt'] ?? 'N/A'}',
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
                                              id: _bookings['decbook_id'],
                                              amt: _bookings['decbook_totalamnt'],
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
                                                          .from('tbl_decorationbooking')
                                                          .update({'decbook_status': 4})
                                                          .eq('decbook_id', _bookings['decbook_id']);
                                                      Navigator.pop(context);
                                                      fetchBookings();
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
                                value: _bookings['tbl_eventtype']?['eventtype_name'] ?? 'N/A',
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.calendar_today,
                                label: 'Date',
                                value: _bookings['decbook_fordate'] ?? 'N/A',
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.account_balance_wallet,
                                label: 'Budget',
                                value: '₹${_bookings['decbook_budget'] ?? 'N/A'}',
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.location_on,
                                label: 'Venue',
                                value: _bookings['decbook_venue'] ?? 'N/A',
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.description,
                                label: 'Details',
                                value: _bookings['decbook_detail'] ?? 'N/A',
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.map,
                                label: 'District',
                                value: _bookings['tbl_place']?['tbl_district']?['dist_name'] ?? 'N/A',
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.place,
                                label: 'Place',
                                value: _bookings['tbl_place']?['place_name'] ?? 'N/A',
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (_bookings['decbook_status'] == 5)
                                    ElevatedButton.icon(
                                      onPressed: showRatingDialog,
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
                                  if (_bookings['decbook_status'] == 1 ||
                                      _bookings['decbook_status'] == 3 ||
                                      _bookings['decbook_status'] == 5)
                                    ElevatedButton.icon(
                                      onPressed: showComplaintDialog,
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