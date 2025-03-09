import 'package:flutter/material.dart';
import 'package:user/Screens/Homepage.dart';

import 'package:user/Screens/login.dart';
// import 'package:user/login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage()
    );
  }
}
