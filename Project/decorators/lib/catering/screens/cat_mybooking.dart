import 'package:decorators/catering/screens/cat_bookingdetails.dart';
import 'package:decorators/catering/widgets/custom_catering_appbar.dart';
import 'package:decorators/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CatMybooking extends StatefulWidget {
  const CatMybooking({super.key});

  @override
  State<CatMybooking> createState() => _CatMybookingState();
}

class _CatMybookingState extends State<CatMybooking> {
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
          .from('tbl_cateringbooking')
          .select(
              'id, booking_fordate, created_at, tbl_eventtype(eventtype_name),tbl_user(user_name)')
          .eq('catering_id', supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);

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

  String formatDate(dynamic dateValue) {
    if (dateValue == null) return 'No Date';
    try {
      DateTime dateTime;
      if (dateValue is DateTime) {
        dateTime = dateValue;
      } else if (dateValue is String && dateValue.isNotEmpty) {
        dateTime = DateTime.parse(dateValue);
      } else {
        return 'No Date';
      }
      return DateFormat('dd MMMM yyyy').format(dateTime);
    } catch (e) {
      return 'No Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomCateringAppBar(isScrolled: false),
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
                            "No booking with your catering yet!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ]),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final eventName = booking['tbl_eventtype']
                              ?['eventtype_name'] ??
                          'No Event Name';
                      final user =
                          booking['tbl_user']?['user_name'] ?? 'No Decoration';
                      final bookingDate = formatDate(booking['created_at']);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CatBookingdetails(id: booking['id']),
                            ),
                          );
                        },
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        "User: $user",
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
