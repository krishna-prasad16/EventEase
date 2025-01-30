import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  final Function(int) onItemSelected;
  const SideBar({super.key, required this.onItemSelected});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final List<String> pages = [
    "profile",
    " Decorators",
    " Catering",
    " District",
    " Place",
    " EventType",
    " Complaints",
  ];
  final List<IconData> icons = [
    Icons.person,
    Icons.admin_panel_settings_sharp,
    Icons.food_bank,
    Icons.place,
    Icons.place_outlined,
    Icons.add_chart_sharp,
    Icons.message
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // height:700,
     
      decoration: BoxDecoration(
       
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(30),
        //   bottomLeft: Radius.circular(30),
        // ),
        color: Color(0xff065a60), // Set a solid color
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image.asset(
              //   'assets/logo.png',
              //   width: 50,
              //   height: 70,
              // ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        widget.onItemSelected(index);
                      },
                      leading: Icon(icons[index], color: Colors.white),
                      title: Text(pages[index],
                          style: TextStyle(color: Colors.white)),
                    );
                  }),
            ],
          ),
          ListTile(
            leading: Icon(Icons.logout_outlined, color: Colors.white),
            title: Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
