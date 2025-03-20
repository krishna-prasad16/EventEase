import 'package:decorators/decorators/screens/mydecoration.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewDecoration extends StatefulWidget {
  const ViewDecoration({super.key});

  @override
  State<ViewDecoration> createState() => _ViewDecorationState();
}

class _ViewDecorationState extends State<ViewDecoration> {
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
          await Supabase.instance.client.from('tbl_decorations').select();
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

  Future<void> _deleteProduct(int productId) async {
    try {
      await Supabase.instance.client
          .from('tbl_decorations')
          .delete()
          .eq('id', productId);
      _fetchProducts(); // Refresh after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("deleted successfully!"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("Error deleting product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting product: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 4,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 270,
                    height: 60,
                  ),
                  Row(
                    children: [
                      TextButton(onPressed: () {}, child: const Text("Home")),
                      TextButton(
                          onPressed: () {}, child: const Text("My Booking")),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Mydecoration()),
                          );
                        },
                        child: const Text("My Decorations"),
                      ),
                      TextButton(
                          onPressed: () {}, child: const Text("Profile")),
                      TextButton(onPressed: () {}, child: const Text("Logout")),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("No products available"))
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Mydecoration(),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                        child: Image.network(
                                          product['decoration_image'] ??
                                              'https://via.placeholder.com/150',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 50),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['decoration_title'] ??
                                                "No Name",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            product['decoration_description'] ??
                                                "No Description",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            "\$${product['decoration_budget'] ?? '0.00'}",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () async {
                                                  bool? confirmDelete =
                                                      await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            "Confirm Delete"),
                                                        content: const Text(
                                                            "Are you sure you want to delete this product?"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    false),
                                                            child: const Text(
                                                                "No"),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    true),
                                                            child: const Text(
                                                                "Yes"),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );

                                                  if (confirmDelete == true) {
                                                    _deleteProduct(
                                                        product['id']);
                                                  }
                                                },
                                              ),
                                            ],
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
                      ],
                    ),
                  ),
                ),
    );
  }
}
