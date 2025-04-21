import 'package:decorators/catering/screens/cat_complaint.dart';
import 'package:decorators/catering/screens/cat_profile.dart';
import 'package:decorators/catering/screens/view_fooditem.dart';
import 'package:decorators/login.dart';
import 'package:decorators/main.dart';
import 'package:flutter/material.dart';
import 'package:decorators/catering/screens/catHomepage.dart';
import 'package:decorators/catering/screens/myfood.dart';
import 'package:decorators/catering/screens/cat_mybooking.dart';

class CustomCateringAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isScrolled;
  const CustomCateringAppBar({super.key, required this.isScrolled});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isScrolled ? Colors.white : Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 200,
                height: 130,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 500),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Cathomepage()),
                    );
                  },
                  child: const Text("Home")),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyFood()),
                    );
                  },
                  child: const Text("Add Food Items")),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewFood()),
                    );
                  },
                  child: const Text("View FoodItems")),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CatMybooking()),
                    );
                  },
                  child: const Text("My Booking")),
                  TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FeedbackPage()),
                    );
                  },
                  child: const Text("complaints")),
              TextButton(onPressed: () {
                Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CatPtofile()),
                    );
              }, child: const Text("Profile")),
              TextButton(
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text("Logout"),
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
                },
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}