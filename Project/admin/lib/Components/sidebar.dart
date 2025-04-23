import 'package:admin/main.dart';
import 'package:admin/screen/login.dart';
import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  final Function(int) onItemSelected;
  const SideBar({super.key, required this.onItemSelected});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin {
  final List<String> pages = [
    "Home",
    "Decorators",
    "Catering",
    "District",
    "Place",
    "EventType",
    "Complaints",
  ];
  final List<IconData> icons = [
    Icons.home,
    Icons.admin_panel_settings_sharp,
    Icons.food_bank,
    Icons.place,
    Icons.place_outlined,
    Icons.add_chart_sharp,
    Icons.message
  ];

  int selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: const Color(0xff065a60),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: const AssetImage('assets/women3.jpg'),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Meredith",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Meredith .com",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Navigation Items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: ListView.builder(
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                            widget.onItemSelected(index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.amber.withOpacity(0.5),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  icons[index],
                                  color: isSelected ? Colors.amber : Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pages[index],
                                    style: TextStyle(
                                      color: isSelected ? Colors.amber : Colors.white,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Logout Button
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            child: const Text("Logout"),
                          ),
                        ],
                      ),
                    );
                    if (shouldLogout == true) {
                      await supabase.auth.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.logout_outlined,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}