import 'dart:io';
import 'dart:typed_data';

import 'package:decorators/catering/widgets/custom_catering_appbar.dart';
import 'package:decorators/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyFood extends StatefulWidget {
  const MyFood({super.key});

  @override
  State<MyFood> createState() => _MyFoodState();
}

class _MyFoodState extends State<MyFood> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  PlatformFile? pickedImage;

  String _foodType = 'VEG'; // Default value

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

  Future<String?> photoUpload() async {
    try {
      final bucketName = 'fooditem'; // Replace with your bucket name
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileExtension =
          pickedImage!.name.split('.').last; // Get the file extension
      final fileName =
          "${timestamp}.${fileExtension}"; // New file name with timestamp
      final filePath = fileName;

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

  Future<void> _submitProduct() async {
    try {
      String? url = await photoUpload();

      await Supabase.instance.client.from('tbl_food').insert({
        'food_name': _titleController.text,
        'food_amount': _budgetController.text,
        'food_image': url,
        'food_type': _foodType, // Insert food type
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" Inserted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error inserting product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error inserting product: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomCateringAppBar(isScrolled: false),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 450,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add Food Items",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: "Title"),
                      ),
                      TextField(
                        controller: _budgetController,
                        decoration: const InputDecoration(labelText: "Budget"),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      // Radio buttons for food type
                      Row(
                        children: [
                          const Text("Type: "),
                          Radio<String>(
                            value: 'VEG',
                            groupValue: _foodType,
                            onChanged: (value) {
                              setState(() {
                                _foodType = value!;
                              });
                            },
                          ),
                          const Text('VEG'),
                          Radio<String>(
                            value: 'NON',
                            groupValue: _foodType,
                            onChanged: (value) {
                              setState(() {
                                _foodType = value!;
                              });
                            },
                          ),
                          const Text('NON'),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                                  borderRadius: BorderRadius.circular(8),
                                  child: pickedImage!.bytes != null
                                      ? Image.memory(
                                          Uint8List.fromList(
                                              pickedImage!.bytes!),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(pickedImage!.path!),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _submitProduct,
                        child: const Text("Add"),
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
