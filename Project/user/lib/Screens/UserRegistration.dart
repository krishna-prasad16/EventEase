import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> distList = [];
  List<Map<String, dynamic>> placeList = [];

  String? _selectedDistrict;
  String? _selectedPlace;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchDistricts();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchDistricts() async {
    try {
      final response = await supabase.from('tbl_district').select();
      List<Map<String, dynamic>> dist = [];
      for (var data in response) {
        dist.add({
          'id': data['id'].toString(),
          'name': data['dist_name']
        });
      }
      setState(() {
        distList = dist;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching districts: $e')),
      );
    }
  }

  Future<void> _fetchPlaces(String id) async {
    try {
      final response = await supabase.from('tbl_place').select().eq('dist_id', id);
      List<Map<String, dynamic>> plc = [];
      for (var data in response) {
        plc.add({
          'id': data['place_id'].toString(),
          'name': data['place_name']
        });
      }
      setState(() {
        placeList = plc;
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
      await supabase.storage.from('user').upload(fileName, _selectedImage!);

      final String imageUrl = supabase.storage.from('user').getPublicUrl(fileName);

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
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Meredith',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create Account',
                        style: GoogleFonts.lora(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A2F27),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join us today',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade50,
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _selectedImage == null
                                      ? Icon(
                                          Icons.camera_alt_outlined,
                                          size: 40,
                                          color: const Color(0xFF8D6E63),
                                        )
                                      : Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInput(_nameController, Icons.person_outline, "Your Name"),
                            const SizedBox(height: 16),
                            _buildInput(_emailController, Icons.email_outlined, "Your Email",
                                isEmail: true),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              hint: "Select District",
                              icon: Icons.location_city_outlined,
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
                            const SizedBox(height: 16),
                            _buildDropdown(
                              hint: "Select Place",
                              icon: Icons.place_outlined,
                              items: placeList,
                              value: _selectedPlace,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPlace = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildInput(_passwordController, Icons.lock_outline, "Password",
                                isPassword: true),
                            const SizedBox(height: 16),
                            _buildInput(
                              _confirmPasswordController,
                              Icons.lock_outline,
                              "Confirm Password",
                              isPassword: true,
                              passwordValue: _passwordController.text, // <-- pass the password value
                            ),
                            const SizedBox(height: 24),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6D4C41),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 100,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Sign Up',
                                        style: GoogleFonts.openSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login()),
                                );
                              },
                              child: Text(
                                'Already have an account? Sign In',
                                style: GoogleFonts.openSans(
                                  fontSize: 14,
                                  color: const Color(0xFF8D6E63),
                                  fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}

Widget _buildInput(TextEditingController controller, IconData icon, String hint,
    {bool isPassword = false, bool isEmail = false, String? passwordValue}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.openSans(
        color: Colors.grey.shade400,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF8D6E63),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
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
      if (hint == "Confirm Password" && value != passwordValue) {
        return "Passwords do not match";
      }
      return null;
    },
  );
}

Widget _buildDropdown({
  required String hint,
  required IconData icon,
  required List<Map<String, dynamic>> items,
  required String? value,
  required Function(String?) onChanged,
}) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.openSans(
        color: Colors.grey.shade400,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF8D6E63),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
    ),
    items: items.map((item) {
      return DropdownMenuItem<String>(
        value: item['id'],
        child: Text(
          item['name'],
          style: GoogleFonts.openSans(),
        ),
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