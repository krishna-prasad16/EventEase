import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/Screens/changepassword.dart';
import 'package:user/Screens/editprofile.dart';
import 'package:user/Screens/feedback.dart';
import 'package:user/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = true;
  Map<String, dynamic> userData = {};

  Future<void> display() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        userData = response;
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E2723),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF8D6E63)),
            tooltip: 'Refresh',
            onPressed: display,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF8D6E63)))
          : Center(
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Color(0xFFF9F6F2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[100],
                            backgroundImage: (userData['user_photo'] != null && userData['user_photo'].toString().isNotEmpty)
                                ? NetworkImage(userData['user_photo'])
                                : null,
                            child: (userData['user_photo'] == null || userData['user_photo'].toString().isEmpty)
                                ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: IconButton(
                                icon: Icon(Icons.edit, color: Color(0xFF8D6E63)),
                                tooltip: 'Edit Profile Picture',
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        userData['user_name'] ?? 'N/A',
                        style: GoogleFonts.lora(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userData['user_email'] ?? 'N/A',
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (userData['user_phone'] != null)
                        Text(
                          userData['user_phone'],
                          style: GoogleFonts.openSans(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.edit, color: Colors.white),
                            label: Text(
                              'Edit Profile',
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6D4C41),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
                            },
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            icon: Icon(Icons.lock, color: Colors.white),
                            label: Text(
                              'Change Password',
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8D6E63),
                              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Changepwd()));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
                        },
                        child: Text(
                          'Report an issue',
                          style: GoogleFonts.openSans(
                            color: Color(0xFF8D6E63),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF8D6E63),
                          ),
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