import 'package:decorators/catering/widgets/custom_catering_appbar.dart';
import 'package:decorators/main.dart';
import 'package:flutter/material.dart';
// For date formatting if needed

class CatBookingdetails extends StatefulWidget {
  final int id;
  const CatBookingdetails({super.key, required this.id});

  @override
  State<CatBookingdetails> createState() => _CatBookingdetailsState();
}

class _CatBookingdetailsState extends State<CatBookingdetails> {
  Map<String, dynamic>? booking;
  List<dynamic> foodList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // Fetch booking details
      final bookingResponse = await supabase
          .from('tbl_cateringbooking')
          .select('*, tbl_eventtype(eventtype_name), tbl_user(user_name)')
          .eq('id', widget.id)
          .single();

      // Fetch food details for this booking
      final foodResponse = await supabase
          .from('tbl_bookingfood')
          .select('*, tbl_food(food_name, food_amount)')
          .eq('cateringbooking_id', widget.id);

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

  Future<void> updateBookingStatus(int status, {double? amount}) async {
    try {
      final updateData = {'booking_status': status};
      if (amount != null) {
        updateData['booking_total'] = amount as int;
      }
      await supabase
          .from('tbl_cateringbooking')
          .update(updateData)
          .eq('id', widget.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == 1 ? 'Booking accepted!' : (status == 2 ? 'Booking rejected!' : 'Status updated!'))),
      );
      fetchBookingDetails(); // Refresh booking details after update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating booking status: $e')),
      );
    }
  }

  void showAcceptDialog() {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Accept Booking'),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter Amount',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null) {
                  updateBookingStatus(1, amount: amount);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Booking'),
          content: const Text('Are you sure you want to reject this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateBookingStatus(2);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> markWorkAsCompleted() async {
    try {
      await supabase
          .from('tbl_cateringbooking')
          .update({'booking_status': 5})
          .eq('id', widget.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Work marked as completed!')),
      );
      fetchBookingDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking work as completed: $e')),
      );
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
        return 'Work Completed';
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
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomCateringAppBar(isScrolled: false),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : booking == null
                  ? const Center(child: Text('No details found.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Event: ${booking!['tbl_eventtype']?['eventtype_name'] ?? ''}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(booking!['booking_status']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      getStatusLabel(booking!['booking_status']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: getStatusColor(booking!['booking_status']),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (booking!['booking_status'] == 0)
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: showAcceptDialog,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Accept', style: TextStyle(fontSize: 12)),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: showRejectDialog,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Reject', style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  if (booking!['booking_status'] == 1)
                                    ElevatedButton(
                                      onPressed: markWorkAsCompleted,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Mark as Completed', style: TextStyle(fontSize: 12)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Booked By: ${booking!['tbl_user']?['user_name'] ?? ''}'),
                          const SizedBox(height: 8),
                          Text('Date: ${booking!['booking_fordate'] ?? ''}'),
                          const SizedBox(height: 8),
                          Text('Venue: ${booking!['booking_venue'] ?? ''}'),
                          const SizedBox(height: 8),
                          Text('Budget: ${booking!['booking_budget'] ?? ''}'),
                          const SizedBox(height: 8),
                          Text('Count: ${booking!['booking_count'] ?? ''}'),
                          const Divider(height: 32),
                          const Text(
                            'Food Details',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          foodList.isEmpty
                              ? const Text('No food items selected.')
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: foodList.length,
                                  itemBuilder: (context, index) {
                                    final food = foodList[index]['tbl_food'];
                                    return ListTile(
                                      title: Text(food?['food_name'] ?? ''),
                                      trailing: Text('₹${food?['food_amount'] ?? ''}'),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
    );
  }
}