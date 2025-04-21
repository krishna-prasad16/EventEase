import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login.dart'; // Ensure this import is correct based on your project structure

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  List<Map<String,dynamic>> distList= [];
  List<Map<String,dynamic>> placeList= [];

  String? _selectedDistrict;
  String? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _fetchDistricts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fetch districts from Supabase
  Future<void> _fetchDistricts() async {
    try {
      final response = await supabase.from('tbl_district').select();
      List<Map<String,dynamic>> dist= [];
      for(var data in response){
        dist.add({
          'id':data['id'].toString(),
          'name':data['dist_name']
        });
      }
      print("Districts: $dist");
      setState(() {
       distList=dist;
      });
    } catch (e) {
      print("Error fetching districts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching districts: $e')),
      );
    }
  }

  // Fetch places from Supabase
  Future<void> _fetchPlaces(String id) async {
    try {
      final response = await supabase.from('tbl_place').select().eq('dist_id', id);
      List<Map<String,dynamic>> plc= [];
      for(var data in response){
        plc.add({
          'id':data['place_id'].toString(),
          'name':data['place_name']
        });
      }
      setState(() {
        placeList=plc;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching places: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_selectedImage == null) return null;

    try {
      final String fileName =
          '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('user').upload(fileName, _selectedImage!);

      final String imageUrl =
          supabase.storage.from('userf').getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;
      if (user != null) {
        final String? imageUrl = await _uploadImage(user.id);

        await supabase.from('tbl_user').insert({
          'user_name': _nameController.text.trim(),
          'user_email': _emailController.text.trim(),
          'user_photo': imageUrl,
          'user_password': _passwordController.text.trim(),
          'place_id': _selectedPlace,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF), // pastel blue background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20.0),
                  const Text(
                    "Meredith",
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C355E),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C355E),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: SizedBox(
                            height: 120,
                            width: 120,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                // backgroundImage: _selectedImage != null
                                //     ? FileImage(_selectedImage!,)
                                //     : null,
                                child: _selectedImage == null
                                    ? const Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: Color(0xFFB1C4D6),
                                      )
                                    : Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        _buildInput(_nameController, Icons.person, "Your Name"),
                        const SizedBox(height: 16.0),
                        _buildInput(_emailController, Icons.email, "Your Email",
                            isEmail: true),
                        const SizedBox(height: 16.0),
                        _buildDropdown(
                          hint: "Select District",
                          icon: Icons.location_city,
                          items: distList,
                          value: _selectedDistrict,
                          onChanged: (value) {
                            _fetchPlaces(value!);
                            setState(() {
                              _selectedDistrict = value;
                              _selectedPlace = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        _buildDropdown(
                          hint: "Select Place",
                          icon: Icons.place,
                          items: placeList,
                          value: _selectedPlace,
                          onChanged: (value) {
                            setState(() {
                              _selectedPlace = value;
                            });
                          },
                        ),
                        //  DropdownButtonFormField<District>(
                        //     decoration: InputDecoration(
                        //       hintText: "Select District",
                        //       prefixIcon: const Icon(Icons.location_city),
                        //       filled: true,
                        //       fillColor: Colors.white,
                        //       border: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(12.0),
                        //         borderSide: BorderSide.none,
                        //       ),
                        //     ),
                        //     items: _districts.map((District district) {
                        //       return DropdownMenuItem<District>(
                        //         value: district,
                        //         child: Text(district.name),
                        //       );
                        //     }).toList(),
                        //     onChanged: (District? newValue) {
                        //       setState(() {
                        //         _selectedDistrict = newValue;
                        //         _selectedPlace = null; // Reset place when district changes
                        //       });
                        //     },
                        //     value: _selectedDistrict,
                        //     validator: (value) {
                        //       if (value == null) {
                        //         return "Please select a district";
                        //       }
                        //       return null;
                        //     },
                        //   ),
                        // const SizedBox(height: 16.0),
                        //  DropdownButtonFormField<Place>(
                        //   decoration: InputDecoration(
                        //     hintText: "Select Place",
                        //     prefixIcon: const Icon(Icons.place),
                        //     filled: true,
                        //     fillColor: Colors.white,
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(12.0),
                        //       borderSide: BorderSide.none,
                        //     ),
                        //   ),
                        //   items: _places.map((Place place) {
                        //     return DropdownMenuItem<Place>(
                        //       value: place,
                        //       child: Text(place.name),
                        //     );
                        //   }).toList(),
                        //   onChanged: (Place? newValue) {
                        //     setState(() {
                        //       _selectedPlace = newValue;
                        //     });
                        //   },
                        //   value: _selectedPlace,
                        //   validator: (value) {
                        //     if (value == null) {
                        //       return "Please select a place";
                        //     }
                        //     return null;
                        //   },
                        // ),

                        const SizedBox(height: 16.0),
                        _buildInput(_passwordController, Icons.lock, "Password",
                            isPassword: true),
                        const SizedBox(height: 16.0),
                        _buildInput(_confirmPasswordController,
                            Icons.lock_outline, "Confirm Password",
                            isPassword: true),
                        const SizedBox(height: 24.0),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFD2B48C), // light brown
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shadowColor: Colors.black.withOpacity(0.1),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.white),
                                ),
                        ),
                        const SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                            );
                          },
                          child: const Text(
                            "Already have an account? Sign In",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF7D8CA2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildInput(TextEditingController controller, IconData icon, String hint,
    {bool isPassword = false, bool isEmail = false}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Color(0xFFB1C4D6)),
      filled: true,
      fillColor: const Color(0xFFF3F6FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
    ),
    obscureText: isPassword,
    keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Please enter ${hint.toLowerCase()}";
      }
      if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
        return "Please enter a valid email address";
      }
      return null;
    },
  );
}

Widget _buildDropdown<T>({
  required String hint,
  required IconData icon,
  required List<Map<String,dynamic>> items,
  required T? value,
  required Function(T?) onChanged,
}) {
  return DropdownButtonFormField(
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Color(0xFFB1C4D6)),
      filled: true,
      fillColor: const Color(0xFFF3F6FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
    ),
    items: items.map((item) {
      return DropdownMenuItem<T>(
        value: item['id'],
        child: Text(item['name']),
      );
    }).toList(),
    onChanged: onChanged,
    value: value,
    validator: (value) {
      if (value == null) {
        return "Please select ${hint.toLowerCase()}";
      }
      return null;
    },
  );
}
