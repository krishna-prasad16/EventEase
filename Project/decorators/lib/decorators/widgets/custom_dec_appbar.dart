
import 'package:decorators/decorators/screens/complaint.dart';
import 'package:decorators/decorators/screens/homepage.dart';
import 'package:decorators/decorators/screens/mybooking.dart';
import 'package:decorators/decorators/screens/mydecoration.dart';
import 'package:decorators/decorators/screens/profile.dart';
import 'package:decorators/decorators/screens/viewdecoration.dart';
import 'package:decorators/login.dart';
import 'package:decorators/main.dart';
import 'package:flutter/material.dart';

class CustomDecAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isScrolled;
  const CustomDecAppBar({super.key, required this.isScrolled});

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
                  SizedBox(
                    width: 500,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DecHomepage()),
                        );
                      },
                      child: Text("Home")),
                  TextButton(onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>Complaint()),
                      );
                  }, child: Text("complaint")),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Mydecoration()),
                        );
                      },
                      child: Text("Add Decoration")),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewDecoration()),
                        );
                      },
                      child: Text("View Decorations")),
                      TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Mybooking()),
                        );
                      },
                      child: Text("My Booking")),
                  TextButton(onPressed: () {
                     Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Decprofile()),
                        );
                  }, child: Text("Profile")),
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