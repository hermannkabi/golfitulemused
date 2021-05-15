import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:golfitulemused/components/button.dart';
import 'package:golfitulemused/data/courses.dart';


class AddDataCoordinates extends StatefulWidget {
  @override
  _AddDataCoordinatesState createState() => _AddDataCoordinatesState();
}

class _AddDataCoordinatesState extends State<AddDataCoordinates> {



  TextEditingController controllerLong = TextEditingController();
  TextEditingController controllerLat = TextEditingController();
  int currentHole = 1;
  GolfCourse course;
  List<String> longitudes = [];
  List<String> latitudes = [];
  int index = 0;


  List<DropdownMenuItem<int>>getCoursesWithoutCoords(){
    List<GolfCourse> courses = Courses().courses;
    List<DropdownMenuItem<int>> toReturn = [];
    toReturn.add(DropdownMenuItem(child: Text("Vali väljak"),));
    for(int i = 0; i<courses.length; i++){
      GolfCourse course = courses.elementAt(i);
      if(course.locationEnabled == false) toReturn.add(
        DropdownMenuItem<int>(child: Text(course.name), value: i,),
      );
    }
    return toReturn;
  }

  List<GolfCourse>getCoursesWithoutCoordsAsCourse(){
    List<GolfCourse> courses = Courses().courses;
    List<GolfCourse> toReturn = [];
    for(GolfCourse course in courses){
      if(course.locationEnabled == false) toReturn.add(course);
    }
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Text("Lisa väljakule lipukoordinaate"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Visibility(
              visible: currentHole != 1,
              child: Text((course ?? GolfCourse(name: "Laeb...")).name),
            ),
            Visibility(
              visible: currentHole == 1,
              child: DropdownButton<int>(
                value: index ,
                items: getCoursesWithoutCoords(),
                onChanged: (golfCourseIndex){
                  setState(() {
                    index = golfCourseIndex;
                    course = Courses().courses.elementAt(index);
                  });
                },
              ),
            ),
            SizedBox(height: 40,),
            Visibility(
              visible: index != null ,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    Text("Koordinaadid: RADA $currentHole"),
                    SizedBox(height: 15,),
                    TextField(
                      controller: controllerLong,
                      autocorrect: false,
                      decoration: InputDecoration(hintText: "Rada $currentHole. Lisa lipu pikkuskraad (ujukomaarv punktiga, lõunapikkus negatiivne)"),
                    ),
                    SizedBox(height: 10,),
                    TextField(
                      controller: controllerLat,
                      autocorrect: false,
                      decoration: InputDecoration(hintText: "Rada $currentHole. Lisa lipu laiuskraad (ujukomaarv punktiga, läänelaius negatiivne)"),
                    ),
                    Button(
                      text: "Lisa",
                      color: Colors.green,
                      onPressed: ()async{
                        if(controllerLong.text.isNotEmpty && controllerLat.text.isNotEmpty){
                          if(course.holes.length >= currentHole+1){
                            longitudes.add(controllerLong.text);
                            latitudes.add(controllerLat.text);
                            setState(() {
                              currentHole ++;
                            });
                            controllerLong.clear();
                            controllerLat.clear();
                          }else{
                            longitudes.add(controllerLong.text);
                            latitudes.add(controllerLat.text);
                            String emailSubject = "Lisa andmeid - lisa olemasolevale väljakule lipukoordinaadid";
                            String emailBody = "Lisan lipukoordinaadid väljakule ${course.name} (PAR ${course.par}):\n";
                            for(int i = 0; i<longitudes.length; i++){
                              emailBody += "Rada ${i+1}: [${longitudes[i]}, ${latitudes[i]}]\n";
                            }
                            final Email email = Email(
                              subject: emailSubject,
                              body: emailBody,
                              recipients: ["inquiries.kabiapps@gmail.com"],
                              isHTML: false,
                            );
                            await FlutterEmailSender.send(email);

                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
