import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:golfitulemused/data/courses.dart';
import 'package:golfitulemused/screens/preview_course_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ChooseCourseScreen extends StatefulWidget {

  @override
  _ChooseCourseScreenState createState() => _ChooseCourseScreenState();
}

class _ChooseCourseScreenState extends State<ChooseCourseScreen> {

  Courses _courses = Courses();
  SharedPreferences prefs;
  bool isGameInProgress = false;


  void onTapAction(int index){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>PreviewCourseScreen(index)));
  }

  List<ListTile>getListViewChildren(){
    List<GolfCourse>courses = _courses.courses;
    List<ListTile>coursesReturned = [];
    for(int index = 0; index<courses.length;index++){
      GolfCourse course = courses[index];
      List<Tooltip>featureIcons = [];
      if(course.maps != null){featureIcons.add(Tooltip(message: "Sellel rajal on rajakaardid", child: Icon(Icons.map_sharp, color: Colors.white70, size: 20,)));}
      if(course.locationEnabled){featureIcons.add(Tooltip(message: "Sellel rajal on võimalik näha sinu hetkekaugust august", child: Icon(FontAwesomeIcons.locationArrow, color: Colors.white70, size: 16,)));}
      coursesReturned.add(
          ListTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 15, right: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(course.image),
                          fit: BoxFit.cover
                        ),
                      ),
                      height: 110,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Align(alignment: Alignment.centerLeft, child: Text(course.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.left,)),
                ],
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 15, right: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text("${course.distance[0]}-${course.distance[course.distance.length-1]}m", style: TextStyle(color: Colors.white70),),
                      SizedBox(width: 6,),
                      Row(children: featureIcons,),
                    ],
                  ),
                  SizedBox(height: 2,),
                  Align(alignment: Alignment.centerLeft, child: Text("PAR " + course.par.toString(), style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),)),
                  SizedBox(height: 12,),
                ],
              ),
            ),
            onTap: (){
              onTapAction(index);
            },
          )
      );
    }
    return coursesReturned;
  }

  Future<SharedPreferences>getPrefs()async=>await SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    getPrefs().then((value){
      prefs = value;
      isGameInProgress = gameInProgress();
      print(isGameInProgress);
    });
  }

  bool gameInProgress()=>prefs.getStringList("current_list")!=null;

  @override
  Widget build(BuildContext context) {
    setState(() {
      getPrefs().then((value) {
        setState(() {
          isGameInProgress = gameInProgress();
        });
      });
    });
    return isGameInProgress ? Scaffold(

      body: Center(
        child: Text("Sa ei saa alustada uut mängu, enne kui lõpetad praegu käimasoleva", textAlign: TextAlign.center,),
      ),
    ) : Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.lightBlue, Colors.lightBlueAccent, Colors.lightBlueAccent[400], Colors.lightBlue[600]]
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 9.0),
                child: Text("Vali ${_courses.courses.length} väljaku seast", style: TextStyle(color: Colors.white70, fontFamily: "ProximaNova", fontSize: 35, fontWeight: FontWeight.w700),),
              ),

              Expanded(
                child: ListView(
                  children: getListViewChildren(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
