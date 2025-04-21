import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/Screens/payment.dart';

class CateringBookingDetails extends StatefulWidget {
  final int bookingId;
  const CateringBookingDetails({super.key, required this.bookingId});

  @override
  State<CateringBookingDetails> createState() => _CateringBookingDetailsState();
}

class _CateringBookingDetailsState extends State<CateringBookingDetails> {
  Map<String, dynamic> booking = {};
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
      final bookingResponse = await Supabase.instance.client
          .from('tbl_cateringbooking')
          .select('id, catering_id, booking_fordate, booking_status, booking_budget, booking_venue, booking_total, booking_detail, tbl_eventtype(eventtype_name), tbl_user(user_name)')
          .eq('id', widget.bookingId)
          .single();

      // Fetch food details for this booking
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

  // Map status code to label and color
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
        return Colors.amber;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.red;
      case 3:
        return Colors.green;
      case 4:
        return Colors.redAccent;
      case 5:
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catering Booking Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 208, 205, 212),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchBookingDetails,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchBookingDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status
                            _buildDetailRow(
                              icon: Icons.info,
                              label: 'Status',
                              value: getStatusLabel(booking['booking_status']),
                              valueColor: getStatusColor(booking['booking_status']),
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            // Show Estimated Value and Buttons if status is 1
                            if (booking['booking_status'] == 1) ...[
                              _buildDetailRow(
                                icon: Icons.attach_money,
                                label: 'Estimated Value',
                                value: '₹${booking['booking_total'] ?? 'N/A'}',
                                isBold: true,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle Accept and Pay action
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
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Accept and Pay'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Reject Booking'),
                                            content: const Text('Are you sure you want to reject this booking?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    await Supabase.instance.client
                                                        .from('tbl_cateringbooking')
                                                        .update({'booking_status': 4})
                                                        .eq('id', booking['id']);
                                                    Navigator.pop(context);
                                                    fetchBookingDetails(); // Refresh
                                                  } catch (e) {
                                                    print('Error rejecting booking: $e');
                                                  }
                                                },
                                                child: const Text('Reject'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Reject'),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Event Type
                            _buildDetailRow(
                              icon: Icons.event,
                              label: 'Event Type',
                              value: booking['tbl_eventtype']?['eventtype_name'] ?? 'N/A',
                            ),
                            const SizedBox(height: 12),
                            // Date
                            _buildDetailRow(
                              icon: Icons.calendar_today,
                              label: 'Date',
                              value: booking['booking_fordate'] ?? 'N/A',
                            ),
                            const SizedBox(height: 12),
                            // Budget
                            _buildDetailRow(
                              icon: Icons.account_balance_wallet,
                              label: 'Budget',
                              value: '₹${booking['booking_budget'] ?? 'N/A'}',
                            ),
                            const SizedBox(height: 12),
                            // Venue
                            _buildDetailRow(
                              icon: Icons.location_on,
                              label: 'Venue',
                              value: booking['booking_venue'] ?? 'N/A',
                            ),
                            const SizedBox(height: 12),
                            // Details
                            _buildDetailRow(
                              icon: Icons.description,
                              label: 'Details',
                              value: booking['booking_detail'] ?? 'N/A',
                            ),
                            const SizedBox(height: 12),
                            // Booked By
                            _buildDetailRow(
                              icon: Icons.person,
                              label: 'Booked By',
                              value: booking['tbl_user']?['user_name'] ?? 'N/A',
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 8),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (booking['booking_status'] == 5)
                                  ElevatedButton.icon(
                                    onPressed: showCateringRatingDialog,
                                    icon: const Icon(Icons.star),
                                    label: const Text('Rate'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                    ),
                                  ),
                                if (booking['booking_status'] == 1 ||
                                    booking['booking_status'] == 3 ||
                                    booking['booking_status'] == 5)
                                  ElevatedButton.icon(
                                    onPressed: showCateringComplaintDialog,
                                    icon: const Icon(Icons.report),
                                    label: const Text('Report Complaint'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
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
          color: Colors.grey[600],
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: valueColor ?? Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Submit rating to Supabase
  Future<void> submitCateringRating(int ratingValue, String comment) async {
    try {
      await Supabase.instance.client.from('tbl_review').insert({
        'catering_id': booking['catering_id'], // Make sure you fetch catering_id in your booking query!
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

  // Submit complaint to Supabase
  Future<void> submitCateringComplaint(String title, String content) async {
    try {
      await Supabase.instance.client.from('tbl_complaint').insert({
        'catering_id': booking['catering_id'], // Make sure you fetch catering_id in your booking query!
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
        title: const Text('Rate Catering'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Rating:'),
            StatefulBuilder(
              builder: (context, setState) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < ratingValue ? Icons.star : Icons.star_border,
                      color: Colors.amber,
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
              decoration: const InputDecoration(hintText: 'Enter your comment (optional)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Submit'),
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
        title: const Text('Report Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Complaint Title'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(hintText: 'Complaint Details'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}