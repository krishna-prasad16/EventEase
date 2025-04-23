import 'package:flutter/material.dart';

class Appbar1 extends StatelessWidget {
  const Appbar1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            color: Color(0xff065a60), // Match sidebar's teal background
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        "assets/women3.jpg",
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Admin",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          "MEREDITH",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Icon(
                    //   Icons.keyboard_arrow_down,
                    //   color: Colors.amber.withOpacity(0.7),
                    //   size: 18,
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}