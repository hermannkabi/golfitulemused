import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:golfitulemused/components/button.dart';
import 'package:golfitulemused/data/courses.dart';


class AddDataMap extends StatefulWidget {
  @override
  _AddDataMapState createState() => _AddDataMapState();
}

class _AddDataMapState extends State<AddDataMap> {



  TextEditingController controller = TextEditingController();
  int currentHole = 1;
  GolfCourse course;
  List<String> links = [];
  int index = 0;


  List<DropdownMenuItem<int>>getCoursesWithoutMaps(){
    List<GolfCourse> courses = Courses().courses;
    List<DropdownMenuItem<int>> toReturn = [];
    toReturn.add(DropdownMenuItem<int>(child: Text("Vali väljak"), value: 0,));
    for(int i = 0; i<courses.length; i++){
      GolfCourse course = courses[i];
      if(course.maps == null) toReturn.add(DropdownMenuItem<int>(child: Text(course.name), value: i,));
    }
    return toReturn;
  }

  List<GolfCourse>getCoursesWithoutMapsAsCourse(){
    List<GolfCourse> courses = Courses().courses;
    List<GolfCourse> toReturn = [];
    for(GolfCourse course in courses){
      if(course.maps == null) toReturn.add(course);
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
        title: Text("Lisa väljakule rajakaarte"),
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
              child: DropdownButton(
                value: index,
                items: getCoursesWithoutMaps(),
                onChanged: (i){
                  setState(() {
                    index = i;
                    course = Courses().courses[i];
                  });
                },
              ),
            ),
            SizedBox(height: 40,),
            Visibility(
              visible: course != null ,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    Text("Pildilink rajakaardile: RADA $currentHole"),
                    SizedBox(height: 15,),
                    TextField(
                      controller: controller,
                      autocorrect: false,
                      decoration: InputDecoration(hintText: "Rada $currentHole. Kopeeri siia pildilink rajakaardile"),
                    ),
                    Button(
                      text: "Lisa",
                      color: Colors.green,
                      onPressed: ()async{
                        if(controller.text.isNotEmpty){
                          if(course.holes.length >= currentHole+1){
                            links.add(controller.text);
                            setState(() {
                              currentHole ++;
                            });
                            controller.clear();
                          }else{
                            links.add(controller.text);
                            String emailSubject = "Lisa andmeid - lisa olemasolevale väljakule rajakaarte";
                            String emailBody = "Lisan rajakaardid väljakule ${course.name} (PAR ${course.par}):\n";
                            for(int i = 0; i<links.length; i++){
                              emailBody += "Rada ${i+1}: ${links[i]}\n";
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
