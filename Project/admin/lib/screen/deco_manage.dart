import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class DecoManage extends StatefulWidget {
  DecoManage({super.key});

  @override
  State<DecoManage> createState() => _DecoManageState();
}

class _DecoManageState extends State<DecoManage> {
  List<Map<String, dynamic>> _dec = [];

  //display
  Future<void> fetchData() async {
    try {
      final response = await supabase.from('tbl_decorators').select();
      setState(() {
        _dec = response;
      });
    } catch (e) {
      print('ERROR SELECTING DISTRICT:$e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0), // Add margin for spacing
      padding: const EdgeInsets.all(8.0), // Add padding inside the container
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the container
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // Shadow color
            offset:
                Offset(0, 4), // Horizontal and vertical offset of the shadow
            blurRadius: 8.0, // Blur radius of the shadow
          ),
        ],
      ),
      child: DataTable(
        columns: [
          DataColumn(label: Text("Sl.No")),
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Email")),
          DataColumn(label: Text("Contact")),
          DataColumn(label: Text("Address")),
          DataColumn(label: Text("proof")),
          DataColumn(label: Text("Photo")),
          DataColumn(label: Text("Accept")),
          DataColumn(label: Text("Reject")),
        ],
        rows: _dec.asMap().entries.map((entry) {
          return DataRow(cells: [
            DataCell(Text((entry.key + 1).toString())), // Serial number
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

            DataCell(
              IconButton(
                icon:
                    Icon(Icons.check, color: Color.fromARGB(255, 77, 39, 190)),
                onPressed: () {},
              ),
            ),
            DataCell(
              IconButton(
                icon: const Icon(Icons.close_outlined,
                    color: Color.fromARGB(255, 59, 69, 252)),
                onPressed: () {},
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}
