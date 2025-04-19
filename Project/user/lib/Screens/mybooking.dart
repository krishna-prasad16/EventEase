import 'package:flutter/material.dart';
import 'package:user/Screens/bookingdetails.dart';
import 'package:intl/intl.dart';
import 'package:user/Screens/catering_booking_details.dart';
import 'package:user/main.dart';

class Mybooking extends StatefulWidget {
  const Mybooking({super.key});

  @override
  State<Mybooking> createState() => _MybookingState();
}

class _MybookingState extends State<Mybooking> {
  List<dynamic> decorationBookings = [];
  List<dynamic> cateringBookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllBookings();
  }

  Future<void> fetchAllBookings() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Fetch decoration bookings
      final decorationResponse = await supabase
          .from('tbl_decorationbooking')
          .select('decbook_id, decbook_date, decbook_status, tbl_eventtype(eventtype_name), tbl_user(user_name),decbook_budget')
          .eq('user_id', supabase.auth.currentUser!.id)
          .order('decbook_date', ascending: false);

      // Fetch catering bookings
      final cateringResponse = await supabase
          .from('tbl_cateringbooking')
          .select('id, booking_fordate, booking_status, tbl_eventtype(eventtype_name), tbl_user(user_name), booking_budget, booking_venue')
          .eq('user_id', supabase.auth.currentUser!.id)
          .order('booking_fordate', ascending: false);
      print("Response: ${cateringResponse[0]}");
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

  // Function to format the date
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

  // Map status code to label and color
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
        return Colors.amber.shade600;
      case 1:
        return Colors.blue.shade600;
      case 2:
        return Colors.red.shade600;
      case 3:
        return Colors.green.shade600;
      case 4:
        return Colors.red.shade600;
      case 5:
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "My Bookings",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: fetchAllBookings,
              tooltip: 'Refresh Bookings',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Decoration"),
              Tab(text: "Catering"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
            : TabBarView(
                children: [
                  // Decoration Bookings Tab
                  _buildBookingList(
                    decorationBookings,
                    isDecoration: true,
                  ),
                  // Catering Bookings Tab
                  _buildBookingList(
                    cateringBookings,
                    isDecoration: false,
                  ),
                ],
              ),
      ),
    );
  }

  // Helper widget to build booking list for each tab
  Widget _buildBookingList(List<dynamic> bookings, {required bool isDecoration}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "No bookings found",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Book an event to get started!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDecoration ? Icons.event : Icons.restaurant,
                          color: Colors.grey,
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
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    getStatusLabel(status),
                                    style: TextStyle(
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
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Date: $bookingDate",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (venue.isNotEmpty)
                              Text(
                                "Venue: $venue",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            Text(
                              "Budget: ${budget.toString()}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                      ),
                    ],
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