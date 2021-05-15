import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golfitulemused/data/courses.dart';


class ShowMoreScreen extends StatefulWidget {

  final List<ListTile> scores;
  final int index;
  final List<String> scoresAsString;
  final List<String>girList;
  final int realPar;

  ShowMoreScreen(this.scores, this.index, this.scoresAsString, this.girList, this.realPar);

  @override
  _ShowMoreScreenState createState() => _ShowMoreScreenState();
}

class _ShowMoreScreenState extends State<ShowMoreScreen> {

  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    for(String i in widget.scoresAsString){
      int iAsInt = int.parse(i);
      totalScore+=iAsInt;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:13.0, vertical: 9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Tulemuskaart", style: TextStyle(fontSize: 25, color: Colors.white70),),
                  Text("PAR ${Courses().courses[widget.index].par}", style: TextStyle(color: Colors.white70, fontSize: 20),),
                  SizedBox(height: 70,),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("${Courses().courses[widget.index].name}", style: TextStyle(color: Colors.white54, fontSize: 20),),
            ),
            Expanded(
              flex: 6,
              child: ListView(
                children: widget.scores,
              ),
            ),
            Divider(height: 5, color: Colors.grey,),
            Expanded(
              child: ListTile(
                title: Text("Kokku", style: TextStyle(color: Colors.grey[800]),),
                subtitle: Text("PAR ${widget.realPar}",style: TextStyle(color: Colors.grey[800]),),
                trailing: Text(totalScore.toString(), style: TextStyle(color: totalScore <= Courses().courses[widget.index].par ? Colors.black : Colors.red[600]),),
              ),
            )

          ],
        ),
      ),
    );
  }
}
