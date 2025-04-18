import 'package:flutter/material.dart';
import 'package:user/Screens/food_select.dart';
import 'package:user/main.dart';

class Searchcatering extends StatefulWidget {
  const Searchcatering({super.key});

  @override
  State<Searchcatering> createState() => _SearchcateringState();
}

class _SearchcateringState extends State<Searchcatering> {
  List<Map<String, dynamic>> distList = [];
  List<Map<String, dynamic>> placeList = [];
  List<Map<String, dynamic>> caterList = [];
  List<Map<String, dynamic>> filteredCaterList = [];

  TextEditingController searchController = TextEditingController();
  String? _selectedDistrict;
  String? _selectedPlace;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDistricts();
    fetchCatering();
    searchController.addListener(_filterCatering);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCatering() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await supabase
          .from('tbl_catering')
          .select('id, cat_name, cat_img, place_id, tbl_place(place_name,dist_id,tbl_district(dist_name))')
          .eq('cat_status', 1);
      setState(() {
        caterList = response;
        filteredCaterList = response;
        isLoading = false;
      });
      _filterCatering();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching catering services: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching catering: $e')),
        );
      }
    }
  }

  Future<void> _fetchDistricts() async {
    try {
      final response = await supabase.from('tbl_district').select();
      List<Map<String, dynamic>> dist = [];
      for (var data in response) {
        dist.add({
          'id': data['id'].toString(),
          'name': data['dist_name'],
        });
      }
      setState(() {
        distList = dist;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching districts: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching districts: $e')),
        );
      }
    }
  }

  Future<void> _fetchPlaces(String id) async {
    try {
      final response = await supabase.from('tbl_place').select().eq('dist_id', id);
      List<Map<String, dynamic>> plc = [];
      for (var data in response) {
        plc.add({
          'id': data['place_id'].toString(),
          'name': data['place_name'],
        });
      }
      setState(() {
        placeList = plc;
        _selectedPlace = null; // Reset place when district changes
        _filterCatering();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching places: $e')),
        );
      }
    }
  }

  void _filterCatering() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredCaterList = caterList.where((cater) {
        final name = cater['cat_name']?.toLowerCase() ?? '';
        final placeId = cater['place_id']?.toString();
        final distId = cater['tbl_place']['dist_id']?.toString();

        bool matchesSearch = name.contains(query) ;
        bool matchesPlace = _selectedPlace == null || placeId == _selectedPlace;
        bool matchesDistrict = _selectedDistrict == null || distId == _selectedDistrict;

        return matchesSearch && matchesPlace && matchesDistrict;
      }).toList();
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Search Catering",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFF3F6FB),
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchDistricts();
          await fetchCatering();
        },
        color: const Color(0xFFB1C4D6),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB1C4D6)),
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
                          onPressed: fetchCatering,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F6FB),
                            foregroundColor: Colors.black87,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Bar
                          TextFormField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: "Search Catering",
                              prefixIcon: const Icon(Icons.search, color: Color(0xFFB1C4D6)),
                              filled: true,
                              fillColor: const Color(0xFFF3F6FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onChanged: (value) => _filterCatering(),
                          ),
                          const SizedBox(height: 16),
                          // District Dropdown
                          _buildDropdown<String>(
                            hint: "Select District",
                            icon: Icons.location_city,
                            items: distList,
                            value: _selectedDistrict,
                            onChanged: (value) {
                              setState(() {
                                _selectedDistrict = value;
                                _fetchPlaces(value!);
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Place Dropdown
                          _buildDropdown<String>(
                            hint: "Select Place",
                            icon: Icons.place,
                            items: placeList,
                            value: _selectedPlace,
                            onChanged: (value) {
                              setState(() {
                                _selectedPlace = value;
                                _filterCatering();
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          // Catering List Header
                          Text(
                            "Available Catering Services",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Catering List
                          filteredCaterList.isEmpty
                              ? Center(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 32),
                                      Icon(
                                        Icons.restaurant_menu,
                                        size: 64,
                                        color: Colors.grey.withOpacity(0.6),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "No catering services found",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Try adjusting your search or filters",
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredCaterList.length,
                                  itemBuilder: (context, index) {
                                    final data = filteredCaterList[index];
                                    return Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(12),
                                        leading: data['cat_img'] != null
                                            ? CircleAvatar(
                                                radius: 30,
                                                backgroundImage: NetworkImage(data['cat_img']),
                                              )
                                            : CircleAvatar(
                                                radius: 30,
                                                backgroundColor: const Color(0xFFF3F6FB),
                                                child: Text(
                                                  data['cat_name']?[0] ?? '?',
                                                  style: const TextStyle(
                                                    color: Color(0xFFB1C4D6),
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                        title: Text(
                                          data['cat_name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              data['tbl_place']?['place_name'] ?? 'No Place',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              data['tbl_place']?['tbl_district']?['dist_name'] ?? 'No District',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed: () {
                                            // print("Selected Catering ID: ${data['id']}");
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => FoodSelect(catId: data['id']),));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFB1C4D6),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                          ),
                                          child: const Text(
                                            'Proceed to add food',
                                            style: TextStyle(fontSize: 14),
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
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required T? value,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFB1C4D6)),
        filled: true,
        fillColor: const Color(0xFFF3F6FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item['id'] as T,
          child: Text(
            item['name'],
            style: const TextStyle(color: Colors.black87),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      value: value,
      validator: (value) {
        if (value == null && hint.contains("District")) {
          return "Please select a district";
        }
        return null; // Place is optional
      },
    );
  }
}