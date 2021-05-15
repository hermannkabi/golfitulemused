import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:golfitulemused/screens/log_in.dart';
import 'package:http/http.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String apiKey = "ad908eb430d4f6a82c8a6c3e86867da3";

class Networking{

  Future<int>getWeatherAtCourse(String name)async{
    Response response = await get(Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$name&appid=$apiKey&units=metric"));
    if(response.statusCode==200){
      Map map = jsonDecode(response.body);
      return map["main"]["temp"].toInt();
    }else{
      return -274;
    }
  }


  Future<void>addRoundToCloud(String uid, BuildContext context, int id)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await FirebaseFirestore.instance.collection("users").doc(uid).collection("rounds").add({
      "datetime":DateTime.now(),
      "name": prefs.getStringList("saved_rounds").elementAt(prefs.getStringList("id_list").indexOf(id.toString())),
      "list":prefs.getStringList("list$id"),
      "gir":prefs.getStringList("gir$id"),
      "tees":prefs.getString("tees$id"),
      "string_note":prefs.getString("string_note$id"),
    });

  }


  Future<void>linkRoundsToEmail(String uid, BuildContext context)async{
    print(uid);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>idList = prefs.getStringList("id_list");
    List<String>savedRounds = prefs.getStringList("saved_rounds");
    for(int i = 0; i<idList.length; i++){
      int id = int.parse(idList[i]);
      await FirebaseFirestore.instance.collection("users").doc(uid).collection("rounds").add({
        "name": savedRounds[i],
        "list":prefs.getStringList("list$id"),
        "gir":prefs.getStringList("gir$id"),
        "tees":prefs.getString("tees$id"),
        "string_note":prefs.getString("string_note$id"),
        "datetime":DateTime.now(),
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kõik valmis!")));

  }



  Future<bool>downloadLatestRound(String uid, BuildContext context)async{
    QuerySnapshot coll = await FirebaseFirestore.instance.collection("users").doc(uid).collection("rounds").orderBy("datetime").get();
    if(coll.docs.length == 0){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sul ei ole veel ringe pilve laaditud!")));
      return false;
    }

    DocumentSnapshot latestRound = coll.docs.last;

    List<String>savedRounds = [];
    SharedPreferences prefs  = await SharedPreferences.getInstance();
    savedRounds = prefs.getStringList("saved_rounds") ?? [];
    savedRounds.add(latestRound["name"]);
    List<String> idList = prefs.getStringList("id_list") ?? [];
    int largestId = 0;
    for(int i = 0; i<idList.length;i++){
      if(int.parse(idList[i])>largestId){
        largestId = int.parse(idList[i]);
      }
    }
    largestId++;
    idList.add(largestId.toString());
    await prefs.setStringList("id_list", idList);
    await prefs.setStringList("gir$largestId", latestRound["gir"].cast<String>());
    await prefs.setStringList("saved_rounds", savedRounds);
    await prefs.setStringList("list$largestId", latestRound["list"].cast<String>());
    await prefs.setString("tees$largestId", latestRound["tees"]);
    await prefs.setString("string_note$largestId", latestRound["string_note"] ?? "");
    return true;
  }

  Future<bool>downloadAllRounds(String uid, BuildContext context)async{
    QuerySnapshot coll = await FirebaseFirestore.instance.collection("users").doc(uid).collection("rounds").get();
    if(coll.docs.length == 0){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sul ei ole veel ringe pilve laaditud!")));
      return false;
    }
    for(int i = 0; i<coll.docs.length; i++){
      DocumentSnapshot latestRound = coll.docs[i];
      if(!coll.docs[i].exists){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sul ei ole veel ringe pilve lisatud!")));
        return false;
      }
      List<String>savedRounds = [];
      SharedPreferences prefs  = await SharedPreferences.getInstance();
      savedRounds = prefs.getStringList("saved_rounds") ?? [];
      savedRounds.add(latestRound["name"]);
      List<String> idList = prefs.getStringList("id_list") ?? [];
      int largestId = 0;
      for(int i = 0; i<idList.length;i++){
        if(int.parse(idList[i])>largestId){
          largestId = int.parse(idList[i]);
        }
      }
      largestId++;
      idList.add(largestId.toString());
      await prefs.setStringList("id_list", idList);
      await prefs.setStringList("gir$largestId", latestRound["gir"].cast<String>());
      await prefs.setStringList("saved_rounds", savedRounds);
      await prefs.setStringList("list$largestId", latestRound["list"].cast<String>());
      await prefs.setString("tees$largestId", latestRound["tees"]);
      await prefs.setString("string_note$largestId", latestRound["string_note"] ?? "");
    }
    return true;
  }

  Future<void>uploadRound(GolfRound round, BuildContext context)async{
    bool safeToContinue = FirebaseAuth.instance.currentUser != null;
    if(FirebaseAuth.instance.currentUser == null){
      safeToContinue = await Navigator.push(context, CupertinoPageRoute(builder: (_)=>LoginScreen())) ?? false;
    }
    if(safeToContinue){
      String uid = FirebaseAuth.instance.currentUser.uid;
      await FirebaseFirestore.instance.collection("users").doc(uid).collection("rounds").add({
        "name":round.roundName,
        "tees":round.tees,
        "string_note":round.notes,
        "list":round.holeResults,
        "gir":round.girResults,
        "datetime":DateTime.now(),
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lisatud pilve"),));
  }



  static Future<bool>confirmDecision(BuildContext context, {String title="Kas oled kindel?", String message="See tegevus on tagasivõtmatu", String confirmButton = "Jah, olen kindel"})async{
    bool confirm = false;
    await showCupertinoModalPopup(context: context, builder: (_)=>CupertinoActionSheet(
      title: Text(title),
      message: Text(message),
      actions: [
        CupertinoActionSheetAction(
          child: Text(confirmButton),
          isDestructiveAction: true,
          onPressed: (){
            confirm = true;
            Navigator.pop(context);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Tagasi"),
        onPressed: (){
          confirm = false;
          Navigator.pop(context);
        },
      ),
    ));
    return confirm;
  }


  Future<void>downloadRoundByID(String documentId, String uid, BuildContext context)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.doc("users/$uid/rounds/$documentId").get();
    List<String> savedRounds = prefs.getStringList("saved_rounds") ?? [];
    print("addde");
    savedRounds.add(snapshot["name"]);
    List<String> idList = prefs.getStringList("id_list") ?? [];
    int largestId = 0;
    for(int i = 0; i<idList.length;i++){
      if(int.parse(idList[i])>largestId){
        largestId = int.parse(idList[i]);
      }
    }
    largestId++;

    idList.add(largestId.toString());
    await prefs.setStringList("id_list", idList);
    await prefs.setStringList("saved_rounds", savedRounds);
    await prefs.setStringList("list$largestId", snapshot["list"].cast<String>());
    await prefs.setString("string_note$largestId", snapshot["string_note"] ?? "");
    await prefs.setString("tees$largestId", snapshot["tees"]);
    await prefs.setStringList("gir$largestId", snapshot["gir"].cast<String>());

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(milliseconds: 200), content: Text("Edukalt allalaaditud ${snapshot["name"]}")));
  }

}



class GolfRound{
  final String roundName;
  final List<String>holeResults;
  final List<String>girResults;
  final String tees;
  final String notes;

  GolfRound(this.roundName, this.holeResults, this.girResults, this.notes, this.tees);


}