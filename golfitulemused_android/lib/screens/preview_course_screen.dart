import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:golfitulemused/components/button.dart';
import 'package:golfitulemused/data/courses.dart';
import 'package:golfitulemused/data/networking.dart';
import 'package:golfitulemused/screens/hole_screen.dart';
import 'package:url_launcher/url_launcher.dart';



class PreviewCourseScreen extends StatefulWidget {

  final int index;

  PreviewCourseScreen(this.index);

  @override
  _PreviewCourseScreenState createState() => _PreviewCourseScreenState();
}

class _PreviewCourseScreenState extends State<PreviewCourseScreen> {

  Courses _courses = Courses();
  GolfCourse course;
  dynamic temperature = "Oota";

  @override
  void initState() {
    super.initState();
    course = _courses.courses[widget.index];
    getWeatherInfo().then((value) {
      if(value!=-274){
        setState(() {
          temperature = value;
        });
      }
    });



  }
  
  // ignore: missing_return
  Future<int> getWeatherInfo()async{
    int temp = await Networking().getWeatherAtCourse(course.weather);
    if(temp!=274){
      return temp;
    }
  }


  List<ListTile>getDialogOptions(){
    List<ListTile>dialogOptions = [];
    for(int i = 0; i<course.distance.length;i++){
      dialogOptions.add(
          ListTile(

            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CircleAvatar(backgroundColor: course.teeColors[i],),
                SizedBox(width: 5,),
                Expanded(child: Text(course.tees[i], )),
                Text(course.distance[i].toString()+"m", style: TextStyle(color: Colors.grey[800]),)

              ],
            ),
            onTap: (){
              Navigator.pop(context, i);
            },
          )
      );

    }
    return dialogOptions;
  }

  Future<int> showAlertDialog(String title){

    return showDialog(context: context, builder: (_)=>SimpleDialog(
      backgroundColor: Colors.grey,
      title: Text(title),
      children: getDialogOptions(),

    ));





  }


  List<ListTile> getListTiles(){
    Map contacts = course.contactUs;
    List<ListTile>listTiles = [];
    for(int index = 0; index<contacts.length; index++){

      listTiles.add(ListTile(
        onTap: ()async{
          await launch(contacts.keys.toList()[index][1]);
        },
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              contacts[contacts.keys.toList()[index]],
              Text(contacts.keys.toList()[index][0], style: TextStyle(color: Colors.grey[800]),),
            ],
          ),
        ),
      ));
    }
    return listTiles;
  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(course.image)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("${course.name}", style: TextStyle(color: Colors.white70, fontSize: 35, fontFamily: "ProximaNova"),),
                    SizedBox(height: 10,),
                    Text("PAR ${course.par}", style: TextStyle(color: Colors.white70, fontSize: 20, fontFamily: "ProximaNova"),),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Visibility(visible: temperature!="Oota",child: Text("$temperature°C", style: TextStyle(color: Colors.white70, fontSize: 50, fontFamily: "ProximaNova", fontWeight: FontWeight.bold),)),

                      Container(
                          height: 150,
                          child: Scrollbar(isAlwaysShown: true, thickness: 5, child: SingleChildScrollView(child: Text(course.description, style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: "ProximaNova"),)))),

                      Visibility(
                        visible: course.contactUs!=null,
                        child: Button(
                          text: "Võta ühendust",
                          onPressed: (){
                            showDialog(context: context,
                            builder: (context)=>SimpleDialog(
                              backgroundColor: Colors.grey,
                              title: Text("Võta ühendust - ${Courses().courses[widget.index].name}"),
                              children: getListTiles(),

                            )
                            );
                          },
                          color: Colors.green,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 38.0),
                      child: Button(
                        text: "Mängi",
                        onPressed: ()async{
                          LocationPermission permission = await Geolocator.checkPermission();
                          if(permission != LocationPermission.always || permission !=  LocationPermission.whileInUse){
                            LocationPermission newPermission = await Geolocator.requestPermission();
                            if(newPermission == LocationPermission.deniedForever){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Palun luba seadetest asukoha kasutamine!"), action: SnackBarAction(label: "AVA SEADED", onPressed: (){
                                AppSettings.openLocationSettings();
                              },),));
                              return;
                            } else if(newPermission == LocationPermission.denied ){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mängimiseks on vaja lubada sinu asukoha jälgimine"), action: SnackBarAction(
                                label: "LUBA",
                                onPressed: ()async{
                                  if(await Geolocator.checkPermission() != LocationPermission.deniedForever){
                                    await Geolocator.requestPermission();
                                  }
                                  else{
                                    AppSettings.openAppSettings();
                                  }
                                },
                              ),));
                              return;
                            }
                          }
                          int tees =await showAlertDialog("Vali tiid");
                          if(tees!=null){
                            Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context)=>HoleScreen(index: widget.index, teeIndex: tees)
                            ));
                          }
                        },
                        color: Colors.lightBlue,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
