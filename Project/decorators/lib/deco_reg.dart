import 'dart:io';
import 'dart:typed_data';

import 'package:decorators/main.dart';
import 'package:decorators/index.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Decoreg extends StatefulWidget {
  const Decoreg({super.key});

  @override
  State<Decoreg> createState() => _DecoregState();
}

class _DecoregState extends State<Decoreg> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _adrsController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _proofController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  PlatformFile? pickedImage;
  PlatformFile? pickedFile;

  final _formKey = GlobalKey<FormState>();
  Future<void> register() async {
    try {
      final auth = await supabase.auth.signUp(
          password: _passwordController.text, email: _emailController.text);
      final uid = auth.user!.id;
      if (uid.isNotEmpty || uid != "") {
        insert(uid);
      }
    } catch (e) {
      print("ERROR $e");
    }
  }

  void insert(final id) async {
    try {
      String name = _nameController.text;
      String email = _emailController.text;
      String contact = _contactController.text;
      String address = _adrsController.text;
      String password = _passwordController.text;
      String? url = await photoUpload(id, pickedImage!);
      String? proof = await photoUpload(id, pickedFile!);
      if (url!.isNotEmpty) {
        await supabase.from('tbl_decorators').insert({
          'id': id,
          'dec_name': name,
          'dec_email': email,
          'dec_contact': contact,
          'dec_address': address,
          'dec_password': password,
          'dec_img': url,
          'dec_proof': proof,
          'place_id': selectedPlace
        });
      }
      _nameController.clear();
      _emailController.clear();
      _contactController.clear();
      _adrsController.clear();
      _passwordController.clear();
      _proofController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registration Successfull"),
      ));
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Index(),
          ));
      print("Registration Successfull");
    } catch (e) {
      print('ERROR:$e');
    }
  }

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Only single file upload
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<String?> photoUpload(String uid, PlatformFile file) async {
    try {
      final bucketName = 'decorator'; // Replace with your bucket name
      final filePath = "$uid-${file.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<void> handleFilePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Only single file upload
    );
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
        _proofController.text = result.files.first.name;
      });
    }
  }

  List<Map<String, dynamic>> _distList = [];
  List<Map<String, dynamic>> _placeList = [];

  String? selectedPlace;
  String? selectedDist;

  Future<void> fetchDist() async {
    try {
      final response = await supabase.from('tbl_district').select();
      if (response.isNotEmpty) {
        print(response);
        setState(() {
          _distList = response;
        });
      }
    } catch (e) {
      print("Error fetching districts: $e");
    }
  }

  Future<void> fetchPlace(String? id) async {
    try {
      final response =
          await supabase.from('tbl_place').select().eq('dist_id', id!);
      // print(response);
      setState(() {
        _placeList = response;
      });
    } catch (e) {
      print("ERROR FETCHING DISTRICT DATA: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EBE6), // pastel background
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 4,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "Decorator Registration",
                    style: GoogleFonts.lato(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image Picker
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: pickedImage == null
                        ? GestureDetector(
                            onTap: handleImagePick,
                            child: const Icon(
                              Icons.add_a_photo,
                              color: Color(0xFF0277BD),
                              size: 50,
                            ),
                          )
                        : GestureDetector(
                            onTap: handleImagePick,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: pickedImage!.bytes != null
                                  ? Image.memory(
                                      Uint8List.fromList(pickedImage!.bytes!),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(pickedImage!.path!),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: inputDecoration("Your Name", Icons.person),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter your name" : null,
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: inputDecoration("Your Email", Icons.email),
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
                  const SizedBox(height: 16),

                  // Address Field
                  TextFormField(
                    controller: _adrsController,
                    decoration: inputDecoration("Your Address", Icons.home),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter your address" : null,
                  ),
                  const SizedBox(height: 16),

                  // Contact Field
                  TextFormField(
                    controller: _contactController,
                    decoration:
                        inputDecoration("Your Phone Number", Icons.phone),
                    validator: (value) => value!.isEmpty
                        ? "Please enter your phone number"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // District & Place Dropdowns
                  // District Dropdown
                  // District Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedDist,
                    hint: const Text("Select District"),
                    decoration: dropdownDecoration().copyWith(
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        selectedDist = newValue;
                      });
                      fetchPlace(newValue);
                    },
                    items: _distList.map((district) {
                      return DropdownMenuItem<String>(
                        value: district['id'].toString(),
                        child: Text(district['dist_name']),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

// Place Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedPlace,
                    hint: const Text("Select Place"),
                    decoration: dropdownDecoration().copyWith(
                      prefixIcon: const Icon(Icons.place),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        selectedPlace = newValue;
                      });
                    },
                    items: _placeList.map((place) {
                      return DropdownMenuItem<String>(
                        value: place['place_id'].toString(),
                        child: Text(place['place_name']),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Proof Field
                  TextFormField(
                    readOnly: true,
                    controller: _proofController,
                    onTap: handleFilePick,
                    decoration: inputDecoration("Proof", Icons.file_copy),
                    validator: (value) =>
                        value!.isEmpty ? "Please upload proof" : null,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: inputDecoration("Password", Icons.lock),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration:
                        inputDecoration("Confirm Password", Icons.lock_outline),
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
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        register();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF7DBE9D), // pastel green
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        "Submit",
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration inputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: Colors.grey[700]),
    filled: true,
    fillColor: const Color(0xFFFDFDFD),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}

InputDecoration dropdownDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: const Color(0xFFFDFDFD),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}
