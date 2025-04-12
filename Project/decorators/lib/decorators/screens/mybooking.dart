import 'package:decorators/decorators/screens/booking_details.dart';
import 'package:decorators/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Mybooking extends StatefulWidget {
  const Mybooking({super.key});

  @override
  State<Mybooking> createState() => _MybookingState();
}

class _MybookingState extends State<Mybooking> {
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await supabase
          .from('tbl_decorationbooking')
          .select(
              'decbook_id, decbook_date, tbl_eventtype(eventtype_name), tbl_decorations(decoration_title, decorator_id)')
          .eq('tbl_decorations.decorator_id', supabase.auth.currentUser!.id)
          .order('decbook_date', ascending: false);
      
      setState(() {
        bookings = response;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: fetchBookings,
            tooltip: 'Refresh Bookings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchBookings,
        color: Colors.grey,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
            : bookings.isEmpty
                ? Center(
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
                          "No events booked with your decorations yet!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ]
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final eventName = booking['tbl_eventtype']?['eventtype_name'] ?? 'No Event Name';
                      final decorationName = booking['tbl_decorations']?['decoration_title'] ?? 'No Decoration';
                      final bookingDate = formatDate(booking['decbook_date']);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Bookingdetails(id: booking['decbook_id']),
                            ),
                          );
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
                            child: Row(
                              children: [
                                // Event Icon
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.event,
                                    color: Colors.grey,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Event Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        eventName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Decoration: $decorationName",
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
                                    ],
                                  ),
                                ),
                                // Chevron
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}