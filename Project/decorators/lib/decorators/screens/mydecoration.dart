import 'dart:io';
import 'dart:typed_data';

import 'package:decorators/decorators/widgets/custom_dec_appbar.dart';
import 'package:decorators/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';


class Mydecoration extends StatefulWidget {
  const Mydecoration({super.key});

  @override
  State<Mydecoration> createState() => _MydecorationState();
}

class _MydecorationState extends State<Mydecoration> {
   final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
   final TextEditingController _budgetController = TextEditingController();

   PlatformFile? pickedImage;

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
      final bucketName = 'decoration'; // Replace with your bucket name
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

      await Supabase.instance.client.from('tbl_decorations').insert({
        'decoration_title': _titleController.text,
        
        'decoration_budget': double.tryParse(_budgetController.text) ?? 0.0,
        'decoration_description': _descriptionController.text,
        'decoration_image': url,
      });
      _titleController.clear();

      _budgetController.clear();
      _descriptionController.clear();
      setState(() {
        pickedImage = null; // Reset the image after submission
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" Inserted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
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
  @override
Widget build(BuildContext context) {
  return Scaffold(
   appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomDecAppBar(isScrolled: false),
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
                      "Add Decorations",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: "Description"),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: _budgetController,
                      decoration: const InputDecoration(labelText: "Budget"),
                      maxLines: 3,
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