import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login.dart'; // Ensure this import is correct based on your project structure

// Define Place and District classes for type safety
class Place {
  final String id;
  final String name;
  final String? distId;

  Place({required this.id, required this.name, this.distId});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['place_id'].toString(),
      name: json['place_name'],
      distId: json['dist_id']?.toString(),
    );
  }
}

class District {
  final String id;
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'].toString(),
      name: json['dist_name'],
    );
  }
}

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  File? _selectedImage;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  
  // Dropdown related variables
  List<District> _districts = [];
  List<Place> _places = [];
  District? _selectedDistrict;
  Place? _selectedPlace;
  
  @override
  void initState() {
    super.initState();
    _fetchDistricts();
    _fetchPlaces();
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
      setState(() {
        _districts = (response as List<dynamic>)
            .map((json) => District.fromJson(json))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching districts: $e')),
      );
    }
  }

  // Fetch places from Supabase
  Future<void> _fetchPlaces() async {
    try {
      final response = await supabase.from('tbl_place').select();
      setState(() {
        _places = (response as List<dynamic>)
            .map((json) => Place.fromJson(json))
            .toList();
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
      final String fileName = '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage
          .from('user')
          .upload(fileName, _selectedImage!);
      
      final String imageUrl = supabase.storage
          .from('userf')
          .getPublicUrl(fileName);
      
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
          'place_id': _selectedPlace?.id,
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
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF3F6FB),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _selectedImage == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Color(0xFFB1C4D6),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _buildInput(_nameController, Icons.person, "Your Name"),
                    const SizedBox(height: 16.0),
                    _buildInput(_emailController, Icons.email, "Your Email",
                        isEmail: true),
                    const SizedBox(height: 16.0),
                    _buildDropdown<District>(
                      hint: "Select District",
                      icon: Icons.location_city,
                      items: _districts,
                      value: _selectedDistrict,
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrict = value;
                          _selectedPlace = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildDropdown<Place>(
                      hint: "Select Place",
                      icon: Icons.place,
                      items: _places,
                      value: _selectedPlace,
                      onChanged: (value) {
                        setState(() {
                          _selectedPlace = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildInput(_passwordController, Icons.lock, "Password",
                        isPassword: true),
                    const SizedBox(height: 16.0),
                    _buildInput(_confirmPasswordController, Icons.lock_outline,
                        "Confirm Password",
                        isPassword: true),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD2B48C), // light brown
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shadowColor: Colors.black.withOpacity(0.1),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
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
    keyboardType:
        isEmail ? TextInputType.emailAddress : TextInputType.text,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Please enter ${hint.toLowerCase()}";
      }
      if (isEmail &&
          !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
        return "Please enter a valid email address";
      }
      return null;
    },
  );
}

Widget _buildDropdown<T>({
  required String hint,
  required IconData icon,
  required List<T> items,
  required T? value,
  required Function(T?) onChanged,
}) {
  return DropdownButtonFormField<T>(
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
    items: items.map((T item) {
      return DropdownMenuItem<T>(
        value: item,
        child: Text(item.toString()),
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
