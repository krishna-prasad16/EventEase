import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/Screens/Homepage.dart';
import 'package:user/Screens/UserRegistration.dart';
import 'package:user/main.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: (_fadeAnimation == null || _slideAnimation == null)
                ? const SizedBox.shrink()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Meredith',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF3E2723),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Welcome Back',
                              style: GoogleFonts.lora(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4A2F27),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to continue your journey',
                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: GoogleFonts.openSans(
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF8D6E63),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: GoogleFonts.openSans(
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF8D6E63),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF8D6E63),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6D4C41),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 100,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: GoogleFonts.openSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Registration(),
                                  ),
                                );
                              },
                              child: Text(
                                'Create an Account',
                                style: GoogleFonts.openSans(
                                  fontSize: 14,
                                  color: const Color(0xFF8D6E63),
                                  fontWeight: FontWeight.w600,
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
      ),
    );
  }
}