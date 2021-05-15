import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golfitulemused/components/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowSavedRoundScreen extends StatefulWidget {

  final int id;
  final List<String> scores;
  final String name;
  final String tees;
  final List<String>girList;

  ShowSavedRoundScreen(this.id, this.scores, this.name, this.tees, this.girList);

  @override
  _ShowSavedRoundScreenState createState() => _ShowSavedRoundScreenState();
}

class _ShowSavedRoundScreenState extends State<ShowSavedRoundScreen> {




  SharedPreferences prefs;
  String notesString;
  String filePath;

  // ignore: missing_return
  List<int>asIntList(List<String>list){

    List<int> intList = [];


    if(list!=null){
      for(String score in list){
        intList.add(int.parse(score));
      }
      return intList;
    }

  }




  List<Widget> getListTiles(){
    List<Widget> listTiles = [];
    for(int index = 0; index<widget.scores.length; index++){
      String item = widget.scores[index];
      listTiles.add(
        ListTile(
          leading: Text(widget.girList!=null ? widget.girList[index]=="true" ? "GIR" : "": "", style: TextStyle(color: Colors.black),),
          title: Text("Rada ${index+1}", style: TextStyle(color: Colors.black),),
          trailing: Text(item, style: TextStyle(color: Colors.black),),

        )
      );
      listTiles.add(
        Divider(color: Colors.white70,),
      );
    }
    return listTiles;

  }


  int total = 0;

  @override
  void initState() {
    super.initState();
    List<String> totalList = widget.scores;
    for(String score in totalList){
      total +=int.parse(score);

    }
    getPrefs().then((value) => setState((){
      prefs = value;
      filePath = prefs.getString("image_note${widget.id}");
      notesString = prefs.getString("string_note${widget.id}") ?? "Märkmeid pole lisatud";
    }));

  }

  Future<SharedPreferences>getPrefs()async=>await SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 9, horizontal: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.name, style: TextStyle(color: Colors.white70, fontSize: 20),),
                  Text(widget.tees, style: TextStyle(color: Colors.white54, fontSize: 18),),
                  IconButton(
                    icon: Icon(Icons.speaker_notes, color: Colors.grey[700],),
                    onPressed: (){
                      showModalBottomSheet(context: context, builder: (_)=>Container(
                        height: MediaQuery.of(context).size.height-40,
                        child: SafeArea(
                          child: Column(
                            children: [
                              Text("Märkmed", textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),),
                              SizedBox(height: 20,),
                              Text(notesString, textAlign: TextAlign.center, style: TextStyle(color: Colors.black),),
                              SizedBox(height: 20),
                              Visibility(
                                visible: filePath != null,
                                child: Button(
                                  text: "Vaata märkmetest pilti",
                                  color: Colors.blue,
                                  onPressed: (){
                                    showDialog(barrierDismissible: true, context: context, builder: (_)=>AlertDialog(
                                      content: Container(child: Image.file(File(filePath))),

                                    ));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 25,
              child: ListView(

                children: getListTiles(),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: <Widget>[
                  Divider(height: 10, color: Colors.white, thickness: 2,),
                  ListTile(
                    title: Text("Kokku", style: TextStyle(color: Colors.black),),
                    trailing: Text(total.toString(), style: TextStyle(color: Colors.black),),

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
