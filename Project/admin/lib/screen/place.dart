import 'package:admin/main.dart';
import 'package:flutter/material.dart';


class Manageplace extends StatefulWidget {
  const Manageplace({super.key});

  @override
  State<Manageplace> createState() => _ManageplaceState();
}

class _ManageplaceState extends State<Manageplace>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isFormVisible = false; // To manage form visibility
  String? selectedDist;
  List<Map<String, dynamic>> districtList = [];
  List<Map<String, dynamic>> placeList = []; // <-- Add this
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController placeController = TextEditingController();

  Future<void> place() async {
    try {
      String place = placeController.text;
      await supabase.from('tbl_place').insert({
        'place_name': place,
        'dist_id': selectedDist,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'place added',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      print("Inserted");
      placeController.clear();
      fetchPlaces(); // Refresh table after adding
    } catch (e) {
      print("Error adding place:$e");
    }
  }

  Future<void> fetchDist() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() {
        districtList = response;
      });
      fetchPlaces(); // Fetch places after districts are loaded
    } catch (e) {}
  }

  Future<void> fetchPlaces() async {
    try {
      final response = await supabase.from('tbl_place').select();
      // Map district id to name for easy lookup
      final distMap = {for (var d in districtList) d['id'].toString(): d['dist_name']};
      setState(() {
        placeList = response.map<Map<String, dynamic>>((place) {
          return {
            'place_name': place['place_name'],
            'district_name': distMap[place['dist_id'].toString()] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching places:$e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDist();
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
              const Text("Manage Place"),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isFormVisible = !_isFormVisible; // Toggle form visibility
                  });
                },
                label: Text(_isFormVisible ? "Cancel" : "Add place"),
                icon: Icon(_isFormVisible ? Icons.cancel : Icons.add),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Place Form",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedDist,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedDist = newValue!;
                                  });
                                },
                                items: districtList.map((district) {
                                  return DropdownMenuItem<String>(
                                    value: district['id'].toString(),
                                    child: Text(district['dist_name']),
                                  );
                                }).toList(),
                                decoration: const InputDecoration(
                                  labelText: "District",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a district';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: placeController,
                                decoration: const InputDecoration(
                                  labelText: "Place Name",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a place name';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'Place name must be at least 3 characters';
                                  }
                                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                                    return 'Only alphabetic characters allowed';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  place();
                                }
                              },
                              child: const Text("Add"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          const SizedBox(height: 20),
          // Display the table of places and districts
          SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Sl.No")),
                DataColumn(label: Text("Place Name")),
                DataColumn(label: Text("District Name")),
              ],
              rows: placeList.asMap().entries.map((entry) {
                return DataRow(cells: [
                  DataCell(Text((entry.key + 1).toString())),
                  DataCell(Text(entry.value['place_name'])),
                  DataCell(Text(entry.value['district_name'])),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}