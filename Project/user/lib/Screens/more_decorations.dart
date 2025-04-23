import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/Screens/decodetails.dart';

class MoreDecorations extends StatefulWidget {
  final String id;
  const MoreDecorations({super.key, required this.id});

  @override
  State<MoreDecorations> createState() => _MoreDecorationsState();
}

class _MoreDecorationsState extends State<MoreDecorations> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await Supabase.instance.client
          .from('tbl_decorations')
          .select("*, tbl_decorators(*)")
          .eq("decorator_id", widget.id);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'More Decorations',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E2723),
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF8D6E63)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFF8D6E63)))
            : products.isEmpty
                ? Center(
                    child: Text(
                      "No products found",
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          constraints: BoxConstraints(maxWidth: 400),
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F6F2),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  product['decoration_image'] ?? 'https://via.placeholder.com/150',
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey.shade400,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['decoration_title'] ?? "No Name",
                                      style: GoogleFonts.lora(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Color(0xFF3E2723),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product['decoration_description'] ?? "No Description",
                                      style: GoogleFonts.openSans(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "\$${product['decoration_budget'] ?? '0.00'}",
                                      style: GoogleFonts.openSans(
                                        fontSize: 14,
                                        color: Color(0xFF81C784),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Decodetails(decoration: product),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            "View Details",
                                            style: GoogleFonts.openSans(
                                              fontSize: 14,
                                              color: Color(0xFF6D4C41),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(
                                            Icons.double_arrow,
                                            color: Color(0xFF6D4C41),
                                            size: 16,
                                          ),
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
      ),
    );
  }
}