import 'package:flutter/material.dart';
import 'package:user/Screens/UserRegistration.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF), // Light blue background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section 
                const Column(
                  children: [
                    Icon(
                      Icons.nightlight_round,
                      size: 40,
                      color: Color(0xFF1C355E), // Dark blue
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Event Ease',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C355E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Welcome Text Section
                const Column(
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C355E),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Let's get start",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7D8CA2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Input Fields Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'your email here',
                          hintStyle: const TextStyle(color: Color(0xFFB1C4D6)),
                          prefixIcon: const Icon(Icons.email, color: Color(0xFFB1C4D6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F6FB),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'your password here',
                          hintStyle: const TextStyle(color: Color(0xFFB1C4D6)),
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFFB1C4D6)),
                          suffixIcon:
                              const Icon(Icons.visibility, color: Color(0xFFB1C4D6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F6FB),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot Password functionality
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color(0xFF7D8CA2)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Sign In Button
                ElevatedButton(
                  onPressed: () {
                    // Sign In functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C355E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 120,
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
                TextButton(
                  onPressed: () {
                    // Sign Up functionality
                  },
                  child: GestureDetector(onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (Context)=>Registration()),
                    );
                  },//vere oru pagilekk link cheyyan
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF7D8CA2),
                      ),
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
