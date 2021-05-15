import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:golfitulemused/components/button.dart';
import 'package:golfitulemused/data/courses.dart';
import 'package:golfitulemused/screens/show_more_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/networking.dart';

class EndRoundScreen extends StatefulWidget {
  final int index;
  final int teeIndex;


  EndRoundScreen({this.index, this.teeIndex});

  @override
  _EndRoundScreenState createState() => _EndRoundScreenState();
}

class _EndRoundScreenState extends State<EndRoundScreen> {

  Future<SharedPreferences> getPrefs()async{

    return await SharedPreferences.getInstance();
  }

  List<ListTile>scorecard = [];
  List<String>scores = [];
  int totalScore = 0;
  bool isSaveRoundVisible = true;
  List<String>currentList = [];
  List<String>currentGir = [];
  int realPAR;
  String notesString;

  void getScores(){
    totalScore = 0;
    scores = currentList;
    scorecard = [];
    realPAR = 0;
    for(int i = 0; i<scores.length;i++){
      //raja number on i+1, listi index on i
      realPAR += Courses().courses[widget.index].holes[i+1][0];
      totalScore += int.parse(scores[i]);
      scorecard.add(
        ListTile(
          leading: Text("${currentGir[i]=="true" ? "GIR" : ""}", style: TextStyle(color: Colors.black),),
          title: Text("Rada ${i+1}"),
          subtitle: Text("PAR ${Courses().courses[widget.index].holes[i+1][0]}"),
          trailing: Text("${currentList[i]}", style: TextStyle(color: int.parse(currentList[i]) <= Courses().courses[widget.index].holes[i+1][0] ? Colors.black : Colors.redAccent),),
        )
      );
    }

  }

  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    getPrefs().then((value)async{
      setState(() {
        prefs = value;
      });
      currentList = prefs.getStringList("current_list");
      currentGir = prefs.getStringList("current_gir");
      await prefs.remove("current_list");
      await prefs.remove("current_tees");
      await prefs.remove("current_course");
      await prefs.remove("current_gir");
      getScores();
    });
  }


  @override
  void dispose() {
    super.dispose();
    disposeAction().then((value) {
      print("Kustutatud: $value");
    });

  }

  Future<int>disposeAction()async{

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    getScores();

    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Colors.lightGreen,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(

              height: MediaQuery.of(context).size.height + 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                    child: AutoSizeText("${Courses().courses[widget.index].name}", style: TextStyle(fontSize: 25, color: Colors.black),maxLines: 1,),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:13, vertical: 8),
                    child: Row(
                      children: <Widget>[
                        Text("PAR ${Courses().courses[widget.index].par}${realPAR==Courses().courses[widget.index].par ? "" : ", PAR sulle $realPAR"}", style: TextStyle(fontSize: 25, color: Colors.black),),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Sa mängisid: ", style: TextStyle(color: Colors.black, fontSize: 30),),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: Column(
                      children: <Widget>[
                        Text("$totalScore lööki", style: TextStyle(color: Colors.black, fontSize: 27),),
                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text("${realPAR>totalScore ? "-" : realPAR == totalScore ? "" : "+"} ${totalScore - realPAR}", style: TextStyle(color: realPAR>totalScore ? Colors.green[800] : realPAR == totalScore ? Colors.black : Colors.red, fontSize: 27),),
                        ),
                        Button(
                          color: Colors.blue,
                          text: "Täpsem tulemus",
                          onPressed: (){

                            Navigator.push(context, MaterialPageRoute(
                              builder: (context)=>ShowMoreScreen(scorecard, widget.index, currentList, currentGir, realPAR)
                            ));
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 30,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: TextField(
                      decoration: InputDecoration(hintText: "Lisa märkmeid"),
                      minLines: 5,
                      maxLines: 8,
                      onChanged: (val){
                        setState(() {
                          notesString = val;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 15,),
                  Button(
                    text: "või lisa märkmetest pilt",
                    color: Colors.blueGrey,
                    onPressed: ()async{
                      List<String> idList = prefs.getStringList("id_list") ?? [];
                      int largestId = 0;
                      for(int i = 0; i<idList.length;i++){
                        if(int.parse(idList[i])>largestId){
                          largestId = int.parse(idList[i]);
                        }
                      }
                      largestId++;
                      PickedFile pickedFile = await ImagePicker().getImage(source: kReleaseMode ? ImageSource.camera : ImageSource.gallery);
                      if(pickedFile != null){
                        String appDocs = (await getApplicationDocumentsDirectory()).path;
                        var fileName = basename(pickedFile.path);
                        File(pickedFile.path).copy(appDocs+"/$fileName");
                        await prefs.setString("image_note$largestId", appDocs+"/$fileName");
                      }
                    }
                  ),
                  SizedBox(height: 40,),
                  Builder(
                    builder:(context)=> isSaveRoundVisible ? Button(
                      color: Colors.lightGreen[800],
                      text: "Salvesta ja lahku",
                      onPressed: ()async{



                        List<String>savedRounds = [];
                        String formattedDt = DateFormat("dd.MM.yyyy").format(DateTime.now());
                        savedRounds = prefs.getStringList("saved_rounds") ?? [];
                        List<String> idList = prefs.getStringList("id_list") ?? [];
                        int largestId = 0;
                        for(int i = 0; i<idList.length;i++){
                          if(int.parse(idList[i])>largestId){
                            largestId = int.parse(idList[i]);
                          }
                        }
                        largestId++;
                        idList.add(largestId.toString());
                        if(notesString != null){
                          await prefs.setString("string_note$largestId", notesString);
                        }
                        savedRounds.add("$formattedDt väljakul ${Courses().courses[widget.index].name} ${realPAR==Courses().courses[widget.index].par ? "": "- ${(currentList??[]).length} rada"}");
                        await prefs.setStringList("id_list", idList);
                        await prefs.setStringList("gir$largestId", currentGir);
                        await prefs.setStringList("saved_rounds", savedRounds);
                        await prefs.setStringList("list$largestId", currentList);
                        await prefs.setString("tees$largestId", Courses().courses[widget.index].tees[widget.teeIndex]);

                        User user = FirebaseAuth.instance.currentUser;


                        if(user != null){
                          print("Laadis pilve");
                          Networking().addRoundToCloud(FirebaseAuth.instance.currentUser.uid, context, largestId);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ring on automaatselt pilve üles laetud!"),));
                        }else{
                          await Future.delayed(Duration(milliseconds: 200));
                          user = FirebaseAuth.instance.currentUser;
                          if(user != null){
                            print("Laadis pilve");
                            Networking().addRoundToCloud(FirebaseAuth.instance.currentUser.uid, context, largestId);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ring on automaatselt pilve üles laetud!"),));
                          }
                        }

                        setState(() {
                          isSaveRoundVisible = false;
                        });
                        Navigator.of(context).pop();

                      },
                    ): Button(
                      text: "✓ Salvestatud",
                      color: Colors.lightGreen,
                      onPressed: (){},
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
