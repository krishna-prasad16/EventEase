import 'dart:async';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'package:user/Screens/Homepage.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  late ConfettiController _confettiController;
  // ignore: unused_field
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _confettiController.play(); // Start confetti animation
    _timer = Timer(const Duration(seconds: 5), _navigateToHomepage);
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _navigateToHomepage() {
    // Navigate to the homepage and clear all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              Homepage()), // Replace `HomePage` with your actual homepage widget
      (Route<dynamic> route) => false, // Remove all routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Confetti Animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Success Icon (Lottie)
                Center(
                  child: Lottie.asset(
                    'assets/success.json',
                    repeat: false,
                  ),
                ),

                // Success Message
                const SizedBox(height: 20),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}