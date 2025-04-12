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
      backgroundColor: const Color(0xFFE3EAFB),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40.0),
                const Text(
                  "Meredith",
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A4D8F),
                  ),
                ),
                const SizedBox(height: 32.0),
                const Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3A4D8F),
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
                            color: Colors.white,
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Color(0xFF3A4D8F),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "Your Name",
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Your Email",
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // District Dropdown
                      DropdownButtonFormField<District>(
                        decoration: InputDecoration(
                          hintText: "Select District",
                          prefixIcon: const Icon(Icons.location_city),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _districts.map((District district) {
                          return DropdownMenuItem<District>(
                            value: district,
                            child: Text(district.name),
                          );
                        }).toList(),
                        onChanged: (District? newValue) {
                          setState(() {
                            _selectedDistrict = newValue;
                            _selectedPlace = null; // Reset place when district changes
                          });
                        },
                        value: _selectedDistrict,
                        validator: (value) {
                          if (value == null) {
                            return "Please select a district";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Place Dropdown
                      DropdownButtonFormField<Place>(
                        decoration: InputDecoration(
                          hintText: "Select Place",
                          prefixIcon: const Icon(Icons.place),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _places.map((Place place) {
                          return DropdownMenuItem<Place>(
                            value: place,
                            child: Text(place.name),
                          );
                        }).toList(),
                        onChanged: (Place? newValue) {
                          setState(() {
                            _selectedPlace = newValue;
                          });
                        },
                        value: _selectedPlace,
                        validator: (value) {
                          if (value == null) {
                            return "Please select a place";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters long";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm your password";
                          }
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: const Color(0xFF3A4D8F),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Sign Up",
                                style: TextStyle(fontSize: 16.0),
                              ),
                      ),
                      const SizedBox(height: 16.0),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                          );
                        },
                        child: const Text(
                          "Already have an account? Sign In",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF3A4D8F),
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
    );
  }
}