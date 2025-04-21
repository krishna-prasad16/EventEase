import 'package:flutter/material.dart';
import 'package:user/Screens/Homepage.dart';
import 'package:user/Screens/UserRegistration.dart';
import 'package:user/main.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Future<void> _signIn() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   final email = _emailController.text.trim();
  //   final password = _passwordController.text;

  //   try {
  //     final result = await supabase.auth.signInWithPassword(
  //       email: email,
  //       password: password,
  //     );

  //     if (result.user != null) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const Homepage()),
  //       );
  //     } else {
  //       _showError('Login failed. Please check your credentials.');
  //     }
  //   } catch (e) {
  //     _showError('Login error: ${e.toString()}');
  //   }

  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
   

  void _showInvalidDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Failed"),
        content: const Text("Invalid login details. Please try again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validation for empty fields
    if (email.isEmpty && password.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    } else if (email.isEmpty) {
      _showError("Please enter your email.");
      return;
    } else if (password.isEmpty) {
      _showError("Please enter your password.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      } else {
        _showInvalidDialog(); // Show alert for wrong credentials
      }
    } catch (e) {
      _showInvalidDialog(); // Catch also shows the alert
    }

    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3ED), // Soft pastel background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Meredith',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 128, 83, 47),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Column(
                    children: [
                      Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 153, 124, 70),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Let's get started",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7D8CA2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF8F4), // light pastel form bg
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'your email here',
                            hintStyle:
                                const TextStyle(color: Color(0xFFB1C4D6)),
                            prefixIcon: const Icon(Icons.email,
                                color: Color(0xFFB1C4D6)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor:
                                const Color(0xFFF7F3ED), // pastel input bg
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'your password here',
                            hintStyle:
                                const TextStyle(color: Color(0xFFB1C4D6)),
                            prefixIcon: const Icon(Icons.lock,
                                color: Color(0xFFB1C4D6)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFFB1C4D6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF7F3ED),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                 
                 
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD2B48C), // light brown
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 120,
                        vertical: 15,
                      ),
                      shadowColor: Colors.black.withOpacity(0.1),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Registration()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Color(0xFF7D8CA2)),
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
