import 'package:flutter/material.dart';
import 'package:admin/main.dart';

class ManageEvent extends StatefulWidget {
  const ManageEvent({super.key});

  @override
  State<ManageEvent> createState() => _ManageEventState();
}

class _ManageEventState extends State<ManageEvent>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController eventController = TextEditingController();

  List<Map<String, dynamic>> _eventTypes = []; // Store event types

  Future<void> fetchEventTypes() async {
    try {
      final response = await supabase.from('tbl_eventtype').select();
      setState(() {
        _eventTypes = response;
      });
    } catch (e) {
      print("ERROR FETCHING EVENT TYPES: $e");
    }
  }

  Future<void> eventSubmit() async {
    try {
      String eventtype = eventController.text;
      await supabase.from('tbl_eventtype').insert({
        'eventtype_name': eventtype,
      });
      eventController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inserted")),
      );
      fetchEventTypes(); // Refresh table after adding
    } catch (e) {
      print("ERROR ADDING EVENT: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEventTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 1000),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isFormVisible = !_isFormVisible;
                    });
                  },
                  label: Text(_isFormVisible ? "Cancel" : "Add EventType"),
                  icon: Icon(_isFormVisible ? Icons.cancel : Icons.add),
                ),
              )
            ],
          ),
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: _isFormVisible
                ? Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: eventController,
                                decoration: InputDecoration(
                                  labelText: 'Event Type ',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.zero),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter an event type';
                                  }
                                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                                    return 'Only alphabetic characters allowed';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  eventSubmit();
                                }
                              },
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          const SizedBox(height: 20),
          // Display the table of event types
          SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Sl.No")),
                DataColumn(label: Text("Event Type")),
              ],
              rows: _eventTypes.asMap().entries.map((entry) {
                return DataRow(cells: [
                  DataCell(Text((entry.key + 1).toString())),
                  DataCell(Text(entry.value['eventtype_name'])),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}