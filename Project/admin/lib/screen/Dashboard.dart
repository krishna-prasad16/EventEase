import 'package:admin/Components/appbar.dart';
import 'package:admin/Components/sidebar.dart';
import 'package:admin/screen/cater_manage.dart';
import 'package:admin/screen/complaints.dart';
import 'package:admin/screen/deco_manage.dart';
import 'package:admin/screen/district.dart';
import 'package:admin/screen/event_type.dart';
import 'package:admin/screen/place.dart';
import 'package:admin/screen/profile.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // const Center(child: Text('Dashboard Content')),
    Profile(),
    DecoManage(),
    Catering(),
    ManageDistrict(),
    Place(),
    ManageEvent(),
    Complaints(),
    const Center(child: Text('Settings Content')),
  ];

  void onSidebarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Row(
          children: [
            Expanded(
                flex: 1,
                child: SideBar(
                  onItemSelected: onSidebarItemTapped,
                )),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Appbar1(),
                  _pages[_selectedIndex],
                ],
              ),
            )
          ],
        ));
  }
}
