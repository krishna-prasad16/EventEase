import 'package:admin/screen/Dashboard.dart';
import 'package:admin/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ishpstbsscooimvdqnfw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlzaHBzdGJzc2Nvb2ltdmRxbmZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQzNDY5MTUsImV4cCI6MjA0OTkyMjkxNX0.a2Pt9CucLpYGBa4TX0WpfosrCOA8boOfS3ODtiGUTwE',
  );
  runApp(const MainApp());
}
final supabase=Supabase.instance.client;
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner:false, //debug maarum
      home: AuthWrapper()
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    final session = supabase.auth.currentSession;

    // Navigate to the appropriate screen based on the authentication state
    if (session != null) {
      return AdminHome(); // Replace with your home screen widget
    } else {
      return Login(); // Replace with your auth page widget
    }
  }
}
