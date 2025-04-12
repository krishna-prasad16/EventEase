import 'package:decorators/cat_reg.dart';
import 'package:decorators/main.dart';
import 'package:decorators/deco_reg.dart';
import 'package:decorators/decorators/screens/homepage.dart';

import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> signIN() async {
    try {
      final response = await supabase.auth.signInWithPassword(
          password: _passwordController.text, email: _emailController.text);
      if (response != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Homepage(),
            ));
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3F0), // Soft pastel background
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            height: 600,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFCFB), // Soft pastel container
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                const Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Meredith',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5A4C4C), // Soft pastel text
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Welcome Text Section
                const Column(
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6E5F5F),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Let's get started",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF9C8D8D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Input Fields Section
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAF0), // Soft cream inside box
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'your email here',
                          hintStyle: const TextStyle(color: Color(0xFFA49A9A)),
                          prefixIcon:
                              const Icon(Icons.email, color: Color(0xFFA49A9A)),
                          filled: true,
                          fillColor: const Color(0xFFFDF7F2),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
  controller: _passwordController,
  obscureText: _obscureText,
  decoration: InputDecoration(
    hintText: 'your password here',
    hintStyle: const TextStyle(color: Color(0xFFA49A9A)),
    prefixIcon: const Icon(Icons.lock, color: Color(0xFFA49A9A)),
    suffixIcon: IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,
        color: Color(0xFFA49A9A),
      ),
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    ),
    filled: true,
    fillColor: const Color(0xFFFDF7F2),
    contentPadding: const EdgeInsets.symmetric(vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot Password functionality
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color(0xFF9C8D8D)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Sign In Button
                ElevatedButton(
                  onPressed: () {
                    signIN();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFB3A1A1), // Muted pastel pink
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                    shadowColor: Colors.black.withOpacity(0.1),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign Up Link
                // Sign Up Link with Dialog
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25)),
                      ),
                      backgroundColor: const Color(0xFFFDF7F2),
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Sign Up As",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6E5F5F),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close BottomSheet
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Decoreg()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB3A1A1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 60),
                                ),
                                child: const Text(
                                  "Decorator",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CatReg()), // You create this page
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB3A1A1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 60),
                                ),
                                child: const Text(
                                  "Catering",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color(0xFF9C8D8D),
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
