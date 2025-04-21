import 'package:decorators/decorators/widgets/custom_dec_appbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Added for date formatting

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
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await Supabase.instance.client
          .from('tbl_decorationbooking')
          .select(
              'decbook_detail, decbook_fordate, decbook_budget, decbook_venue, decbook_status, tbl_eventtype(eventtype_name), tbl_place(place_name, tbl_district(dist_name)), tbl_user(user_name)')
          .eq('decbook_id', widget.id)
          .single();

      setState(() {
        _bookings = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load booking details. Please try again.';
      });
    }
  }

  // Format date
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
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
        return 'Rejected by Decorators';
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

  Future<void> updateBookingStatus(int status, {double? amount}) async {
    try {
      final updateData = {'decbook_status': status};
      if (amount != null) {
        updateData['decbook_totalamnt'] = amount as int;
      }
      await Supabase.instance.client
          .from('tbl_decorationbooking')
          .update(updateData)
          .eq('decbook_id', widget.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == 1 ? 'Booking accepted!' : 'Booking rejected!')),
      );
      fetchBookings(); // Refresh booking details after update
    } catch (e) {
      print("Error updating booking status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating booking status: $e')),
      );
    }
  }

  Future<void> markWorkAsCompleted() async {
    try {
      await Supabase.instance.client
          .from('tbl_decorationbooking')
          .update({'decbook_status': 5})
          .eq('decbook_id', widget.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Work marked as completed!')),
      );
      fetchBookings(); // Refresh booking details after update
    } catch (e) {
      print("Error marking work as completed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking work as completed: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomDecAppBar(isScrolled: false),
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
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchBookings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with Event Type and Status
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _bookings['tbl_eventtype']?['eventtype_name'] ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(_bookings['decbook_status']).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              getStatusLabel(_bookings['decbook_status']),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: getStatusColor(_bookings['decbook_status']),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (_bookings['decbook_status'] == 0) // Show Accept/Reject buttons only if status is "Pending"
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
                                          if (_bookings['decbook_status'] == 3) // Show "Mark as Completed" button only if status is "Confirmed"
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
                                  Text(
                                    'Booking ID: ${widget.id}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  // Details
                                  _buildDetailRow(
                                    icon: Icons.person,
                                    label: 'Booked by',
                                    value: _bookings['tbl_user']?['user_name'] ?? 'N/A',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    icon: Icons.calendar_today,
                                    label: 'Date',
                                    value: formatDate(_bookings['decbook_fordate']),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    icon: Icons.account_balance_wallet,
                                    label: 'Budget',
                                    value: '₹${_bookings['decbook_budget']?.toString() ?? 'N/A'}',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    icon: Icons.location_on,
                                    label: 'Venue',
                                    value: _bookings['decbook_venue'] ?? 'N/A',
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
                                  const SizedBox(height: 16),
                                  _buildDetailRow(
                                    icon: Icons.description,
                                    label: 'Details',
                                    value: _bookings['decbook_detail'] ?? 'N/A',
                                    isMultiLine: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
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
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
                maxLines: isMultiLine ? null : 2,
                overflow: isMultiLine ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}