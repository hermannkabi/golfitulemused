import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:golfitulemused/components/button.dart';
import 'package:golfitulemused/data/courses.dart';
import 'package:golfitulemused/screens/hole_screen.dart';
import 'package:golfitulemused/screens/preview_course_screen.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {

  final bool isFirstTime;
  HomeScreen(this.isFirstTime);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String name = "";
  SharedPreferences prefs;
  bool resume = false;
  String courseName = "- ";
  bool isConnected = true;
  bool locationServiceEnabled = false;
  String closestCourseName;
  int closestCourseIndex;
  double closestCourseDistance;


  void getClosestCourse()async{
    List<GolfCourse>courses = Courses().courses;
    Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    for(int i = 0; i<courses.length;i++){
      double distanceBetween = Geolocator.distanceBetween(currentPosition.latitude, currentPosition.longitude, courses[i].location[0], courses[i].location[1]);
      if(closestCourseDistance == null || closestCourseDistance > distanceBetween){
        closestCourseIndex = i;
        closestCourseDistance = distanceBetween;
      }
    }
  }


  @override
  void initState() {
    super.initState();
      Geolocator.checkPermission().then((value) {
        if(value != LocationPermission.denied && value != LocationPermission.deniedForever){
          setState(() {
            locationServiceEnabled = true;
          });
          getClosestCourse();
        }
      });


      getName().then((value){
      setState(() {
        name = value;
      });
    });
    getPrefs().then((value)async{

      ConnectivityResult result  = await Connectivity().checkConnectivity();


      setState((){
        isConnected = result != ConnectivityResult.none;
        prefs = value;
        print("Times now: ${prefs.getInt("opening_times")}");
        print("Times needed: ${prefs.getInt("opening_req")}");
        courseName = prefs.getString("current_course")??"";
        prefs.getInt("opening_times")??setOpenTimes();
        prefs.getBool("popup_wanted") ? addOneOpening():print("Popup not wanted (N)");
        if(prefs.getInt("opening_times") >= prefs.getInt("opening_req") && prefs.getBool("popup_wanted")==true){
          prefs.setBool("popup_wanted", false).whenComplete(() => InAppReview.instance.requestReview());
        }
      });
    });
  }

  Future<void>setOpenTimes()async{
    await prefs.setInt("opening_times", 1);
    await prefs.setInt("opening_req", 5);
    await prefs.setBool("popup_wanted", true);
  }
  Future<void>addOneOpening()async{
    await prefs.setInt("opening_times", prefs.getInt("opening_times")+1);
  }

  Future<String>getName()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("name");
  }

  Future<SharedPreferences>getPrefs()async=>await SharedPreferences.getInstance();




  @override
  Widget build(BuildContext context) {
    getName().then((value) {
      setState(() {
        name = value;
      });
    });
    getPrefs().then((value){
      setState(() {
        prefs = value;
        resume = prefs.getStringList("current_list")!=null;
      });
    });

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<ConnectivityResult>(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: snapshot.data == ConnectivityResult.none || !isConnected,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.perm_scan_wifi, color: Colors.redAccent[200],),
                      SizedBox(width: 15,),
                      Expanded(child: AutoSizeText("Tundub, et sa pole internetiga ühendatud. Mõned võimalused ei pruugi töötada", textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey[800]), maxLines: 2,))
                    ],

                  ),
                ),
              ),
            SizedBox(height: 70,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 35),
              child: Center(child: Text("Tere tulemast${widget.isFirstTime?"":" tagasi"}, ${name ?? "külastaja"}",textAlign: TextAlign.center, style: TextStyle(fontFamily: "ProximaNova", fontSize: 25, color: Colors.white70, fontWeight: FontWeight.w700))),
            ),
              SizedBox(height: 40,),
              Visibility(
                visible: resume,
                child: Column(
                  children: [
                    Button(
                      text: "Jätka - $courseName",
                      color: Colors.greenAccent,
                      onPressed: ()async{
//                await prefs.setStringList("current_list", null);
//                await prefs.setStringList("current_tees", null);
//                await prefs.setStringList("current_course", null);
//                await prefs.setStringList("current_gir", null);
                        for(int i = 0; i<Courses().courses.length; i++){
                          GolfCourse course = Courses().courses[i];
                          if(course.name==courseName){

                            Navigator.push(context, MaterialPageRoute(
                              builder: (context)=>HoleScreen(
                                index: i,
                                teeIndex: prefs.getInt("current_tees"),
                              )
                            ));
                          }
                        }


                      },
                    ),
                    SizedBox(width: 5,),
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: ()async{
                        showCupertinoModalPopup(context: context, builder: (_)=>CupertinoActionSheet(
                          title: Text("Kustuta?"),
                          message: Text("Kas soovid ringi katkestada ja kustutada"),
                          actions: [
                            CupertinoActionSheetAction(
                              child: Text("Kustuta", style: TextStyle(color: Colors.red),),
                              onPressed: ()async{
                                await prefs.remove("current_list");
                                await prefs.remove("current_tees");
                                await prefs.remove("current_course");
                                await prefs.remove("current_gir");
                                Navigator.pop(context);
                              },
                            ),

                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: Text("Tagasi"),
                            onPressed: (){Navigator.pop(context);},
                          ),
                        ));
                      },
                    ),
                    SizedBox(width: 4,),
                  ],
                ),
              ),
              Spacer(),

              Visibility(
                visible: locationServiceEnabled && !resume,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, CupertinoPageRoute(builder: (_)=>PreviewCourseScreen(closestCourseIndex)));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        gradient: LinearGradient(
                          colors: [Colors.teal[700], Colors.teal[800]],
                        ),
                        image: DecorationImage(
                          image: NetworkImage(Courses().courses[closestCourseIndex ?? 0].image),
                          fit: BoxFit.cover
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("SOOVITUS", style: TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 1)]),),
                                SizedBox(height: 10,),
                                Text("LÄHIM RADA (${(closestCourseDistance ?? 0) < 1000 ? (closestCourseDistance ?? 0).toStringAsFixed(0) : ((closestCourseDistance ?? 0) / 1000).toStringAsFixed(1)}${(closestCourseDistance ?? 0) < 1000 ? "M" : "KM"})", style: TextStyle(color: Colors.grey[300]),),
                              ],
                            ),
                            Spacer(),
                            Expanded(child: Text("${(Courses().courses[closestCourseIndex ?? 0].name)??""}", overflow: TextOverflow.clip, style: TextStyle(color: Colors.white),)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
            ],
            );
          },
        ),
        ),
    );
  }
}
