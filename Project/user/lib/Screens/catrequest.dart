import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user/Screens/Homepage.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/main.dart';

class Catrequest extends StatefulWidget {
  final List<int> food;
  final String catId;
  const Catrequest({super.key, required this.food, required this.catId});

  @override
  State<Catrequest> createState() => _CatrequestState();
}

class _CatrequestState extends State<Catrequest> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  // Selected values
  // String? selectedEventTypeId;
  String? selectedPlace;
  String? selectedDist;
  String? selectedEvent;


  // Dropdown data
  // List<Map<String, dynamic>> eventTypes = [];
  List<Map<String, dynamic>> _distList = [];
  List<Map<String, dynamic>> _placeList = [];
   List<Map<String, dynamic>> _eventList = [];

  @override
  void initState() {
    super.initState();
    fetchDist();
    fetchEvent();
  }

Future<void> fetchEvent() async {
    try {
      final response = await supabase.from('tbl_eventtype').select();
      print(response);
      if (response.isNotEmpty) {
        print(response);
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
      print(response);
      if (response.isNotEmpty) {
        print(response);
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
      final response =
          await supabase.from('tbl_place').select().eq('dist_id', id!);
      // print(response);
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
      'eventtype_id': selectedEvent,
      'booking_fordate': _dateController.text,
      'booking_budget': _budgetController.text,
      'booking_count': _countController.text,
      'booking_venue': _venueController.text,
      'booking_detail': _detailsController.text,
      'place_id': selectedPlace,
      'catering_id': widget.catId,
    };

    print("Sending data: $payload");

    try { 
      final response = await supabase.from('tbl_cateringbooking').insert(payload).select().single();
      for(var food in widget.food){
        final foodPayload = {
          'cateringbooking_id': response['id'],
          'food_id': food,
        };
        await supabase.from('tbl_bookingfood').insert(foodPayload);
      }
      print("Insert response: $response");

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
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        title: const Text('Send Request'),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedEvent,
                      hint: const Text("Select Event Type"),
                      decoration: const InputDecoration(
                        labelText: "Events",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          selectedEvent = newValue;
                        });
                        fetchPlace(newValue);
                      },
                      items: _eventList.map((Event) {
                        return DropdownMenuItem<String>(
                          value: Event['id'].toString(),
                          child: Text(Event['eventtype_name']),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _detailsController,
                      decoration: const InputDecoration(
                        labelText: 'Event Details',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (val) =>
                          val!.isEmpty ? 'Please enter event details' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Event Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: _pickDate,
                      validator: (val) =>
                          val!.isEmpty ? 'Please select event date' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Budget',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'Please enter budget' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _venueController,
                      decoration: const InputDecoration(
                        labelText: 'Venue',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'Please enter venue' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _countController,
                      decoration: const InputDecoration(
                        labelText: 'Count',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (val) =>
                          val!.isEmpty ? 'Please enter count' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDist,
                      hint: const Text("Select District"),
                      decoration: const InputDecoration(
                        labelText: "District",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          selectedDist = newValue;
                        });
                        fetchPlace(newValue);
                      },
                      items: _distList.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['id'].toString(),
                          child: Text(district['dist_name']),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPlace,
                      hint: const Text("Select Place"),
                      decoration: const InputDecoration(
                        labelText: "Place",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        prefixIcon: Icon(Icons.place),
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          selectedPlace = newValue;
                        });
                      },
                      items: _placeList.map((place) {
                        return DropdownMenuItem<String>(
                          value: place['place_id'].toString(),
                          child: Text(place['place_name']),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 138, 204, 162),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Send Request',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
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
}
