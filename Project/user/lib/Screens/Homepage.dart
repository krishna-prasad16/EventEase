import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0; // Track selected tab

  // List of pages for bottom navigation (using Navigator)
  final List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    BookingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1C355E),
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex], // selected screen display cheyyum

      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF1C355E),
        shape: CircularNotchedRectangle(), // Optional notch design
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(Icons.home, "Home", 0, context),
              buildNavItem(Icons.search, "Search", 1, context),
              buildNavItem(Icons.book, "Booking", 2, context),
              buildNavItem(Icons.person, "Profile", 3, context),
            ],
          ),
        ),
      ),
    );
  }

  // Updated function to navigate on tap using Navigator.push()
  Widget buildNavItem(IconData icon, String label, int index, BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: _selectedIndex == index ? Colors.blue : Colors.grey, // Highlight selected icon
      ),
      onPressed: () {
        setState(() {
          _selectedIndex = index; // Change screen
        });

        // Add navigation logic here
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              switch (index) {
                case 0:
                  return HomeScreen();
                case 1:
                  return SearchScreen();
                case 2:
                  return BookingScreen();
                case 3:
                  return ProfileScreen();
                default:
                  return HomeScreen();
              }
            },
          ),
        );
      },
    );
  }
}

// Placeholder Screens
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("🏠 Home Screen", style: TextStyle(fontSize: 24)));
  }
}

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("🔍 Search Screen", style: TextStyle(fontSize: 24)));
  }
}

class BookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("📅 Booking Screen", style: TextStyle(fontSize: 24)));
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("👤 Profile Screen", style: TextStyle(fontSize: 24)));
  }
}
