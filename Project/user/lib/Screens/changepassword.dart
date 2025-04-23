import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';

class Changepwd extends StatefulWidget {
  const Changepwd({super.key});

  @override
  State<Changepwd> createState() => _ChangepwdState();
}

class _ChangepwdState extends State<Changepwd> with SingleTickerProviderStateMixin {
  final TextEditingController currentpwdController = TextEditingController();
  final TextEditingController newpwdController = TextEditingController();
  final TextEditingController confirmpwdController = TextEditingController();

  bool showCurrent = false;
  bool showNew = false;
  bool showConfirm = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchpass();
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
    currentpwdController.dispose();
    newpwdController.dispose();
    confirmpwdController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> updatepwd() async {
    final String currentPwd = currentpwdController.text.trim();
    final String newPwd = newpwdController.text.trim();
    final String confirmPwd = confirmpwdController.text.trim();

    if (currentPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    if (newPwd != confirmPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('New password and confirm password do not match')),
      );
      return;
    }
    try {
      String? userData = supabase.auth.currentUser!.id;
      await supabase.from('tbl_user').update({
        'user_password': newPwd,
      }).eq('id', userData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password Updated',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF3E2723),
        ),
      );
      await fetchpass();
      newpwdController.clear();
      confirmpwdController.clear();
    } catch (e) {
      print('ERROR UPDATING PASSWORD:$e');
    }
  }

  Future<void> fetchpass() async {
    try {
      String? userData = supabase.auth.currentUser!.id;
      if (userData != null) {
        final response = await supabase
            .from('tbl_user')
            .select()
            .eq('id', userData)
            .single();
        setState(() {
          currentpwdController.text = response['user_password'];
        });
      } else {
        print('Error');
      }
    } catch (e) {
      print('ERROR FETCHING PASSWORD:$e');
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
          'Change Password',
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
                  children: [
                    Text(
                      'Update your password',
                      style: GoogleFonts.lora(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: currentpwdController,
                      obscureText: !showCurrent,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        labelStyle: GoogleFonts.openSans(
                          color: Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF8D6E63)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showCurrent ? Icons.visibility : Icons.visibility_off,
                            color: Color(0xFF8D6E63),
                          ),
                          onPressed: () => setState(() => showCurrent = !showCurrent),
                        ),
                      ),
                      style: GoogleFonts.openSans(),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: newpwdController,
                      obscureText: !showNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: GoogleFonts.openSans(
                          color: Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF8D6E63)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showNew ? Icons.visibility : Icons.visibility_off,
                            color: Color(0xFF8D6E63),
                          ),
                          onPressed: () => setState(() => showNew = !showNew),
                        ),
                      ),
                      style: GoogleFonts.openSans(),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: confirmpwdController,
                      obscureText: !showConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: GoogleFonts.openSans(
                          color: Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF8D6E63)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirm ? Icons.visibility : Icons.visibility_off,
                            color: Color(0xFF8D6E63),
                          ),
                          onPressed: () => setState(() => showConfirm = !showConfirm),
                        ),
                      ),
                      style: GoogleFonts.openSans(),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: updatepwd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6D4C41),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Update',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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