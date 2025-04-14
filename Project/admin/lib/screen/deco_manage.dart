import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class DecoManage extends StatefulWidget {
  DecoManage({super.key});

  @override
  State<DecoManage> createState() => _DecoManageState();
}

class _DecoManageState extends State<DecoManage> {
  List<Map<String, dynamic>> _dec = [];
  List<Map<String, dynamic>> _accepted = [];
  List<Map<String, dynamic>> _rejected = [];

  // Fetch data for pending decorators
  Future<void> fetchData() async {
    try {
      final response = await supabase.from('tbl_decorators').select();

      setState(() {
        // Clear all lists before updating
        _dec.clear();
        _accepted.clear();
        _rejected.clear();

        // Categorize data based on `dec_status`
        for (var entry in response) {
          if (entry['dec_status'] == 0) {
            _dec.add(entry); // Pending
          } else if (entry['dec_status'] == 1) {
            _accepted.add(entry); // Accepted
          } else if (entry['dec_status'] == 2) {
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
      await supabase.from('tbl_decorators').update({
        'dec_status': 1
      }).eq('id', id);

      // Move the accepted entry to the _accepted list
      setState(() {
        final entry = _dec.firstWhere((element) => element['id'] == id);
        _dec.remove(entry);
        _accepted.add(entry);
      });
    } catch (e) {
      print("Error : $e");
    }
  }

  Future<void> reject(String id) async {
    try {
      await supabase.from('tbl_decorators').update({
        'dec_status': 2
      }).eq('id', id);

      // Move the rejected entry to the _rejected list
      setState(() {
        final entry = _dec.firstWhere((element) => element['id'] == id);
        _dec.remove(entry);
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
              if (title == "Pending Decorators") DataColumn(label: Text("Accept")),
              if (title == "Pending Decorators") DataColumn(label: Text("Reject")),
            ],
            rows: data.asMap().entries.map((entry) {
              return DataRow(cells: [
                DataCell(Text((entry.key + 1).toString())),
                DataCell(Text(entry.value['dec_name'])),
                DataCell(Text(entry.value['dec_email'])),
                DataCell(Text(entry.value['dec_contact'])),
                DataCell(Text(entry.value['dec_address'])),
                DataCell(
                  CircleAvatar(
                      backgroundImage: NetworkImage(entry.value['dec_proof'])),
                ),
                DataCell(
                  CircleAvatar(
                      backgroundImage: NetworkImage(entry.value['dec_img'])),
                ),
                if (title == "Pending Decorators")
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.check,
                          color: Color.fromARGB(255, 77, 39, 190)),
                      onPressed: () {
                        accept(entry.value['id']);
                      },
                    ),
                  ),
                if (title == "Pending Decorators")
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.close_outlined,
                          color: Color.fromARGB(255, 59, 69, 252)),
                      onPressed: () {
                        reject(entry.value['id']);
                      },
                    ),
                  ),
              ]);
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
          buildTable("Pending Decorators", _dec),
          buildTable("Accepted Decorators", _accepted),
          buildTable("Rejected Decorators", _rejected),
        ],
      ),
    );
  }
}
