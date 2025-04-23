import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/Screens/login.dart';
import 'package:user/Screens/mybooking.dart';
import 'package:user/Screens/profile.dart';
import 'package:user/Screens/searchcatering.dart';
import 'package:user/Screens/viewdecorations.dart';
import 'package:user/main.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final PageController _pageController1 = PageController();
  final PageController _pageController2 = PageController();

  int _currentPage1 = 0;
  int _currentPage2 = 0;

  final List<String> slider1Images = [
    'assets/img1.jpeg',
    'assets/img.jpg',
  ];
  final List<String> slider2Images = [
    'assets/img1.jpeg',
    'assets/img.jpg',
  ];

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();

    // Auto-slide for first slider
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (mounted) _nextPage1();
    });

    // Auto-slide for second slider
    Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (mounted) _nextPage2();
    });

    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        userData = response;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _nextPage1() {
    setState(() {
      _currentPage1 = (_currentPage1 + 1) % slider1Images.length;
      _pageController1.animateToPage(
        _currentPage1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _previousPage1() {
    setState(() {
      _currentPage1 =
          (_currentPage1 - 1 + slider1Images.length) % slider1Images.length;
      _pageController1.animateToPage(
        _currentPage1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _nextPage2() {
    setState(() {
      _currentPage2 = (_currentPage2 + 1) % slider2Images.length;
      _pageController2.animateToPage(
        _currentPage2,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _previousPage2() {
    setState(() {
      _currentPage2 =
          (_currentPage2 - 1 + slider2Images.length) % slider2Images.length;
      _pageController2.animateToPage(
        _currentPage2,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController1.dispose();
    _pageController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Color(0xFF6D4C41)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 15),
              child: Image.asset(
                "assets/logo.png",
                height: 40,
                width: 130,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
              ),
              child: userData == null
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF8D6E63)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: (userData!['user_photo'] != null &&
                                  userData!['user_photo'].toString().isNotEmpty)
                              ? NetworkImage(userData!['user_photo'])
                              : null,
                          child: (userData!['user_photo'] == null ||
                                  userData!['user_photo'].toString().isEmpty)
                              ? Icon(Icons.person, size: 40, color: Color(0xFF8D6E63))
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userData!['user_name'] ?? 'N/A',
                          style: GoogleFonts.lora(
                            color: Color(0xFF3E2723),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          userData!['user_email'] ?? 'N/A',
                          style: GoogleFonts.openSans(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color(0xFF8D6E63)),
              title: Text('Home', style: GoogleFonts.openSans()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Color(0xFF8D6E63)),
              title: Text('Profile', style: GoogleFonts.openSans()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list, color: Color(0xFF8D6E63)),
              title: Text('My Booking', style: GoogleFonts.openSans()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Mybooking()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text(
                "Logout",
                style: GoogleFonts.openSans(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Logout", style: GoogleFonts.lora()),
                    content: Text("Are you sure you want to logout?", style: GoogleFonts.openSans()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("Cancel", style: GoogleFonts.openSans()),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("Logout", style: GoogleFonts.openSans()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true) {
                  supabase.auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                alignment: Alignment.center,
                color: Colors.white.withOpacity(0.5),
                child: Text(
                  "Welcome to Meredith Events",
                  style: GoogleFonts.playfairDisplay(
                    color: Color(0xFF3E2723),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    "Unlock Your Dream Destination Wedding in Kerala",
                    style: GoogleFonts.lora(
                      color: Color(0xFF4A2F27),
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Choose Meredith Event Management Company for your premium destination wedding in Kerala, India. Whether you dream of a beach wedding in Kerala or a resort celebration, we will bring it to life, infusing rich traditions.",
                    style: GoogleFonts.openSans(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "We also offer venue selection assistance for an easier planning process. Our track record includes clients from India and abroad, making us your ideal partner for a dream destination wedding in Kerala, India.",
                    style: GoogleFonts.openSans(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              height: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: PageView.builder(
                      controller: _pageController1,
                      itemCount: slider1Images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            slider1Images[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                      onPressed: _previousPage1,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
                      onPressed: _nextPage1,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              height: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: PageView.builder(
                      controller: _pageController2,
                      itemCount: slider2Images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            slider2Images[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                      onPressed: _previousPage2,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
                      onPressed: _nextPage2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              color: Color(0xFFF9F6F2),
              child: Column(
                children: [
                  Text(
                    "OUR SERVICES",
                    style: GoogleFonts.openSans(
                      color: Color(0xFF8D6E63),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Services by Meredith Event Management",
                    style: GoogleFonts.lora(
                      color: Color(0xFF4A2F27),
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Meredith Event Management is a certified ISO 9001:2015 event management company based in the state of Kerala, South India. We offer excellent, comprehensive event management services, including personal event planning, corporate events and conferences, private parties, trade exhibitions, virtual event management services, and entertaining stage shows all over Kerala. Feel free to contact us.",
                    style: GoogleFonts.openSans(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(maxWidth: 400),
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      'assets/img.jpg',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Decorations",
                          style: GoogleFonts.lora(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "If you want to make a statement at your next corporate event, partner with Meredith Event Management Company in Kerala.",
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Viewdecorations()),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                "Learn More",
                                style: GoogleFonts.openSans(
                                  fontSize: 14,
                                  color: Color(0xFF8D6E63),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.arrow_forward, color: Color(0xFF8D6E63), size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(maxWidth: 400),
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      'assets/Wed.jpg',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Catering",
                          style: GoogleFonts.lora(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Have you ever dreamed of planning the perfect wedding event to be remembered forever?",
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Searchcatering()),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                "Learn More",
                                style: GoogleFonts.openSans(
                                  fontSize: 14,
                                  color: Color(0xFF8D6E63),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.arrow_forward, color: Color(0xFF8D6E63), size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Bride.jpeg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library, color: Colors.white, size: 24),
                      SizedBox(width: 15),
                      Icon(Icons.facebook, color: Colors.white, size: 24),
                      SizedBox(width: 15),
                      Icon(Icons.linked_camera, color: Colors.white, size: 24),
                      SizedBox(width: 15),
                      Icon(Icons.share, color: Colors.white, size: 24),
                    ],
                  ),
                  SizedBox(height: 20),
                  Image.asset(
                    'assets/logo.png',
                    height: 60,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Meredith",
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Event Management",
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Planning a full event has never been easier! Meredith® Event Management, an ISO 9001:2015 Certified Event Management Company based in Kerala state, India, offers a wide range of services to make your events stress-free and memorable across Kerala. From premium corporate events and destination wedding planning to small-scale birthday parties and private gatherings, you can be sure we have it all covered. With offices in Kochi, Thrissur, Calicut, and Trivandrum, we also specialize in venue selections and hospitality services. We primarily serve Keralites, Malayalees, and those looking to plan destination events in Kerala. We exclusively operate within Kerala. Whether you are planning a destination wedding event or a local celebration in Kerala, India, Melodia® is here to help.",
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.white54),
                  SizedBox(height: 8),
                  Text(
                    "Meredith Event Management. All Rights Reserved.",
                    style: GoogleFonts.openSans(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}