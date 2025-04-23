import 'package:decorators/catering/screens/cat_changepassword.dart';
import 'package:decorators/catering/screens/cat_editprofile.dart';
import 'package:decorators/main.dart';
import 'package:flutter/material.dart';
import 'package:decorators/catering/widgets/custom_catering_appbar.dart';
import 'package:google_fonts/google_fonts.dart';

class CatPtofile extends StatefulWidget {
  const CatPtofile({super.key});

  @override
  State<CatPtofile> createState() => _CatPtofileState();
}

class _CatPtofileState extends State<CatPtofile> {
  bool isLoading = true;
  Map<String, dynamic> catData = {};

  Future<void> display() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase
          .from('tbl_catering')
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        catData = response;
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
      backgroundColor: const Color(0xFFF5F6FA), // Pastel light grey
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomCateringAppBar(isScrolled: false),
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
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFA8C7FA)))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: const Color(0xFFECEFF8), // Pastel grey
                          backgroundImage: (catData['cat_img'] != null && catData['cat_img'] != "")
                              ? NetworkImage(catData['cat_img'])
                              : null,
                          child: (catData['cat_img'] == null || catData['cat_img'] == "")
                              ? const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Color(0xFFB0B7C9),
                                )
                              : null,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          catData['cat_name'] ?? 'N/A',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3A3A3A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          catData['cat_email'] ?? 'N/A',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          catData['cat_contact'] ?? 'N/A',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          catData['cat_address'] ?? 'N/A',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: const Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Divider(
                          color: const Color(0xFFECEFF8),
                          thickness: 1,
                          height: 1,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CatEditprofile(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: Text(
                            'Edit Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA8C7FA), // Pastel blue
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CatChangepassword(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lock, color: Colors.white),
                          label: Text(
                            'Change Password',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA8C7FA), // Pastel blue
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}