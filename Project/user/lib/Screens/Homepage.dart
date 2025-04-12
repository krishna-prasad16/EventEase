import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/Screens/mybooking.dart';
import 'package:user/Screens/viewdecorations.dart';

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
          preferredSize: const Size.fromHeight(70), // Increase AppBar height
          child: AppBar(
            backgroundColor: Colors.white, // Removes default back arrow
            // leading: IconButton(
            //   icon: Icon(Icons.menu),
            //   onPressed: () {
            //     Scaffold.of(context).openDrawer();
            //   },
            // ),
            title:
                SizedBox(), // Keeps the title empty to allow manual alignment
            actions: [
              Padding(
                padding: const EdgeInsets.only(
                    right: 16.0, top: 30), // Adjust as needed
                child: Image.asset(
                  "assets/logo.png",
                  height: 40,
                  width: 130, // Adjust size as needed
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
                    color: const Color.fromARGB(255, 187, 195, 201)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    SizedBox(height: 10),
                    Text('User Name',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text('user@example.com',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text('My Booking'),
                onTap: () {
                   Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Mybooking()),
                              );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => SettingsPage(),
                  //   ),
                  // );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  // // Navigate to login page and remove all previous routes
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => UserLoginPage()),
                  //   (route) => false, // Removes all previous routes
                  // );
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
                  color: Colors.white.withOpacity(0.4),
                  child: Text(
                    "Welcome to Meredith Events",
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                height: 320,
                padding: EdgeInsets.symmetric(
                    horizontal: 20), // Add padding for better spacing
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Align content in the center
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center text horizontally
                  children: [
                    Text(
                      "Unlock Your Dream Destination Wedding in Kerala",
                      style: GoogleFonts.cormorantGaramond(
                        color: Colors.black,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10), // Space between texts

                    Text(
                      "Choose Meredith Event Management Company for your premium destination wedding in Kerala, India. Whether you dream of a beach wedding in Kerala or a resort celebration, we will bring it to life, infusing rich traditions.",
                      style: GoogleFonts.cormorantGaramond(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "We also offer venue selection assistance for an easier planning process. Our track record includes clients from India and abroad, making us your ideal partner for a dream destination wedding in Kerala, India.",
                      style: GoogleFonts.cormorantGaramond(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              //silder 1
              Container(
                padding: EdgeInsets.all(20),
                height: 400, // Reduced height for better aspect ratio
                width: double.infinity, // Make it responsive
                child: Stack(
                  children: [
                    Positioned(
                      top: 50, // Adjust positioning
                      left: 0,
                      right: 0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 500, // Adjusted image width
                            height: 300, // Adjusted image height
                            child: PageView.builder(
                              controller: _pageController1,
                              itemCount: slider1Images.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      10), // Optional: Add rounded corners
                                  child: Image.asset(
                                    slider1Images[index],
                                    width:
                                        500, // Ensure width matches container
                                    height:
                                        300, // Ensure height matches container
                                    fit: BoxFit
                                        .cover, // Ensures the image fills the space
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            left: 10,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  color: Colors.white, size: 30),
                              onPressed: _previousPage1,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            child: IconButton(
                              icon: Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 30),
                              onPressed: _nextPage1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //slider 2
              Container(
                padding: EdgeInsets.all(20),
                height: 400, // Reduced height for better aspect ratio
                width: double.infinity, // Make it responsive
                child: Stack(
                  children: [
                    Positioned(
                      top: 50, // Adjust positioning
                      left: 0,
                      right: 0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 500, // Adjusted image width
                            height: 300, // Adjusted image height
                            child: PageView.builder(
                              controller: _pageController2,
                              itemCount: slider1Images.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      10), // Optional: Add rounded corners
                                  child: Image.asset(
                                    slider1Images[index],
                                    width:
                                        500, // Ensure width matches container
                                    height:
                                        300, // Ensure height matches container
                                    fit: BoxFit
                                        .cover, // Ensures the image fills the space
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            left: 10,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  color: Colors.white, size: 30),
                              onPressed: _previousPage2,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            child: IconButton(
                              icon: Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 30),
                              onPressed: _nextPage2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 320,
                padding: EdgeInsets.symmetric(
                    horizontal: 20), // Add padding for better spacing
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Align content in the center
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center text horizontally
                  children: [
                    Text(
                      "OUR SERVICES",
                      style: GoogleFonts.cormorantGaramond(
                        color: const Color.fromARGB(255, 52, 50, 50),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Services by Meredith Event Management",
                      style: GoogleFonts.cormorantGaramond(
                        color: Colors.black,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 10), // Space between texts

                    Text(
                      "Meredith Event Management is a certified ISO 9001:2015 event management company based in the state of Kerala, South India. We offer excellent, comprehensive event management services, including personal event planning, corporate events and conferences, private parties, trade exhibitions, virtual event management services, and entertaining stage shows all over Kerala. Feel free to contact us.",
                      style: GoogleFonts.cormorantGaramond(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // 90% of screen width
                constraints: BoxConstraints(
                  maxWidth: 400, // Maximum width limit
                ),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
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
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "If you want to make a statement at your next corporate event, partner with "
                            "Melodia Event Management Company in Kerala.",
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Viewdecorations()),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Learn More",
                                  style: GoogleFonts.openSans(
                                    fontSize: 14,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(Icons.double_arrow,
                                    color: Colors.deepPurple, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // 90% of screen width
                constraints: BoxConstraints(
                  maxWidth: 400, // Maximum width limit
                ),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
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
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Have you ever dreamed of planning the perfect wedding event to be remembered forever?",
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Viewdecorations()),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Learn More",
                                  style: GoogleFonts.openSans(
                                    fontSize: 14,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(Icons.double_arrow,
                                    color: Colors.deepPurple, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/Bride.jpeg'), // Replace with actual image
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color:
                        Colors.black.withOpacity(0.7), // Black overlay effect
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Social Media Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library,
                              color: Colors.white, size: 28), // YouTube
                          SizedBox(width: 15),
                          Icon(Icons.facebook, color: Colors.white, size: 28),
                          SizedBox(width: 15),
                          Icon(Icons.linked_camera,
                              color: Colors.white, size: 28), // LinkedIn
                          SizedBox(width: 15),
                          Icon(Icons.share,
                              color: Colors.white, size: 28), // Twitter
                        ],
                      ),
                      SizedBox(height: 16),
                      // Logo
                      Image.asset(
                        'assets/logo.png', // Replace with actual logo
                        height: 60,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Meredith",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Event Management",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Description Text
                      Text(
                        "Planning a full event has never been easier! Meredith® Event Management, an ISO 9001:2015 Certified Event Management Company based in Kerala state, India, offers a wide range of services to make your events stress-free and memorable across Kerala. From premium corporate events and destination wedding planning to small-scale birthday parties and private gatherings, you can be sure we have it all covered. With offices in Kochi, Thrissur, Calicut, and Trivandrum, we also specialize in venue selections and hospitality services. We primarily serve Keralites, Malayalees, and those looking to plan destination events in Kerala. We exclusively operate within Kerala. Whether you are planning a destination wedding event or a local celebration in Kerala, India, Melodia® is here to help.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16),
                      Divider(color: Colors.white54),
                      SizedBox(height: 8),
                      Text(
                        "Meredith Event Management. All Rights Reserved.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
