import 'package:flutter/material.dart';

class Appbar1 extends StatelessWidget {
  const Appbar1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SizedBox(height: 15),
        Container(
            height: 50,
            decoration: BoxDecoration(color: Color(0xffccdad1)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Admin",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  width: 40,
                )
              ],
            )),
      ],
    );
  }
}
