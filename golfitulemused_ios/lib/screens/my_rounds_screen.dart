import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golfitulemused/screens/log_in.dart';
import 'package:golfitulemused/screens/select_rounds_from_cloud.dart';
import 'package:golfitulemused/screens/show_saved_round_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/networking.dart';


class MyRoundsScreen extends StatefulWidget {
  @override
  _MyRoundsScreenState createState() => _MyRoundsScreenState();
}

class _MyRoundsScreenState extends State<MyRoundsScreen> {

  Future<SharedPreferences>getPrefs()async{

    return await SharedPreferences.getInstance();
  }
  SharedPreferences prefs;
  List<ListTile> listViewChildren = [];
  bool isListViewVisible = true;
  double avScore = 0.0;


  //This boolean will be set false when rounds are loaded
  // It prevents the flash of 'no rounds' when loading rounds
  bool notFinished = true;

  @override
  void initState() {
    super.initState();
    getPrefs().then((value) {
      setState((){
        prefs = value;
        getListViewChildren();
      });


    });

  }





//    averageScore = averageScore / numberOfRounds;
  void getListViewChildren()async{
    List<ListTile>somethingToReturn = [];
    if(prefs.getStringList("id_list")==null){
      await prefs.setStringList("id_list", []);
    }else if(prefs.getStringList("saved_rounds")==null){
      await prefs.setStringList("saved_rounds", []);
    }
    print("ID: ${prefs.getStringList("id_list")}");
    List<String> savedRounds = prefs.getStringList("saved_rounds");
    print(savedRounds);
    List<String> idStringList = prefs.getStringList("id_list");
    List<int> idList = [];
    for(int i = 0; i<idStringList.length;i++){
      idList.add(int.parse(idStringList.elementAt(i)));
    }
    for(int id in idList){
      int howMany;
      for(int idx = 0; idx<idList.length;idx++){
        if(idList[idx]==id){
          howMany = idx;
        }
      }
//      print(savedRounds[howMany]);
//      print(prefs.getStringList("list$id"));
      int totalScore = 0;
      for(String hole in prefs.getStringList("list$id") ?? []){
        totalScore+=int.parse(hole);
      }


      somethingToReturn.add(ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(totalScore.toString(), style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.upload_rounded),
                  onPressed: (){
                    User user = FirebaseAuth.instance.currentUser;
                    if(!user.emailVerified && user.email != "apple-review-account@test-email.com"){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Jätkamiseks kinnita e-posti aadress. Link on saadetud meilile"), action: SnackBarAction(label: "SAADA UUESTI", onPressed: ()async{
                        await user.sendEmailVerification();
                      },),));
                      return;
                    }

                    GolfRound round = GolfRound(savedRounds[howMany], prefs.getStringList("list$id"), prefs.getStringList("gir$id"), prefs.getString("string_note$id"), prefs.getString("tees$id"));
                    Networking().uploadRound(round, context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red,),
                  onPressed: (){
                    showCupertinoModalPopup(context: context, builder: (_)=>CupertinoActionSheet(
                      title: Text("Kustuta?"),
                      message: Text("Kas soovid selle ringi kustutada?\n${savedRounds[howMany]}\n${totalScore.toString()} lööki"),
                      actions: [
                        CupertinoActionSheetAction(
                          child: Text("Kustuta", style: TextStyle(color: Colors.red),),
                          onPressed: ()async{
                            deleteRoundWithID(id);
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
              ],
            ),
          ],
        ),
        subtitle: Text(savedRounds[howMany]),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowSavedRoundScreen(id, prefs.getStringList("list$id"), savedRounds[howMany], prefs.getString("tees$id"), prefs.getStringList("gir$id"))));
        },
      ));



    }
    setState(() {
      listViewChildren = somethingToReturn;

      notFinished = false;
    });
    getAverageScore();
  }

  Future<void> deleteRoundWithID(int id)async{
    List<String>savedRounds = prefs.getStringList("saved_rounds");
    savedRounds.removeAt(prefs.getStringList("id_list").indexOf(id.toString()));
    print(savedRounds.length.toString() + "isl endns");
    await prefs.setStringList("saved_rounds", savedRounds);

    int indexForName;
    List<int>idList = [];
    List<String>returnIdList = [];
    for(int index = 0; index< prefs.getStringList("id_list").length;index++){
      int intId = int.parse(prefs.getStringList("id_list").elementAt(index));
      idList.add(intId);
      if(intId==id){
        indexForName = index;
      }
    }



    idList.remove(id);
    for(int idx = 0; idx<idList.length;idx++){
      returnIdList.add(idList.elementAt(idx).toString());
    }
    print(idList);
    await prefs.remove("list$id");
    await prefs.remove("image_note$id");
    await prefs.remove("string_note$id");
    await prefs.setStringList("id_list", returnIdList);
    print(prefs.getStringList("saved_rounds"));
    getListViewChildren();
  }


  void getAverageScore(){
    int numberOfRounds = prefs.getStringList("id_list").length;
    double average = 0.0;
    for(String idAsString in prefs.getStringList("id_list")){
      double total = 0;
      int numberOfHoles = prefs.getStringList("list$idAsString").length;
      int id = int.parse(idAsString);
      for(String hole in prefs.getStringList("list$id")){
        total += int.parse(hole);
      }
      total = total / numberOfHoles * 18;
      average +=total;
    }
    average = average / numberOfRounds;
    setState(() {
      avScore = average;
    });
  }


  //Checks if user has data uploaded to rounds. If they have, shows a warning about making multiple copies of rounds
  Future<bool>dataUploaded()async{
    return FirebaseAuth.instance.currentUser != null ? (await FirebaseFirestore.instance.collection("users/${FirebaseAuth.instance.currentUser.uid}/rounds").get()).docs.length > 0 : false;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 13), child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("Minu ringid", textAlign: TextAlign.start, style: TextStyle(color: Colors.white70, fontSize: 35),),
              ],
            )),
            ListTile(
              title: Text("Laadi enda ringid siia seadmesse"),
              leading: Icon(Icons.download_outlined),
              onTap: ()async{

                User user = FirebaseAuth.instance.currentUser;
                await Future.delayed(Duration(milliseconds: 200));
                user = FirebaseAuth.instance.currentUser;


                if(!user.emailVerified){
                  await FirebaseAuth.instance.currentUser.reload();
                }

                if(!user.emailVerified && user.email != "apple-review-account@test-email.com"){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Jätkamiseks kinnita e-posti aadress. Kui olete juba kinnitanud, logige välja ja siis uuesti sisse. Link on saadetud meilile"), action: SnackBarAction(label: "SAADA UUESTI", onPressed: ()async{
                    await user.sendEmailVerification();

                  },),));
                  return;
                }
                if(user == null){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sa pole sisse logitud!"),));
                  return;
                }




                //I have no idea why I have to do this but it wont work otherwise
                //It's stupid
                if(user==null){
                  await Future.delayed(Duration(milliseconds: 200));
                  user = FirebaseAuth.instance.currentUser;
                }


                if(user == null){
                  Navigator.push(context, CupertinoPageRoute(builder: (_)=>LoginScreen()));
                }else if(user is User){
                  showCupertinoModalPopup(context: context, builder: (_)=>CupertinoActionSheet(
                    title: Text("Laadi alla"),
                    actions: [
                      CupertinoActionSheetAction(
                        child: Text("Ainult viimane ring"),
                        onPressed: ()async{
                          print(FirebaseAuth.instance.currentUser.uid);
                          bool finished = await Networking().downloadLatestRound(FirebaseAuth.instance.currentUser.uid, context);
                          if(finished){
                            Navigator.pop(context);
                            getListViewChildren();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Allalaaditud")));
                          }
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: Text("Kõik ringid"),
                        onPressed: ()async{
                          bool finished = await Networking().downloadAllRounds(FirebaseAuth.instance.currentUser.uid, context);
                          if(finished){
                            Navigator.pop(context);
                            getListViewChildren();
                          }
                        },
                      ),
                      CupertinoActionSheetAction(
                        isDefaultAction: true,
                        child: Text("Vali ringid"),
                        onPressed: (){
                          print(FirebaseAuth.instance.currentUser);
                          //TODO: Lisa ekraan, kus on näha kõik ringid, kus on checkbox ja kus saab valida, milliseid ringe alla laadida
                          Navigator.push(context, CupertinoPageRoute(builder: (_)=>SelectRoundsFromCloudScreen()));
                        },
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: Text("Tagasi"),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ));
                }

              },
            ),
            Visibility(
              visible: listViewChildren.length!=0,
              child: Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("${avScore.toStringAsFixed(1).replaceAll(".", ",")}", style: TextStyle(fontSize: 40),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(child:
                        Text("Keskmine tulemus 18-rajal", style: TextStyle(color: Colors.grey[700])), onTap: (){
                          showDialog(
                            context: context,
                            builder: (context)=>AlertDialog(
                              title: Text("Keskmine tulemus 18-rajal"),
                              content: Text("See number näitab sinu keskmist tulemust 18 raja mängimisel. Kui sa oled mänginud lühematel radadel, muudetakse need tulemused keskmise arvutamisel 18 raja tulemusteks, võttes arvesse sinu tulemust sellel rajal."),
                            )
                          );
                        },),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 15,
              child: listViewChildren.length!=0 || notFinished ? ListView(

                children: listViewChildren.reversed.toList() + [
                  ListTile(
                    leading: Icon(Icons.upload_outlined),
                    title: Text("Laadi kõik tulemused pilve"),
                    onTap: ()async{
                      User user = FirebaseAuth.instance.currentUser;
                      if(!user.emailVerified && user.email != "apple-review-account@test-email.com"){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Jätkamiseks kinnita e-posti aadress. Kui olete juba kinnitanud, logige välja ja siis uuesti sisse. Link on saadetud meilile."), action: SnackBarAction(label: "SAADA UUESTI", onPressed: ()async{
                          await user.sendEmailVerification();
                        },),));
                        return;
                      }
                      bool continueAnyway = true;
                      if(await dataUploaded()){
                        continueAnyway = false;
                        showCupertinoDialog(context: context, builder: (_)=>CupertinoAlertDialog(
                          title: Text("Kindel?"),
                          content: Text("Sa oled sisse logitud ja kõik sinu ringid salvestatakse automaatselt pilve. Kas tahad kõik uuesti pilve laadida? See võib tekitada ringidest koopiad"),
                          actions: [
                            CupertinoDialogAction(child: Text("Tagasi"), onPressed: (){Navigator.pop(context);},),
                            CupertinoDialogAction(child: Text("Jätka ikkagi"), isDestructiveAction: true, onPressed: (){continueAnyway = true;},)
                          ],
                        ));
                      }
                      if(continueAnyway){
                      showCupertinoModalPopup(context: context, builder: (_)=>CupertinoActionSheet(
                      title: Text("Millised ringid kontoga siduda?"),
                      message: Text("Sisselogitud kasutajad saavad need ja kõik järgnevad ringid oma kontoga siduda."),
                      actions: [
                      CupertinoActionSheetAction(
                      child: Text("Seo ringid kontoga"),
                      isDefaultAction: true,
                      onPressed: ()async{
                      Navigator.pop(context);
                      if(FirebaseAuth.instance.currentUser == null){
                      Navigator.push(context, CupertinoPageRoute(builder: (_)=>LoginScreen(linkRoundsAfterLogin: true,)));
                      }else{
                      Networking().linkRoundsToEmail(FirebaseAuth.instance.currentUser.uid, context);
                      }
                      },
                      ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                      child: Text("Tagasi"),
                      onPressed: (){Navigator.pop(context);},
                      ),
                      ));
                      }
                    },
                  ),

                ],
              ) : Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.info_outline, size: 120, color: Colors.white54,),
                  SizedBox(height: 30,),
                  Text("Sa pole veel ringe salvestanud", style: TextStyle(color: Colors.white54, fontSize: 23),),
                ],
              ))
            ),
          ],
        ),
      ),
    );
  }
}
