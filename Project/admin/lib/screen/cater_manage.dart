import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class CaterManage extends StatefulWidget {
  CaterManage({super.key});

  @override
  State<CaterManage> createState() => _CaterManageState();
}

class _CaterManageState extends State<CaterManage> {
  List<Map<String, dynamic>> _cat = [];
  List<Map<String, dynamic>> _accepted = [];
  List<Map<String, dynamic>> _rejected = [];

  // Fetch data for pending catering
  Future<void> fetchData() async {
    try {
      final response = await supabase.from('tbl_catering').select();

      setState(() {
        // Clear all lists before updating
        _cat.clear();
        _accepted.clear();
        _rejected.clear();

        // Categorize data based on `dec_status`
        for (var entry in response) {
          if (entry['cat_status'] == 0) {
            _cat.add(entry); // Pending
          } else if (entry['cat_status'] == 1) {
            _accepted.add(entry); // Accepted
          } else if (entry['cat_status'] == 2) {
            _rejected.add(entry); // Rejected
          }
        }
      });
    } catch (e) {
      print('ERROR FETCHING DATA: $e');
    }
  }

  Future<void> accept(String id) async {
    try {
      await supabase.from('tbl_catering').update({
        'cat_status': 1
      }).eq('id', id);

      // Move the accepted entry to the _accepted list
      setState(() {
        final entry = _cat.firstWhere((element) => element['id'] == id);
        _cat.remove(entry);
        _accepted.add(entry);
      });
    } catch (e) {
      print("Error : $e");
    }
  }

  Future<void> reject(String id) async {
    try {
      await supabase.from('tbl_catering').update({
        'cat_status': 2
      }).eq('id', id);

      // Move the rejected entry to the _rejected list
      setState(() {
        final entry = _cat.firstWhere((element) => element['id'] == id);
        _cat.remove(entry);
        _rejected.add(entry);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void showImage(String image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    image,
                    height: 500,
                    width: 600,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTable(String title, List<Map<String, dynamic>> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          DataTable(
            columns: [
              DataColumn(label: Text("Sl.No")),
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Email")),
              DataColumn(label: Text("Contact")),
              DataColumn(label: Text("Address")),
              DataColumn(label: Text("Proof")),
              DataColumn(label: Text("Photo")),
              if (title == "Pending Catering") DataColumn(label: Text("Accept")),
              if (title == "Pending Catering") DataColumn(label: Text("Reject")),
            ],
            rows: data.asMap().entries.map((entry) {
              final cells = [
                DataCell(Text((entry.key + 1).toString())),
                DataCell(Text(entry.value['cat_name'])),
                DataCell(Text(entry.value['cat_email'])),
                DataCell(Text(entry.value['cat_contact'])),
                DataCell(Text(entry.value['cat_address'])),
                DataCell(
                  onTap: () {
                    showImage(entry.value['cat_proof']);
                  },
                  CircleAvatar(
                      backgroundImage: NetworkImage(entry.value['cat_proof'])),
                ),
                DataCell(
                  onTap: () {
                    showImage(entry.value['cat_img']);
                  },
                  CircleAvatar(
                      backgroundImage: NetworkImage(entry.value['cat_img'])),
                ),
              ];

              if (title == "Pending Catering") {
                cells.add(
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.check,
                          color: Color.fromARGB(255, 77, 39, 190)),
                      onPressed: () {
                        accept(entry.value['id']);
                      },
                    ),
                  ),
                );
                cells.add(
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.close_outlined,
                          color: Color.fromARGB(255, 59, 69, 252)),
                      onPressed: () {
                        reject(entry.value['id']);
                      },
                    ),
                  ),
                );
              }

              return DataRow(cells: cells);
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildTable("Pending Catering", _cat),
          buildTable("Accepted catering", _accepted),
          buildTable("Rejected catering", _rejected),
        ],
      ),
    );
  }
}
