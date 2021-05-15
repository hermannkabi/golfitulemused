import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golfitulemused/components/button.dart';
import 'package:golfitulemused/data/networking.dart';


class SelectRoundsFromCloudScreen extends StatefulWidget {

  @override
  SelectRoundsFromCloudScreenState createState() => SelectRoundsFromCloudScreenState();
}

class SelectRoundsFromCloudScreenState extends State<SelectRoundsFromCloudScreen> {

  static List<String>docIds = [];



  List<Widget> rounds = [];
  List<String> chosenDocIds = [];


  int getTotalScore(DocumentSnapshot snapshot){
    int total = 0;
    for(int i = 0; i<snapshot["list"].length; i++){
      total += int.parse(snapshot["list"][i]);
    }
    return total;
  }

  void getRoundsInCloud([QuerySnapshot snapshot])async{
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {
      QuerySnapshot querySnapshot = snapshot ?? await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.uid).collection("rounds").orderBy("datetime").get();
      rounds = [];
      for(DocumentSnapshot document in querySnapshot.docs.reversed){
        int totalScore = getTotalScore(document);

        rounds.add(
          ListTileRound(document: document, totalScore: totalScore,),
        );

      }

      setState(() {

      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vali ringid", style: TextStyle(fontSize: 28),),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.uid).collection("rounds").orderBy("datetime").snapshots(),
        builder:(context, snapshot){
          if(!snapshot.hasData) return CircularProgressIndicator();
          getRoundsInCloud(snapshot.data);
          return Column(
          children: [
            Visibility(
              visible: rounds.length > 0,
              child: Container(
                height: MediaQuery.of(context).size.height-76,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 10,
                      child: ListView(
                        children: rounds,
                      ),
                    ),
                    Spacer(),
                    Button(
                      color: Colors.green,
                      text: "Laadi ringid alla",
                      onPressed: ()async{
                        if(DocumentsSelected.documentsSelected.length < 1){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Palun vali ringid, mis alla laadida")));
                          return;
                        }

                        for(String documentId in DocumentsSelected.documentsSelected){
                          await Networking().downloadRoundByID(documentId, FirebaseAuth.instance.currentUser.uid, context);
                        }
                        DocumentsSelected.documentsSelected = [];
                      },
                    )
                  ],
                ),
              ),
            ),
            Center(
              child: Visibility(
                visible: rounds.length == 0,
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 65, color: Colors.white,),
                    Text("Sa pole veel ühtki ringi pilve laadinud", textAlign: TextAlign.center,),
                  ],
                ),
              ),
            )

          ],
        );
        },
      ),
    );
  }
}


class DocumentsSelected{
  static List<String> documentsSelected = [];

}


class ListTileRound extends StatefulWidget {
  final int totalScore;
  final DocumentSnapshot document;
  ListTileRound({this.document, this.totalScore, });
  @override
  _ListTileRoundState createState() => _ListTileRoundState();
}

class _ListTileRoundState extends State<ListTileRound> {




  bool selected = false;


  Future<void>deleteRoundFromCloud()async{
    bool confirm = await Networking.confirmDecision(context, title: "Kindel?", message: "See tegevus kustutab ringi pilvest. Seda ei saa tagasi võtta. Kas olete kindel?");
    if(confirm){
      await FirebaseFirestore.instance.doc(widget.document.reference.path).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kustutatud pilvest!")));
    }
  }






  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.totalScore.toString(), style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),),
          IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: deleteRoundFromCloud,),
        ],
      ),
      subtitle: Text(widget.document["name"]),
      leading: CircularCheckBox(
        value: selected,
        onChanged: (val){
          setState(() {
            selected = val;
          });
          if(val){
            DocumentsSelected.documentsSelected.add(widget.document.id);
          }else{
            DocumentsSelected.documentsSelected.remove(widget.document.id);
          }
        },
      ),
    );
  }
}
