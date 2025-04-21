import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/Screens/payment.dart';

class Bookingdetails extends StatefulWidget {
  final int id;
  const Bookingdetails({super.key, required this.id});

  @override
  State<Bookingdetails> createState() => _BookingdetailsState();
}

class _BookingdetailsState extends State<Bookingdetails> {
  Map<String, dynamic> _bookings = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchBookings();
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

  // Submit rating to Supabase
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

  // Submit complaint to Supabase
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

  // Show rating dialog
  void showRatingDialog() {
    int ratingValue = 0;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Booking'),
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
                submitRating(ratingValue, commentController.text);
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

  // Show complaint dialog
  void showComplaintDialog() {
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
                submitComplaint(titleController.text, contentController.text);
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

  // Map status code to label and color
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
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 208, 205, 212),
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
                        onPressed: fetchBookings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status
                            _buildDetailRow(
                              icon: Icons.info,
                              label: 'Status',
                              value: getStatusLabel(_bookings['decbook_status']),
                              valueColor: getStatusColor(_bookings['decbook_status']),
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            // Show Estimated Value and Buttons if status is 1
                            if (_bookings['decbook_status'] == 1) ...[
                              _buildDetailRow(
                                icon: Icons.attach_money,
                                label: 'Estimated Value',
                                value: '₹${_bookings['decbook_totalamnt'] ?? 'N/A'}',
                                isBold: true,
                              ),
                              const SizedBox(height: 12),
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
                                                        .from('tbl_decorationbooking')
                                                        .update({'decbook_status': 4})
                                                        .eq('decbook_id', _bookings['decbook_id']);
                                                    Navigator.pop(context);
                                                    fetchBookings();
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
                              value: _bookings['tbl_eventtype']?['eventtype_name'] ?? 'N/A',
                            ),
                            const SizedBox(height: 12),
                            // Date
                            _buildDetailRow(
                              icon: Icons.calendar_today,
                              label: 'Date',
                              value: _bookings['decbook_fordate'] ?? 'N/A',
                            ),
                            const SizedBox(height: 12),
                            // Budget
                            _buildDetailRow(
                              icon: Icons.account_balance_wallet,
                              label: 'Budget',
                              value: '₹${_bookings['decbook_budget'] ?? 'N/A'}',
                            ),
                            const SizedBox(height: 12),
                            // Venue
                            _buildDetailRow(
                              icon: Icons.location_on,
                              label: 'Venue',
                              value: _bookings['decbook_venue'] ?? 'N/A',
                            ),
                            const SizedBox(height: 12),
                            // Details
                            _buildDetailRow(
                              icon: Icons.description,
                              label: 'Details',
                              value: _bookings['decbook_detail'] ?? 'N/A',
                            ),
                            const SizedBox(height: 12),
                            // District
                            _buildDetailRow(
                              icon: Icons.map,
                              label: 'District',
                              value: _bookings['tbl_place']?['tbl_district']?['dist_name'] ?? 'N/A',
                            ),
                            const SizedBox(height: 12),
                            // Place
                            _buildDetailRow(
                              icon: Icons.place,
                              label: 'Place',
                              value: _bookings['tbl_place']?['place_name'] ?? 'N/A',
                            ),
                            const SizedBox(height: 20),
                            // Rate and Complaint Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (_bookings['decbook_status'] == 5)
                                  ElevatedButton.icon(
                                    onPressed: showRatingDialog,
                                    icon: const Icon(Icons.star),
                                    label: const Text('Rate'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                    ),
                                  ),
                                if (_bookings['decbook_status'] == 1 ||
                                    _bookings['decbook_status'] == 3 ||
                                    _bookings['decbook_status'] == 5)
                                  ElevatedButton.icon(
                                    onPressed: showComplaintDialog,
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
}