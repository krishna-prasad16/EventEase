import 'package:flutter/material.dart';

class Appbar1 extends StatelessWidget {
  const Appbar1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SizedBox(height: 15),
        Container(
          height: 50,
          decoration: BoxDecoration(color: Color(0xffccdad1)),
          child: // Admin profile
              Row(
            children: [
              const SizedBox(width: 1100),
              ClipOval(
                child: Image.asset(
                  "assets/d.jpg",
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Admin",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "MEREDITH",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 17, 16, 16),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
