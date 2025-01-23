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
  int _editid =0;

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

void update() async{
  try{
    await supabase.from("tbl_district").update({
      "dist_name":distController.text
    }).eq('id',_editid);
    distController.clear();
    _editid=0;
     fetchData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Updated"),
      ));
  }
  catch(e){
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
                    children: [
                      //F,orms
                      Form(
                          child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                                controller: distController,
                                decoration: InputDecoration(
                                  labelText: 'District Name',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.zero),
                                )),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                if(_editid !=0)
                                {
                                  update();
                                  _isFormVisible=false;
                                }
                                else
                                {
                                distSubmit();
                                _isFormVisible=false;
                                }
                              },
                              child: Text('Submit'))
                        ],
                      )),
                    ],
                  ))
                : Container(),
          ),
          DataTable(
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

                DataCell(IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {
                    _editid=entry.value['id'];
                    distController.text=entry.value['dist_name'];
                    _isFormVisible=true;
                  },
                )),
              ]);
            }).toList(),
          )
        ],
      ),
    );
  }
}
