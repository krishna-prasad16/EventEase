import 'dart:io';
import 'package:decorators/catering/widgets/custom_catering_appbar.dart';
import 'package:decorators/decorators/widgets/custom_dec_appbar.dart';
import 'package:decorators/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic> userData = {};
  bool isUpdating = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      String? url = await uploadImage();
      if (url != null) {
        await updateImage(url);
        await display();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated!')),
        );
      }
    }
  }

  Future<void> updateImage(String? url) async {
    try {
      String uid = supabase.auth.currentUser!.id;
      await supabase.from('tbl_decorators').update({'dec_img': url}).eq("id", uid);
    } catch (e) {
      print("Image updation failed: $e");
    }
  }

  Future<void> display() async {
    try {
      final response = await supabase
          .from('tbl_decorators')
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        userData = response;
        nameController.text = response['dec_name'] ?? '';
        _emailController.text = response['dec_email'] ?? '';
        _contactController.text = response['dec_contact'] ?? '';
        _addressController.text = response['dec_address'] ?? '';
      });
    } catch (e) {
      print("ERROR FETCHING DATA:$e");
    }
  }

  Future<void> updateData() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty!')),
      );
      return;
    }
    setState(() {
      isUpdating = true;
    });
    try {
      await supabase.from('tbl_decorators').update({
        'dec_name': nameController.text.trim(),
      }).eq('id', userData['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile Updated', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black87,
        ),
      );
      await display();
    } catch (e) {
      print("ERROR UPDATING PROFILE:$e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update failed!')),
      );
    }
    setState(() {
      isUpdating = false;
    });
  }

  Future<String?> uploadImage() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$uid-photo-$timestamp';
      await supabase.storage.from('decorators').upload(fileName, _image!);
      final imageUrl = supabase.storage.from('decorators').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    display();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Pastel light grey
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomDecAppBar(isScrolled: false),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600), // Web-friendly width
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: const Color(0xFFECEFF8), // Pastel grey
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : (userData['dec_img'] != null &&
                                        userData['dec_img'].toString().isNotEmpty
                                    ? NetworkImage(userData['dec_img'])
                                    : null) as ImageProvider<Object>?,
                            child: (_image == null &&
                                    (userData['dec_img'] == null ||
                                        userData['dec_img'].toString().isEmpty))
                                ? const Icon(
                                    Icons.person,
                                    size: 70,
                                    color: Color(0xFFB0B7C9),
                                  )
                                : null,
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFB8D8D8), // Pastel teal
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6B7280),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC), // Pastel off-white
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color(0xFFB8D8D8), // Pastel teal
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6B7280),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFFB8D8D8),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _contactController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Contact',
                        labelStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6B7280),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Color(0xFFB8D8D8),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _addressController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        labelStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6B7280),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: Color(0xFFB8D8D8),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          'Update',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA8C7FA), // Pastel blue
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: isUpdating ? null : updateData,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}