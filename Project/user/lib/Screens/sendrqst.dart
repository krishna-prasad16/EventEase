import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:user/Screens/Homepage.dart';
import 'package:user/main.dart';

class SendRequest extends StatefulWidget {
  final int id;
  const SendRequest({super.key, required this.id});

  @override
  State<SendRequest> createState() => _SendRequestState();
}

class _SendRequestState extends State<SendRequest> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Selected values
  String? selectedPlace;
  String? selectedDist;
  String? selectedEvent;

  // Dropdown data
  List<Map<String, dynamic>> _distList = [];
  List<Map<String, dynamic>> _placeList = [];
  List<Map<String, dynamic>> _eventList = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchDist();
    fetchEvent();
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
    _detailsController.dispose();
    _budgetController.dispose();
    _venueController.dispose();
    _dateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchEvent() async {
    try {
      final response = await supabase.from('tbl_eventtype').select();
      if (response.isNotEmpty) {
        setState(() {
          _eventList = response;
        });
      }
    } catch (e) {
      print("Error fetching Events: $e");
    }
  }

  Future<void> fetchDist() async {
    try {
      final response = await supabase.from('tbl_district').select();
      if (response.isNotEmpty) {
        setState(() {
          _distList = response;
        });
      }
    } catch (e) {
      print("Error fetching districts: $e");
    }
  }

  Future<void> fetchPlace(String? id) async {
    try {
      final response = await supabase.from('tbl_place').select().eq('dist_id', id!);
      setState(() {
        _placeList = response;
      });
    } catch (e) {
      print("ERROR FETCHING DISTRICT DATA: $e");
    }
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final payload = {
        'decoration_id': widget.id,
        'eventtype_id': selectedEvent,
        'decbook_detail': _detailsController.text,
        'decbook_fordate': _dateController.text,
        'decbook_budget': _budgetController.text,
        'decbook_venue': _venueController.text,
        'place_id': selectedPlace,
      };

      try {
        final response = await supabase.from('tbl_decorationbooking').insert(payload);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Homepage(),
          ),
        );
      } catch (error) {
        print("Insert Error: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insert failed: $error')),
        );
      }
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
          'Send Request',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E2723),
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF8D6E63)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFFF9F6F2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedEvent,
                        hint: Text(
                          "Select Event Type",
                          style: GoogleFonts.openSans(color: Colors.grey.shade600),
                        ),
                        decoration: InputDecoration(
                          labelText: "Events",
                          labelStyle: GoogleFonts.openSans(color: Color(0xFF3E2723)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          prefixIcon: Icon(Icons.event, color: Color(0xFF8D6E63)),
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            selectedEvent = newValue;
                          });
                        },
                        items: _eventList.map((event) {
                          return DropdownMenuItem<String>(
                            value: event['id'].toString(),
                            child: Text(
                              event['eventtype_name'],
                              style: GoogleFonts.openSans(),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _detailsController,
                        decoration: InputDecoration(
                          labelText: 'Event Details',
                          labelStyle: GoogleFonts.openSans(color: Color(0xFF3E2723)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.openSans(),
                        maxLines: 3,
                        validator: (val) => val!.isEmpty ? 'Please enter event details' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Event Date',
                          labelStyle: GoogleFonts.openSans(color: Color(0xFF3E2723)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF8D6E63)),
                        ),
                        style: GoogleFonts.openSans(),
                        onTap: _pickDate,
                        validator: (val) => val!.isEmpty ? 'Please select event date' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Budget',
                          labelStyle: GoogleFonts.openSans(color: Color(0xFF3E2723)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.openSans(),
                        validator: (val) => val!.isEmpty ? 'Please enter budget' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _venueController,
                        decoration: InputDecoration(
                          labelText: 'Venue',
                          labelStyle: GoogleFonts.openSans(color: Color(0xFF3E2723)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.openSans(),
                        validator: (val) => val!.isEmpty ? 'Please enter venue' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedDist,
                        hint: Text(
                          "Select District",
                          style: GoogleFonts.openSans(color: Colors.grey.shade600),
                        ),
                        decoration: InputDecoration(
                          labelText: "District",
                          labelStyle: GoogleFonts.openSans(color: Color(0xFF3E2723)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          prefixIcon: Icon(Icons.location_city, color: Color(0xFF8D6E63)),
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            selectedDist = newValue;
                            selectedPlace = null; // Reset place when district changes
                            _placeList = []; // Clear place list
                          });
                          fetchPlace(newValue);
                        },
                        items: _distList.map((district) {
                          return DropdownMenuItem<String>(
                            value: district['id'].toString(),
                            child: Text(
                              district['dist_name'],
                              style: GoogleFonts.openSans(),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedPlace,
                        hint: Text(
                          "Select Place",
                          style: GoogleFonts.openSans(color: Colors.grey.shade600),
                        ),
                        decoration: InputDecoration(
                          labelText: "Place",
                          labelStyle: GoogleFonts.openSans(color: Color(0xFF3E2723)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          prefixIcon: Icon(Icons.place, color: Color(0xFF8D6E63)),
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            selectedPlace = newValue;
                          });
                        },
                        items: _placeList.map((place) {
                          return DropdownMenuItem<String>(
                            value: place['place_id'].toString(),
                            child: Text(
                              place['place_name'],
                              style: GoogleFonts.openSans(),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6D4C41),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Send Request',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}