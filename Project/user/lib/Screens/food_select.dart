import 'package:flutter/material.dart';
import 'package:user/Screens/catrequest.dart';
import 'package:user/main.dart';

class FoodSelect extends StatefulWidget {
  final String catId;
  const FoodSelect({super.key, required this.catId});

  @override
  State<FoodSelect> createState() => _FoodSelectState();
}

class _FoodSelectState extends State<FoodSelect> {
  List<Map<String, dynamic>> foodList = [];
  List<Map<String, dynamic>> filteredFoodList = [];
  List<int> selectedFoodIds = []; // Store selected food IDs
  bool isLoading = true;
  String? errorMessage;
  TextEditingController searchController = TextEditingController();
  String filterType = 'All'; // All, Veg, Non-Veg

  @override
  void initState() {
    super.initState();
    fetchFoodList();
    searchController.addListener(_filterFoods);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchFoodList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await supabase
          .from('tbl_food')
          .select('id, food_name, food_amount, food_image, food_type')
          .eq('cat_id', widget.catId);
      setState(() {
        foodList = response;
        filteredFoodList = response;
        isLoading = false;
      });
      _filterFoods();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching food list: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching food: $e')),
        );
      }
    }
  }

  void _filterFoods() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredFoodList = foodList.where((food) {
        final name = food['food_name']?.toLowerCase() ?? '';
        final type =
            food['food_type']?.toUpperCase() == 'VEG' ? 'Veg' : 'Non-Veg';
        bool matchesSearch = name.contains(query);
        bool matchesType = filterType == 'All' ||
            (filterType == 'Veg' && type == 'Veg') ||
            (filterType == 'Non-Veg' && type == 'Non-Veg');
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  void _toggleFoodSelection(int foodId, [int? amount]) {
    setState(() {
      if (selectedFoodIds.contains(foodId)) {
        selectedFoodIds.remove(foodId);
      } else {
        selectedFoodIds.add(foodId);
      }
    });
  }

  double _calculateTotal() {
    return filteredFoodList
        .where((food) => selectedFoodIds.contains(
            food['id'] is int ? food['id'] : int.tryParse(food['id'].toString()) ?? 0))
        .fold(
            0.0, (sum, food) => sum + (food['food_amount'] as num).toDouble());
  }

  void _proceed() {
    if (selectedFoodIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one food item')),
      );
      return;
    }
    // For now, show selected IDs; extend as needed
   Navigator.push(context, MaterialPageRoute(builder: (context) => Catrequest(food: selectedFoodIds,catId: widget.catId,),));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Food',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Brown
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF8D6E63)), // Lighter brown
            onPressed: fetchFoodList,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchFoodList,
              color: const Color(0xFF8D6E63), // Lighter brown
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF8D6E63)),
                      ),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: fetchFoodList,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6D4C41),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Search Bar
                                TextFormField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search Food',
                                    prefixIcon: const Icon(Icons.search,
                                        color: Color(0xFF8D6E63)),
                                    filled: true,
                                    fillColor: const Color(0xFFF5E9E2),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  onChanged: (value) => _filterFoods(),
                                ),
                                const SizedBox(height: 16),
                                // Filter Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildFilterButton(
                                        'All', filterType == 'All'),
                                    _buildFilterButton(
                                        'Veg', filterType == 'Veg'),
                                    _buildFilterButton(
                                        'Non-Veg', filterType == 'Non-Veg'),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Food List Header
                                Text(
                                  'Available Food Items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3E2723), // Dark brown
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Food List
                                filteredFoodList.isEmpty
                                    ? Center(
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 32),
                                            Icon(
                                              Icons.restaurant_menu,
                                              size: 64,
                                              color:
                                                  Colors.grey.withOpacity(0.6),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'No food items found',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Try adjusting your search or filter',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: filteredFoodList.length,
                                        itemBuilder: (context, index) {
                                          final food = filteredFoodList[index];
                                          final foodType = food['food_type']
                                                      ?.toUpperCase() ==
                                                  'VEG'
                                              ? 'Veg'
                                              : 'Non-Veg';
                                          final isSelected = selectedFoodIds
                                              .contains(food['id']);
                                          return Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.all(12),
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  food['food_image'] ?? '',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    width: 60,
                                                    height: 60,
                                                    color:
                                                        const Color(0xFFF5E9E2),
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      color: Color(0xFF8D6E63),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                food['food_name'] ?? 'Unknown',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF3E2723),
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '₹${food['food_amount']?.toString() ?? 'N/A'}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  Text(
                                                    foodType,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: foodType == 'Veg'
                                                          ? Colors.green[600]
                                                          : Colors.red[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              trailing: ElevatedButton(
                                                onPressed: () =>
                                                    _toggleFoodSelection(
                                                        food['id'] is int ? food['id'] : int.tryParse(food['id'].toString()) ?? 0,
                                                        food['food_amount']),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isSelected
                                                      ? Color(0xFF6D4C41)
                                                      : Color(0xFF8D6E63),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                ),
                                                child: Text(
                                                  isSelected
                                                      ? 'Selected'
                                                      : 'Select',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ),
            ),
          ),
          // Total and Proceed Button
          if (filteredFoodList.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFF6D4C41),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ₹${_calculateTotal().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _proceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8D6E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Proceed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool isSelected) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              filterType = label;
              _filterFoods();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? const Color(0xFF8D6E63) : const Color(0xFFF5E9E2),
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
