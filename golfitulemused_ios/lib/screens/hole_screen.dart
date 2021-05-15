import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:golfitulemused/components/button.dart';
import 'package:golfitulemused/components/round_button.dart';
import 'package:golfitulemused/data/courses.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_navigation_screen.dart';
import 'end_round_screen.dart';

class HoleScreen extends StatefulWidget {
  final int index;
  final int teeIndex;

  HoleScreen({this.index, this.teeIndex});

  @override
  _HoleScreenState createState() => _HoleScreenState();
}

class _HoleScreenState extends State<HoleScreen> {
  GolfCourse course;
  String greyImage = "https://i.pinimg.com/originals/5d/33/a1/5d33a10d3d20c73125e66a1f3cb4a974.jpg";

  bool isGir = false;
  int holeNr = 1;
  int shotsNr;
  int index;
  String holeMap;
  SharedPreferences prefs;
  bool isConnected = true;
  bool tooFar = false;

  void newHole() {
    setState(() {
      isGir=false;
      holeNr++;
      shotsNr = course.holes[holeNr][0];
      try{
        holeMap = course.maps[holeNr-1] ?? greyImage;
      }catch(e){
        holeMap = greyImage;
      }
    });
  }



  @override
  void initState() {
    super.initState();
    index = widget.index;
    course = Courses().courses[widget.index];
    shotsNr = course.holes[holeNr][0];
    try{
      holeMap = Courses().courses[widget.index].maps[0] ?? greyImage;
    }catch(e){
      holeMap = greyImage;
    }
    initAction().then((value) {
      setState(() {
        prefs = value;
        holeNr = (prefs.getStringList("current_list")??[]).length+1;
        checkConnectivity().then((value){
          isConnected = value;
        });
      });
      setCurrentCourse().then((value) {
        print(value);
      });
    });

//    print(course.holes[hole number][1 to get distances, 0 to get par][widget.tees]);
  }


  Future<bool>checkConnectivity()async=>(await Connectivity().checkConnectivity()) == ConnectivityResult.none;

  Future<int>setCurrentCourse()async{
    await prefs.setString("current_course", course.name);
    await prefs.setInt("current_tees", widget.teeIndex);

    return 0;
  }


  Future<SharedPreferences> initAction() async =>
      await SharedPreferences.getInstance();

  Future<bool> _onWillPop() async {
    return (await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Oled kindel?'),
            content: Text(
                'Oled kindel, et tahad äpi sulgeda. See lõpetab su praeguse ringi ilma salvestamata'),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Ei'),
              ),
              CupertinoDialogAction(
                onPressed: () async{
                  await prefs.setStringList("current_list", null);
                  await prefs.setStringList("current_tees", null);
                  await prefs.setStringList("current_course", null);
                  await prefs.setStringList("current_gir", null);
                  Navigator.of(context).pop(true);
                  },
                child: new Text('Jah, tahan lõpetada'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> showAlertDialog(String title, Widget content, [bool barrierDismissible = true]) {
    return showCupertinoDialog(
      barrierDismissible: barrierDismissible,
        context: context,
        builder: (context) => CupertinoAlertDialog(

              title: Text(title),
              content: content,
              actions: <Widget>[
                MaterialButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  bool checkForMaps(){
    try{
      // ignore: unnecessary_statements
      course.maps[holeNr-1];
      return true;
    }catch(e){
      return false;
    }
  }


  void isCheckVisible(){
    initAction().then((value) {
      prefs = value;
      if((prefs.getStringList("current_list")??[]).length==0){
        setState(() {
          isDoneVisible = false;
        });
      }else{
        setState(() {
          isDoneVisible = true;
        });
      }
    });
  }


  bool isDoneVisible = false;

  @override
  Widget build(BuildContext context) {
    checkConnectivity().then((value) {
      isConnected = value;
    });
    isCheckVisible();

    return checkForMaps() == true ? Scaffold(
      backgroundColor: Colors.lightBlue[800],
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.lightBlue[200], Colors.lightBlue[300], Colors.lightBlueAccent, Colors.lightBlueAccent[400], Colors.lightBlue[600], Colors.lightBlue[800]]
          ),
        ),
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: SafeArea(child: SingleChildScrollView(
            child: Container(
              child: StreamBuilder<Position>(
                stream: Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best),
                builder: (context, snapshot){
                if(!snapshot.hasData) return CircularProgressIndicator();
                int distanceFromTarget = course.locationEnabled ? Geolocator.distanceBetween(snapshot.data.latitude, snapshot.data.longitude, course.holes[holeNr][2][0], course.holes[holeNr][2][1]).toInt() : 0;
                Future.delayed(Duration.zero).whenComplete(() => setState((){
                  tooFar = course.locationEnabled ? (distanceFromTarget > (course.holes[holeNr][1][widget.teeIndex])) : false;
                }));

                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: AutoSizeText(
                                  course.name, style: TextStyle(fontSize: 23), maxLines: 1,
                                ),
                              ),
                              Visibility(
                                visible: !isDoneVisible,
                                child: IconButton(icon: Icon(Icons.close, color: Colors.white,), onPressed: (){Navigator.pop(context);},),
                              ),
                              Visibility(
                                visible: isDoneVisible,
                                child: IconButton(icon: Icon(Icons.exit_to_app, color: Colors.white, size: 30,),onPressed: ()async{
                                  String shouldContinue = await showCupertinoModalPopup(context: context,
                                      builder: (context)=>CupertinoActionSheet(
                                        title: Text("Lõpetad ringi?"),
                                        message: Text("Kas oled kindel, et tahad ringi lõpetada?"),
                                        actions: <Widget>[
                                          CupertinoActionSheetAction(onPressed: (){Navigator.pop(context, "save");}, child: Text("Lõpeta ja salvesta")),
                                          CupertinoActionSheetAction(onPressed: (){Navigator.pop(context, "delete");}, child: Text("Lõpeta ja kustuta", style: TextStyle(color: Colors.red),)),
                                        ],
                                        cancelButton: CupertinoActionSheetAction(onPressed: (){Navigator.pop(context);}, child: Text("Tagasi")),
                                      )
                                  );
                                  if(shouldContinue == "save"){
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EndRoundScreen(index: widget.index, teeIndex: widget.teeIndex,)));
                                  } else if(shouldContinue == "delete"){
                                    await prefs.remove("current_list");
                                    await prefs.remove("current_tees");
                                    await prefs.remove("current_course");
                                    await prefs.remove("current_gir");
                                    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_)=>BottomNavigationScreen(false)));
                                  }
                                },),
                              ),
                            ],
                          ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("Rada $holeNr", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold), textAlign: TextAlign.start,),
                                  SizedBox(height: 15,),
                                  Text(tooFar || !course.locationEnabled ? "${course.holes[holeNr][1][widget.teeIndex]}m" : distanceFromTarget.toString()+"m", style: TextStyle(fontSize: 50),),
                                  Text("PAR ${course.holes[holeNr][0]}", style: TextStyle(fontSize: 30)),
                                ],
                              ),
                              SizedBox(height: 60,),
                              Center(
                                child:Column(
                                  children: <Widget>[
                                    Text("$shotsNr", style: TextStyle(fontSize: 60),),
                                    SizedBox(height: 4,),
                                    Text("LÖÖKI", style: TextStyle(color: Colors.grey[300], fontSize: 20),),
                                    SizedBox(height: 15,),
                                    Row(
                                      children: <Widget>[
                                        RoundButton(color: Colors.red[300], onPressed: (){
                                          setState(() {
                                            shotsNr != 1
                                                ? shotsNr--
                                                : print("Not possible");
                                          });
                                        }, child: Icon(Icons.remove, color: Colors.grey[600],)),
                                        SizedBox(width: 20,),
                                        RoundButton(onPressed: (){
                                          setState(() {
                                            shotsNr++;
                                          });
                                        }, color: Colors.green[400], child: Icon(Icons.add, color: Colors.grey[600],),),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 25,),
                              Row(
                                children: <Widget>[
                                  Text("GIR", style: TextStyle(fontSize: 23),),
                                  SizedBox(width: 25,),
                                  Switch(
                                    activeColor: Colors.green[500],
                                    inactiveTrackColor: Colors.blueGrey[400],
                                    inactiveThumbColor: Colors.grey[800],
                                    activeTrackColor: Colors.lime[600],
                                    value: isGir,
                                    onChanged: (value){
                                      setState(() {
                                        isGir=value;
                                      });
                                    },
                                  ),
                                ],
                              ),

                            ],
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: MediaQuery.of(context).size.height * 0.75,
                                child: Image.network(holeMap),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Button(
                      text: holeNr == course.holes.length
                          ? "Lõpeta ring"
                          : "Järgmine!",
                      color: Colors.green,
                      onPressed: ()async{
                        print(prefs.getBool("water_notific"));
                        if (prefs.getBool("water_notific") == true) {
                          holeNr == course.holes.length
                              ? await showAlertDialog("Ja ongi läbi",
                              Text("Palju õnne, mängisid ringi lõpuni"))
                              : ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ära unusta vett juua!"), action: SnackBarAction(label: "ÄRA TULETA MEELDE", onPressed: ()async{
                                await prefs.setBool("water_notific", false);
                          }),));
                        }
                        List<String>scores = prefs.getStringList("current_list") ?? [];
                        List<String>girList = prefs.getStringList("current_gir") ?? [];
                        scores.add(shotsNr.toString());
                        girList.add(isGir.toString());
                        await prefs.setStringList("current_list", scores);
                        await prefs.setStringList("current_gir", girList);

                        holeNr == course.holes.length
                            ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EndRoundScreen(
                              index: widget.index,
                              teeIndex: widget.teeIndex,
                            ),),)
                            : newHole();
                      },
                    ),

                  ],
                );
                },
              ),
            ),
          )),
        ),
      ),
    ) : Scaffold(
    body: WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(course.image),
            fit: BoxFit.cover
          )
        ),
        child: SafeArea(
        child: StreamBuilder<Position>(
          stream: Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best),
          builder: (context, snapshot){
             if(!snapshot.hasData) {
                return Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ));
              }

            int distanceFromTarget = course.locationEnabled ? Geolocator.distanceBetween(snapshot.data.latitude, snapshot.data.longitude, course.holes[holeNr][2][0], course.holes[holeNr][2][1]).toInt() : 0;
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              setState(() {
                tooFar = course.locationEnabled ? distanceFromTarget > course.holes[holeNr][1][widget.teeIndex] * 2 : false;

              });
            });

            return Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(child: AutoSizeText(course.name, style: TextStyle(fontSize: 23), maxLines: 1,)),
                Visibility(
                  visible: !isDoneVisible,
                  child: IconButton(icon: Icon(Icons.close, color: Colors.white,), onPressed: (){Navigator.pop(context);},),
                ),
                Visibility(
                  visible: isDoneVisible,
                  child: IconButton(icon: Icon(Icons.logout, color: Colors.white, size: 30,),onPressed: ()async{
                    String shouldContinue = await showCupertinoModalPopup(context: context,
                        builder: (context)=>CupertinoActionSheet(
                          title: Text("Lõpetad ringi?"),
                          message: Text("Kas oled kindel, et tahad ringi lõpetada?"),
                          actions: <Widget>[
                            CupertinoActionSheetAction(onPressed: (){Navigator.pop(context, "save");}, child: Text("Lõpeta ja salvesta")),
                            CupertinoActionSheetAction(onPressed: (){Navigator.pop(context, "delete");}, child: Text("Lõpeta ja kustuta", style: TextStyle(color: Colors.red),)),
                          ],
                          cancelButton: CupertinoActionSheetAction(onPressed: (){Navigator.pop(context);}, child: Text("Tagasi")),
                        )
                    );
                    if(shouldContinue == "save"){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EndRoundScreen(index: widget.index, teeIndex: widget.teeIndex,)));
                    } else if(shouldContinue == "delete"){
                      await prefs.remove("current_list");
                      await prefs.remove("current_tees");
                      await prefs.remove("current_course");
                      await prefs.remove("current_gir");
                      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_)=>BottomNavigationScreen(false)));
                    }
                  },),
                ),
              ],
          ),
          ),
          Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Text("Rada $holeNr", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),),
          SizedBox(height: 15,),
          Text(tooFar || !course.locationEnabled ? "${course.holes[holeNr][1][widget.teeIndex]}m" :  distanceFromTarget.toString()+"m", style: TextStyle(fontSize: 50),),
          Text("PAR ${course.holes[holeNr][0]}", style: TextStyle(fontSize: 30),),
          ],
          ),
          ),
          Center(
          child: Column(
          children: <Widget>[
          Text("$shotsNr", style: TextStyle(fontSize: 60),),
          SizedBox(height: 4,),
          Text("LÖÖKI", style: TextStyle(color: Colors.grey[100], fontSize: 20),),
          SizedBox(height: 15,),
          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          RoundButton(color: Colors.red[300], onPressed: (){
          setState(() {
          shotsNr != 1
          ? shotsNr--
                : print("Not possible");
          });
          }, child: Icon(Icons.remove, color: Colors.grey[600],)),
          SizedBox(width: 20,),
          RoundButton(color: Colors.green[400], onPressed: (){
          setState(() {
          shotsNr++;
          });
          }, child: Icon(Icons.add, color: Colors.grey[600],))
          ],
          ),
          SizedBox(height: 35,),
          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Text("GIR", style: TextStyle(fontSize: 23),),
          SizedBox(width: 25,),
          Switch(
          activeColor: Colors.green[500],
          inactiveTrackColor: Colors.blueGrey[400],
          inactiveThumbColor: Colors.grey[800],
          activeTrackColor: Colors.lime[600],
          value: isGir,
          onChanged: (value){
          setState(() {
          isGir=value;
          });
          },
          )
          ],
          )

          ],
          ),
          ),
          Spacer(),
          Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Button(
          text: "Järgmine",
          color: Colors.green,
          onPressed: ()async{
          if (prefs.getBool("water_notific") == true) {
          holeNr == course.holes.length
          ? await showAlertDialog("Ja ongi läbi",
          Text("Palju õnne, mängisid ringi lõpuni"))
                : ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ära unusta vett juua!"), action: SnackBarAction(label: "ÄRA TULETA MEELDE", onPressed: ()async{
            await prefs.setBool("water_notific", false);
          }),));
          }
          List<String>scores = prefs.getStringList("current_list") ?? [];
          List<String>girList = prefs.getStringList("current_gir") ?? [];
          scores.add(shotsNr.toString());
          girList.add(isGir.toString());
          await prefs.setStringList("current_list", scores);
          await prefs.setStringList("current_gir", girList);

          holeNr == course.holes.length
          ? Navigator.pushReplacement(
          context,
          MaterialPageRoute(
          builder: (context) => EndRoundScreen(
          index: widget.index,
          teeIndex: widget.teeIndex,
          ),),)
                : newHole();
          },
          ),
          )
          ],
          ),
            );
          },
        ),
        ),
      ),
    ),
    );
  }
}
