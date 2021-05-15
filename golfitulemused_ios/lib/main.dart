import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golfitulemused/screens/bottom_navigation_screen.dart';
import 'package:golfitulemused/screens/intro_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'components/first_time_screen.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GolfScoreCard());
}


class GolfScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    return MaterialApp(

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.lightBlueAccent,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black, fontSize: 18, fontFamily: "ProximaNova"),
          bodyText2: TextStyle(color: Colors.white, fontSize: 18, fontFamily: "ProximaNova")
        )
      ),
      debugShowCheckedModeBanner: false,
      home: FirstTimeScreen(
          introScreen: MaterialPageRoute(builder: (context) => IntroScreen()),
          landingScreen: MaterialPageRoute(builder: (context) =>BottomNavigationScreen(false)),
      ),
    );
  }
}

