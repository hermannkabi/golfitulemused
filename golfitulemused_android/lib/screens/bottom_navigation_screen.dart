import 'package:flutter/material.dart';
import 'package:golfitulemused/screens/choose_course_screen.dart';
import 'package:golfitulemused/screens/home_screen.dart';
import 'package:golfitulemused/screens/my_rounds_screen.dart';
import 'package:golfitulemused/screens/settings_screen.dart';

class BottomNavigationScreen extends StatefulWidget {

  final bool isFirstTime;

  BottomNavigationScreen(this.isFirstTime);

  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {


  @override
  void initState() {
    super.initState();
    setState(() {
      isFirstTime = widget.isFirstTime;
      screens = [
        SettingsScreen(),
        MyRoundsScreen(),
        HomeScreen(isFirstTime),
        ChooseCourseScreen(),
      ];
    });
  }


  bool isFirstTime = false;
  int selectedIndex = 2;



  List<Widget>screens = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.lightBlueAccent,
        backgroundColor: Colors.white70,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.settings, color: Colors.grey,),activeIcon: Icon(Icons.settings, color: Colors.blue,), label: "Seaded"),
          BottomNavigationBarItem(icon: Icon(Icons.save, color: Colors.grey,), activeIcon: Icon(Icons.save, color: Colors.blue,), label: "Minu ringid",),
          BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.grey,),activeIcon: Icon(Icons.home, color: Colors.blue,), label: "Kodu"),
          BottomNavigationBarItem(icon: Icon(Icons.golf_course, color: Colors.grey,), activeIcon: Icon(Icons.golf_course, color: Colors.blue,), label: "Alusta mängu"),
        ],
        currentIndex: selectedIndex,
        onTap: (index){
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      body: screens[selectedIndex],
    );
  }
}
