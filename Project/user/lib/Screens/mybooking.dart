import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/Screens/bookingdetails.dart';
import 'package:intl/intl.dart';
import 'package:user/Screens/catering_booking_details.dart';
import 'package:user/main.dart';

class Mybooking extends StatefulWidget {
  const Mybooking({super.key});

  @override
  State<Mybooking> createState() => _MybookingState();
}

class _MybookingState extends State<Mybooking> with SingleTickerProviderStateMixin {
  List<dynamic> decorationBookings = [];
  List<dynamic> cateringBookings = [];
  bool isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchAllBookings();
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

  Future<void> fetchAllBookings() async {
    setState(() {
      isLoading = true;
    });
    try {
      final decorationResponse = await supabase
          .from('tbl_decorationbooking')
          .select('decbook_id, decbook_date, decbook_status, tbl_eventtype(eventtype_name), tbl_user(user_name),decbook_budget')
          .eq('user_id', supabase.auth.currentUser!.id)
          .order('decbook_date', ascending: false);

      final cateringResponse = await supabase
          .from('tbl_cateringbooking')
          .select('id, booking_fordate, booking_status, tbl_eventtype(eventtype_name), tbl_user(user_name), booking_budget, booking_venue')
          .eq('user_id', supabase.auth.currentUser!.id)
          .order('booking_fordate', ascending: false);

      setState(() {
        decorationBookings = decorationResponse;
        cateringBookings = cateringResponse;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching bookings: $e')),
        );
      }
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'No Date';
    }
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  String getStatusLabel(int? status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Rejected';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "My Bookings",
            style: GoogleFonts.lora(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF3E2723),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Color(0xFF8D6E63)),
              onPressed: fetchAllBookings,
              tooltip: 'Refresh Bookings',
            ),
          ],
          bottom: TabBar(
            labelStyle: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.openSans(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            labelColor: Color(0xFF6D4C41),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Color(0xFF8D6E63),
            tabs: [
              Tab(text: "Decoration"),
              Tab(text: "Catering"),
            ],
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8D6E63)),
                  ),
                )
              : TabBarView(
                  children: [
                    _buildBookingList(
                      decorationBookings,
                      isDecoration: true,
                    ),
                    _buildBookingList(
                      cateringBookings,
                      isDecoration: false,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBookingList(List<dynamic> bookings, {required bool isDecoration}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No bookings found",
              style: GoogleFonts.lora(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Book an event to get started!",
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final eventName = booking['tbl_eventtype']?['eventtype_name'] ?? 'No Event Name';
        final userName = booking['tbl_user']?['user_name'] ?? 'Unknown User';
        final bookingDate = formatDate(
          isDecoration ? booking['decbook_date'] : booking['booking_fordate'],
        );
        final status = isDecoration ? booking['decbook_status'] : booking['booking_status'];
        final venue = isDecoration ? (booking['decbook_venue'] ?? '') : (booking['booking_venue'] ?? '');
        final budget = isDecoration
            ? (booking['decbook_budget'] ?? 0)
            : (booking['booking_budget'] ?? 0);

        return GestureDetector(
          onTap: () {
            if (isDecoration) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Bookingdetails(id: booking['decbook_id']),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CateringBookingDetails(bookingId: booking['id']),
                ),
              );
            }
          },
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF9F6F2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      isDecoration ? Icons.event : Icons.restaurant,
                      color: Color(0xFF8D6E63),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                eventName,
                                style: GoogleFonts.lora(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3E2723),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: getStatusColor(status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                getStatusLabel(status),
                                style: GoogleFonts.openSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: getStatusColor(status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "By: $userName",
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Date: $bookingDate",
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (venue.isNotEmpty)
                          Text(
                            "Venue: $venue",
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        Text(
                          "Budget: ${budget.toString()}",
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Icon(
                      Icons.chevron_right,
                      color: Color(0xFF8D6E63),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}