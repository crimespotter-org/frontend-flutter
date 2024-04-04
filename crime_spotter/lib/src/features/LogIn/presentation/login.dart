import 'package:flutter/material.dart';

import '../../../shared/4data/const.dart';

class _LogIn extends State<LogIn> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      Navigator.pushNamed(context, UIData.homeRoute);
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/LogIn.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Center(
            child: Card(),
          ),
        ),
      ),
    );
  }
}

//Login
class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogIn();
}
