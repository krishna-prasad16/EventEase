import 'dart:async';
import 'package:decorators/deco_reg.dart';
import 'package:decorators/decorators/screens/mydecoration.dart';
import 'package:decorators/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> with SingleTickerProviderStateMixin {
  final PageController _pageController1 = PageController();
  final PageController _pageController2 = PageController();
  final PageController _pageController3 = PageController();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;
  late ScrollController _scrollController;
  bool _isScrolled = false;

  int _currentPage1 = 0;
  int _currentPage2 = 0;
  int _currentPage3 = 0;

  final List<String> slider1Images = [
    'assets/img1.jpeg',
    'assets/img.jpg',
    'assets/wed.jpg',
  ];

  final List<String> slider2Images = [
    'assets/img1.jpeg',
    'assets/img.jpg',
    'assets/wed.jpg',
  ];

  final List<String> slider3Images = [
    'assets/img1.jpeg',
    'assets/img.jpg',
    'assets/wed.jpg',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(-0.02, -0.02),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });

    // Auto-slide for first slider
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (mounted) _nextPage1();
    });

    // Auto-slide for second slider
    Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (mounted) _nextPage2();
    });

    // Auto-slide for third slider
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

  void _nextPage3() {
    setState(() {
      _currentPage2 = (_currentPage3 + 1) % slider2Images.length;
      _pageController3.animateToPage(
        _currentPage2,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _previousPage3() {
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
    _controller.dispose();
    _pageController1.dispose();
    _pageController2.dispose();
    _pageController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // 🔥 This is what makes it float over the hero section
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Container(
          color: _isScrolled ? Colors.white : Colors.transparent,

          // color: Colors.white, // This will force pure white
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 200,
                    height: 130,
                    fit: BoxFit.contain,
                  ),

                  /// Action Buttons
                  Row(
                    children: [
                      // Sign In Button inside container to match Sign Up size
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              );
                            },
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Sign Up Dropdown styled identically
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.black),
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            hint: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Decorator',
                                child: Text('Decorator'),
                              ),
                              DropdownMenuItem(
                                value: 'Catering',
                                child: Text('Catering'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == 'Decorator') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Decoreg()),
                                );
                              } else if (value == 'Catering') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Mydecoration()),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
          controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER WITH NAVIGATION MENU

            // HERO SECTION
            SizedBox(
              height: 600,
              width: double.infinity,
              child: Stack(
                children: [
                  // Animated background image here 👇
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: FractionalTranslation(
                          translation: _positionAnimation.value,
                          child: Image.asset(
                            'assets/img.jpg',
                            height: 600,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),

                  // Overlay + Your existing text 👇
                  Container(
                    height: 600,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: Colors.white.withOpacity(0.4),
                    child: Text(
                      "Planning with Heart",
                      style: GoogleFonts.tangerine(
                        color: Colors.black,
                        fontSize: 68,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // FIRST SECTION WITH SLIDER 1
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 100, top: 50),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 500,
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Have you ever dreamed of planning the perfect event that will be remembered forever? Look no further than Meredith® Events, the top-notch event management company in Kerala, India, that has everything you need to make your occasion an unforgettable experience.",
                            style: GoogleFonts.tangerine(
                                color: Colors.black, fontSize: 27),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "We make everything from corporate event planning and personal celebrations to even small customized event packages absolutely memorable! Contact us today to learn more about our services and how we can help you organize the top event management in Kerala.",
                            style: GoogleFonts.tangerine(
                                color: Colors.black, fontSize: 27),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40),

                // SLIDER 1
                Container(
                  padding: EdgeInsets.all(20),
                  height: 500,
                  width: 700,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 100,
                        child: Container(
                          color: Color(0xFFF5F5DC),
                          width: 600,
                          height: 400,
                        ),
                      ),
                      Positioned(
                        top: 70,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 600,
                              height: 400,
                              child: PageView.builder(
                                controller: _pageController1,
                                itemCount: slider1Images.length,
                                itemBuilder: (context, index) {
                                  return Image.asset(slider1Images[index],
                                      fit: BoxFit.cover);
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
                )
              ],
            ),

            // SECOND SECTION WITH SLIDER 2
            Row(
              children: [
                // SLIDER 2
                Padding(
                  padding: const EdgeInsets.only(left: 90, top: 50),
                  child: Container(
                    height: 500,
                    width: 700,
                    child: Stack(
                      children: [
                        Positioned(
                          child: Container(
                            color: Color(0xFFF5F5DC),
                            width: 550,
                            height: 400,
                          ),
                        ),
                        Positioned(
                          top: 70,
                          left: 50,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 600,
                                height: 400,
                                child: PageView.builder(
                                  controller: _pageController2,
                                  itemCount: slider2Images.length,
                                  itemBuilder: (context, index) {
                                    return Image.asset(slider2Images[index],
                                        fit: BoxFit.cover);
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
                ),
                SizedBox(
                  width: 40,
                  height: 700,
                ),
                Padding(
                  padding: const EdgeInsets.all(95),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: 500,
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Choose Meredith Event Management Company for your premium destination wedding in Kerala, India. Whether you dream of a beach wedding in Kerala or a resort celebration, we will bring it to life, infusing rich traditions.",
                            style: GoogleFonts.tangerine(
                                color: Colors.black, fontSize: 27),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "We also offer venue selection assistance for an easier planning process. Our track record includes clients from India and abroad, making us your ideal partner for a dream destination wedding in Kerala, India.",
                            style: GoogleFonts.tangerine(
                                color: Colors.black, fontSize: 27),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //SECTION 3
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 100, top: 50),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 500,
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Celebrating over a decade of service, Meredith Events is a boutique event planning and design company that specializes in nonprofit fundraising, conferences, and annual celebrations. ",
                            style: GoogleFonts.tangerine(
                                color: Colors.black, fontSize: 27),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "We are inspired by our clients’ mission, values, and goals to create memorable experiences and cultivate lasting impressions and impact. From spreadsheets to illustrated activations, let us help share your vision and build your dream event.",
                            style: GoogleFonts.tangerine(
                                color: Colors.black, fontSize: 27),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40),

                // SLIDER 1
                Container(
                  padding: EdgeInsets.all(20),
                  height: 500,
                  width: 700,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 100,
                        child: Container(
                          color: Color(0xFFF5F5DC),
                          width: 600,
                          height: 400,
                        ),
                      ),
                      Positioned(
                        top: 70,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 600,
                              height: 400,
                              child: PageView.builder(
                                controller: _pageController3,
                                itemCount: slider1Images.length,
                                itemBuilder: (context, index) {
                                  return Image.asset(slider1Images[index],
                                      fit: BoxFit.cover);
                                },
                              ),
                            ),
                            Positioned(
                              left: 10,
                              child: IconButton(
                                icon: Icon(Icons.arrow_back_ios,
                                    color: Colors.white, size: 30),
                                onPressed: _previousPage3,
                              ),
                            ),
                            Positioned(
                              right: 10,
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 30),
                                onPressed: _nextPage3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 300,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First Column (Left)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ernakulam,Kerala",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),

                // Vertical Divider
                Container(
                  height: 20,
                  width: 1,
                  margin: EdgeInsets.symmetric(
                      horizontal: 20), // Space around divider
                  color: Colors.brown, // Adjusted color for similarity
                ),

                // Second Column (Middle)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email: meredith@gmail.com",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),

                // Vertical Divider
                Container(
                  height: 20,
                  width: 1,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  color: Colors.brown,
                ),

                // Third Column (Right)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "© 2035 by Meredith Weddings.",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 150,
            )
          ],
        ),
      ),
    );
  }
}
