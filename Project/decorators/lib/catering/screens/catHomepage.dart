import 'dart:async';
import 'package:decorators/catering/widgets/custom_catering_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Cathomepage extends StatefulWidget {
  const Cathomepage({super.key});

  @override
  State<Cathomepage> createState() => _CathomepageState();
}

class _CathomepageState extends State<Cathomepage>
    with SingleTickerProviderStateMixin {
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
  int _currentImageIndex = 0;

  final List<String> images = [
    'assets/h3.jpeg',
    'assets/h6.jpg',
    'assets/h7.jpg',
  ];

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
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(-0.02, -0.02),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration.zero, () {
          setState(() {
            _currentImageIndex = (_currentImageIndex + 1) % images.length;
          });
          _controller.reset();
          _controller.forward();
        });
      }
    });
    _controller.forward();

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
        preferredSize: const Size.fromHeight(70),
        child: CustomCateringAppBar(isScrolled: _isScrolled),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            images[_currentImageIndex],
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
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
                    child: Text(
                      "Planning with Heart",
                      style: GoogleFonts.tangerine(
                        color: Colors.white,
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
              height: 100,
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
                Container(
                  height: 25,
                  width: 1,
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  color: Colors.brown[300],
                ),

                // Second Column (Email)
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 20, color: Colors.brown),
                    SizedBox(width: 8),
                    Text(
                      "meredith@gmail.com",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: Colors.brown[700],
                      ),
                    ),
                  ],
                ),

                // Divider
                Container(
                  height: 25,
                  width: 1,
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  color: Colors.brown[300],
                ),

                // Third Column (Copyright)
                Row(
                  children: [
                    Icon(Icons.copyright, size: 18, color: Colors.brown),
                    SizedBox(width: 8),
                    Text(
                      "2035 Meredith Weddings",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: Colors.brown[700],
                      ),
                    ),
                  ],
                ),

                // Vertical Divider
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
