import 'package:decorators/catering/screens/cat_complaint.dart';
import 'package:decorators/catering/screens/cat_profile.dart';
import 'package:decorators/catering/screens/view_fooditem.dart';
import 'package:decorators/login.dart';
import 'package:decorators/main.dart';
import 'package:flutter/material.dart';
import 'package:decorators/catering/screens/catHomepage.dart';
import 'package:decorators/catering/screens/myfood.dart';
import 'package:decorators/catering/screens/cat_mybooking.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCateringAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isScrolled;
  const CustomCateringAppBar({super.key, required this.isScrolled});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        content: Text("Are you sure you want to logout?", style: GoogleFonts.poppins(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Logout", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await supabase.auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.black; // Changed to black
    return Container(
      color: isScrolled ? Colors.white : Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo with subtle animation
              GestureDetector(
                onTap: () => _navigateToPage(context, const Cathomepage()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transform: Matrix4.identity()..scale(isScrolled ? 0.95 : 1.0),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 180,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Navigation buttons
              Row(
                children: [
                  _NavButton(
                    title: "Home",
                    onPressed: () => _navigateToPage(context, const Cathomepage()),
                    textColor: textColor,
                  ),
                  const SizedBox(width: 16),
                  _NavButton(
                    title: "Add Food",
                    onPressed: () => _navigateToPage(context, MyFood()),
                    textColor: textColor,
                  ),
                  const SizedBox(width: 16),
                  _NavButton(
                    title: "View Food",
                    onPressed: () => _navigateToPage(context, ViewFood()),
                    textColor: textColor,
                  ),
                  const SizedBox(width: 16),
                  _NavButton(
                    title: "Bookings",
                    onPressed: () => _navigateToPage(context, CatMybooking()),
                    textColor: textColor,
                  ),
                  const SizedBox(width: 16),
                  // Dropdown for additional options
                  PopupMenuButton<String>(
                    tooltip: "More Options",
                    icon: const Icon(Icons.menu, color: textColor, size: 28),
                    onSelected: (value) {
                      if (value == 'complaints') {
                        _navigateToPage(context, FeedbackPage());
                      } else if (value == 'profile') {
                        _navigateToPage(context, CatPtofile());
                      } else if (value == 'logout') {
                        _handleLogout(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'complaints',
                        child: Text("Complaints", style: GoogleFonts.poppins(color: textColor)),
                      ),
                      PopupMenuItem(
                        value: 'profile',
                        child: Text("Profile", style: GoogleFonts.poppins(color: textColor)),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Text("Logout", style: GoogleFonts.poppins(color: Colors.redAccent)),
                      ),
                    ],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable navigation button widget
class _NavButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color textColor;

  const _NavButton({
    required this.title,
    required this.onPressed,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}