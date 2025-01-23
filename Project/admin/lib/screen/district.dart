// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:admin/main.dart';

class ManageDistrict extends StatefulWidget {
  const ManageDistrict({super.key});

  @override
  State<ManageDistrict> createState() => _ManageDistrictState();
}

class _ManageDistrictState extends State<ManageDistrict>
    with SingleTickerProviderStateMixin {
  bool _isFormVisible = false; // To manage form visibility
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController distController = TextEditingController();
  List<Map<String, dynamic>> _dist = [];
  int _editid = 0;

  Future<void> distSubmit() async {
    try {
      String district = distController.text;

      await supabase.from('tbl_district').insert({
        'dist_name': district,
      });
      fetchData();
      distController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
      ));
    } catch (e) {
      print("ERROR ADDING DISTRICT: $e");
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() {
        _dist = response;
      });
    } catch (e) {
      print('ERROR SELECTING DISTRICT:$e');
    }
  }

  void delete(int distid) async {
    try {
      await supabase.from("tbl_district").delete().eq('id', distid);
      fetchData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
      ));
    } catch (e) {
      print("ERROR:$e");
    }
  }

  void update() async {
    try {
      await supabase
          .from("tbl_district")
          .update({"dist_name": distController.text}).eq('id', _editid);
      distController.clear();
      _editid = 0;
      fetchData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Updated"),
      ));
    } catch (e) {
      print("ERROR:$e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
                padding: const EdgeInsets.only(left: 1100),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isFormVisible =
                          !_isFormVisible; // Toggle form visibility
                    });
                  },
                  label: Text(_isFormVisible ? "Cancel" : "Add district"),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 8.0), // Add margin around the form
                          padding: const EdgeInsets.all(
                              16.0), // Add padding inside the container
                          decoration: BoxDecoration(
                            color:
                                Colors.white, // Background color for the form
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26, // Shadow color
                                offset: Offset(0, 4), // Offset of the shadow
                                blurRadius: 8.0, // Blur radius
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: distController,
                                  decoration: InputDecoration(
                                    labelText: 'District Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          8.0), // Rounded borders for input field
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                        horizontal:
                                            16.0), // Padding inside the input
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      16.0), // Add spacing between input and button
                              ElevatedButton(
                                onPressed: () {
                                  if (_editid != 0) {
                                    update();
                                    _isFormVisible = false;
                                  } else {
                                    distSubmit();
                                    _isFormVisible = false;
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue, // Button color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Rounded corners for button
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14.0,
                                      horizontal: 20.0), // Button padding
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          Container(
            margin: const EdgeInsets.all(16.0), // Add margin for spacing
            padding:
                const EdgeInsets.all(8.0), // Add padding inside the container
            decoration: BoxDecoration(
              color: Colors.white, // Background color of the container
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black26, // Shadow color
                  offset: Offset(
                      0, 4), // Horizontal and vertical offset of the shadow
                  blurRadius: 8.0, // Blur radius of the shadow
                ),
              ],
            ),
            child: DataTable(
              columns: [
                DataColumn(label: Text("Sl.No")),
                DataColumn(label: Text("District")),
                DataColumn(label: Text("Delete")),
                DataColumn(label: Text("Edit")),
              ],
              rows: _dist.asMap().entries.map((entry) {
                return DataRow(cells: [
                  DataCell(Text((entry.key + 1).toString())), // Serial number
                  DataCell(Text(entry.value['dist_name'])),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        delete(entry.value['id']);
                      },
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        _editid = entry.value['id'];
                        distController.text = entry.value['dist_name'];
                        _isFormVisible = true;
                      },
                    ),
                  ),
                ]);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
