import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/Screens/more_decorations.dart';
import 'package:user/Screens/sendrqst.dart';

class Decodetails extends StatefulWidget {
  final Map<String, dynamic> decoration;
 
  const Decodetails({super.key, required this.decoration});

  @override
  State<Decodetails> createState() => _DecodetailsState();
}

class _DecodetailsState extends State<Decodetails> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.decoration['decoration_title'] ?? "Decoration Details",
          style: GoogleFonts.cormorantGaramond(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 204, 209, 208),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.decoration['decoration_image'] ?? 'https://via.placeholder.com/300',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image, size: 100));
                },
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.decoration['decoration_title'] ?? "No Name",
              style: GoogleFonts.cormorantGaramond(fontSize: 26),
            ),
            const SizedBox(height: 10),

            Text(
              "Description:",
              style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.decoration['decoration_description'] ?? 'No description available',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            Text(
              "Price: \$${widget.decoration['decoration_budget'] ?? '0.00'}",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 20),

            Text(
              "Decorator Details:",
              style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Name: ${widget.decoration['tbl_decorators']['dec_name']}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Email: ${widget.decoration['tbl_decorators']['dec_email']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SendRequest(id: widget.decoration['id']),));
            }, child: Text('Send Request')),
            ElevatedButton(onPressed: (){
              
              Navigator.push(context, MaterialPageRoute(builder: (context) => MoreDecorations(id: widget.decoration['decorator_id']),));
            }, child: Text('View More')),
          ],
        ),
      ),
    );
  }
}
