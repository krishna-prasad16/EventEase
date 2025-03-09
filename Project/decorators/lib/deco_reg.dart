import 'dart:io';
import 'dart:typed_data';

import 'package:decorators/main.dart';
import 'package:decorators/index.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
      Navigator.push(context, MaterialPageRoute(builder: (context) => Index(),));
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                  key: _formKey,
                  child: Container(
                    width: 500,
                    color: const Color.fromARGB(255, 197, 181, 175),
                    child: Column(
                      children: [
                        const SizedBox(height: 16.0),
                        const Text(
                          "  Decorator Registration",
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 5.0),
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: pickedImage == null
                              ? GestureDetector(
                                  onTap: handleImagePick,
                                  child: Icon(
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
                                            Uint8List.fromList(
                                                pickedImage!.bytes!), // For web
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(pickedImage!
                                                .path!), // For mobile/desktop
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 20),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: "Your Name",
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 20),
                              border: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(12.0),
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
                        ),

                        const SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 20),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: "Your Email",
                              prefixIcon: const Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return "Please enter a valid email address";
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 20),
                          child: TextFormField(
                            controller: _adrsController,
                            decoration: InputDecoration(
                              hintText: "Your address",
                              prefixIcon: const Icon(Icons.note_add_rounded),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 20),
                              border: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your address";
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 20),
                          child: TextFormField(
                            controller: _contactController,
                            decoration: InputDecoration(
                              hintText: "Your phone Number ",
                              prefixIcon: const Icon(Icons.phone),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 20),
                              border: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your Phone Number";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Place ID
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedDist,
                                hint: const Text("Select District"),
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
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedPlace,
                                hint: const Text("Select place"),
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
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 20),
                          child: TextFormField(
                            readOnly: true,
                            onTap: () {
                              handleFilePick();
                            },
                            controller: _proofController,
                            decoration: InputDecoration(
                              hintText: "Proof",
                              prefixIcon: const Icon(Icons.file_copy),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 20),
                              border: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter the proof";
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        // Password Field
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 20),
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
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
                        ),
                        const SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 20),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              hintText: "Confirm Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
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
                        ),
                        const SizedBox(height: 24.0),
                        ElevatedButton(
                            onPressed: () {
                              register();
                            },
                            child: Text("Submit")),

                        const SizedBox(height: 24.0),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
