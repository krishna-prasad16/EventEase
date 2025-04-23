import 'package:decorators/decorators/screens/editprofile.dart';
import 'package:decorators/main.dart';
import 'package:flutter/material.dart';


class Decprofile extends StatefulWidget {
  const Decprofile({super.key, });

  @override
  State<Decprofile> createState() => _DecprofileState();
}

class _DecprofileState extends State<Decprofile> {
  
 bool isLoading = true;
    Map<String, dynamic> decData = {};

  Future<void> display() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase
          .from('tbl_decorators')
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        decData = response;
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      print('ERROR DISPLAYING PROFILE DATA:$e');
    }
  }

  @override
  void initState() {
    super.initState();
    display();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: 420,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 8,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFbc6c25).withOpacity(0.1),
                      backgroundImage: (decData['dec_img'] != null && decData['dec_img'] != "")
                          ? NetworkImage(decData['dec_img'])
                          : null,
                      child: (decData['dec_img'] == null || decData['dec_img'] == "")
                          ? const Icon(Icons.person, size: 60, color: Color(0xFFbc6c25))
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      decData['dec_name'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFbc6c25),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      decData['dec_email'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      decData['dec_contact'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      decData['dec_address'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Editprofile(),
                              ),
                            );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFbc6c25),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigator.push(...);
                      },
                      icon: const Icon(Icons.lock, color: Colors.white),
                      label: const Text(
                        'Change Password',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFbc6c25),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => ReportIssueScreen()),
                        // );
                      },
                      child: const Text(
                        'Report an issue',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}