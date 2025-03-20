import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/Screens/decodetails.dart';
// import 'package:user/Screens/login.dart';

class Viewdecorations extends StatefulWidget {
  const Viewdecorations({super.key});

  @override
  State<Viewdecorations> createState() => _ViewdecorationsState();
}

class _ViewdecorationsState extends State<Viewdecorations> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response =
          await Supabase.instance.client.from('tbl_decorations').select("*, tbl_decorators(*)");
          print(response);
      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(child: Text("No products found"))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index]; // ✅ Now product is defined
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        constraints: BoxConstraints(maxWidth: 400),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 3,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  product['decoration_image'] ??
                                      'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                        child:
                                            Icon(Icons.broken_image, size: 50));
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['decoration_title'] ?? "No Name",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  // Text(
                                  //   product['decoration_description'] ??
                                  //       "No Description",
                                  //   style: const TextStyle(
                                  //       fontWeight: FontWeight.bold,
                                  //       fontSize: 16),
                                  // ),
                                  // Text(
                                  //   "\$${product['decoration_budget'] ?? '0.00'}",
                                  //   style: const TextStyle(
                                  //       color: Colors.green, fontSize: 14),
                                  // ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Decodetails(
                                                  decoration: product,
                                                )),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "View Details",
                                          style: GoogleFonts.openSans(
                                            fontSize: 14,
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(Icons.double_arrow,
                                            color: Colors.deepPurple, size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
