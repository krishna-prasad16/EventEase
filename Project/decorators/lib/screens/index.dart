

import 'package:flutter/material.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            width: 400,
            height: 70,
            color: Color(0xff065a60),
            child: Row(
              children: [
              Image.asset(
                'assets/logo.png',
                width: 270,
                height: 60,
              ),
              SizedBox(width: 1000),
              Row(
                children: [
                  TextButton.icon(
                      onPressed: () {},
                      label: Text(
                        'Sign In',
                        style: TextStyle(color: Colors.black),
                      ),
                      icon: Icon(
                        Icons.login_rounded,
                        color: Colors.black,
                      )),
                  TextButton.icon(
                      onPressed: () {},
                      label: Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.black),
                      ),
                      icon: Icon(
                        Icons.logout_outlined,
                        color: Colors.black,
                      ))
                ],
              )
            ]),
          ),
          Container(
            height: 600,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/img.jpg'), fit: BoxFit.cover),

            ),
            child: Expanded(
              child: Container(
                  color: const Color.fromARGB(207, 255, 255, 255),
                  child: Center(
                    child: Text("Planning with Heart"),
                  ),
              ),
            )
          )
        ],
      ),
    );
  }
}