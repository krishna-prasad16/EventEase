import 'package:decorators/catering/screens/view_fooditem.dart';
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
              const SizedBox(width: 700),
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
              TextButton(onPressed: () {}, child: const Text("Profile")),
              TextButton(onPressed: () {}, child: const Text("Logout")),
            ],
          ),
        ),
      ),
    );
  }
}