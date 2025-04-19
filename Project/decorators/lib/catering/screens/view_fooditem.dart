import 'package:decorators/catering/widgets/custom_catering_appbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewFood extends StatefulWidget {
  const ViewFood({super.key});

  @override
  State<ViewFood> createState() => _ViewFoodState();
}

class _ViewFoodState extends State<ViewFood> {
  List<dynamic> foodItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Supabase.instance.client
          .from('tbl_food')
          .select('food_name, food_amount, food_image, food_type')
          .order('food_name', ascending: true);
      setState(() {
        foodItems = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching food items: $e')),
      );
    }
  }

  Future<void> deleteFoodItem(String foodName) async {
    try {
      await Supabase.instance.client
          .from('tbl_food')
          .delete()
          .eq('food_name', foodName);
      setState(() {
        foodItems.removeWhere((item) => item['food_name'] == foodName);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting food item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomCateringAppBar(isScrolled: false),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : foodItems.isEmpty
              ? const Center(child: Text('No food items found.'))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    itemCount: foodItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final food = foodItems[index];
                      return Stack(
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: food['food_image'] != null
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                          child: Image.network(
                                            food['food_image'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image, size: 60),
                                          ),
                                        )
                                      : const Icon(Icons.fastfood, size: 60),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food['food_name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Type: ${food['food_type'] ?? ''}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Amount: ₹${food['food_amount'] ?? ''}',
                                        style: const TextStyle(fontSize: 14, color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Food Item'),
                                    content: const Text('Are you sure you want to delete this food item?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await deleteFoodItem(food['food_name']);
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}