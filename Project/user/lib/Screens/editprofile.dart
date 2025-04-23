import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/main.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic> userData = {};
  bool isUpdating = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    display();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

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
      await supabase.from('tbl_user').update({'user_photo': url}).eq("id", uid);
    } catch (e) {
      print("Image updation failed: $e");
    }
  }

  Future<void> display() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        userData = response;
        nameController.text = response['user_name'] ?? '';
        _emailController.text = response['user_contact'] ?? '';
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
      await supabase.from('tbl_user').update({
        'user_name': nameController.text.trim(),
      }).eq('id', userData['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile Updated', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF3E2723),
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
      await supabase.storage.from('user').upload(fileName, _image!);
      final imageUrl = supabase.storage.from('user').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.lora(
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF8D6E63)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Color(0xFFF9F6F2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                            radius: 60,
                            backgroundColor: Colors.grey[100],
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : (userData['user_photo'] != null &&
                                        userData['user_photo'].toString().isNotEmpty
                                    ? NetworkImage(userData['user_photo'])
                                    : null) as ImageProvider<Object>?,
                            child: (_image == null &&
                                    (userData['user_photo'] == null ||
                                        userData['user_photo'].toString().isEmpty))
                                ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                                : null,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(Icons.camera_alt, color: Color(0xFF8D6E63), size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: GoogleFonts.openSans(
                          color: Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.person, color: Color(0xFF8D6E63)),
                      ),
                      style: GoogleFonts.openSans(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.openSans(
                          color: Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.email, color: Color(0xFF8D6E63)),
                      ),
                      style: GoogleFonts.openSans(),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: isUpdating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.save, color: Colors.white),
                        label: Text(
                          'Update',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6D4C41),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
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