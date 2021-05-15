import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:golfitulemused/components/button.dart';
import 'package:golfitulemused/screens/bottom_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {

  String name = "";
  PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        children: <Widget>[
          Container(
            color: Colors.green,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(""),
                Center(child: Text("Tere tulemast Golfitulemuskaarti!", style: TextStyle(color: Colors.white70, fontSize: 25, fontFamily: "ProximaNova")),),
                Button(
                  text: "Järgmine",
                  color: Colors.greenAccent,
                  onPressed: (){
                    setState(() {
                      controller.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.decelerate);
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            color: Colors.teal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(""),
                Center(
                  child: Text("Selle äpiga saad kergesti salvestada oma skoori ja näha infot raja kohta.", style: TextStyle(color: Colors.white70, fontSize: 25, fontFamily: "ProximaNova"), textAlign: TextAlign.center,),
                ),
                Button(
                  text: "Tore",
                  color: Colors.greenAccent,
                  onPressed: (){
                    controller.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.decelerate);
                  },
                ),
              ],
            ),
          ),
          Container(
            color: Colors.lightGreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(""),
                Text("Palun luba Golfitulemused äpil sinu asukohta jälgida. Kasutame seda, et anda sulle kiireid mängusoovitusi ja näidata mõnel rajal kaugust lipuni.", style: TextStyle(color: Colors.white70, fontSize: 25, fontFamily: "ProximaNova"), textAlign: TextAlign.center,),
                Button(
                  text: "Luba asukoha jälgimine",
                  color: Colors.teal,
                  onPressed: ()async{
                    LocationPermission permission = await Geolocator.requestPermission();
                    if(permission != LocationPermission.denied && permission != LocationPermission.deniedForever){
                      controller.animateToPage(3, duration: Duration(milliseconds: 400), curve: Curves.decelerate);
                    }
                  },
                )
              ],
            ),
          ),
          Container(
            color: Colors.lightBlueAccent,
            child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Alustamiseks sisesta palun oma nimi:", style: TextStyle(color: Colors.white70, fontSize: 18, fontFamily: "ProximaNova"),),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 35),
                  child: CupertinoTextField(
                    autofocus: true,
                    onChanged: (value){
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                ),
                Builder(
                  builder:(context)=> Button(

                    color: Colors.greenAccent,
                    onPressed: ()async {
                      if(name!=null && name != ""){
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString("name", name);
                        await prefs.setBool("water_notific", true);
                        await prefs.setInt("opening_times", 1);
                        await prefs.setInt("opening_req", 5);
                        await prefs.setBool("popup_wanted", true);
//                        await prefs.setStringList("id_list", ["0", "1", "2"]);
//                        await prefs.setStringList("list0", ["1", "2", "3"]);
//                        await prefs.setStringList("list1", ["4", "5", "6"]);
//                        await prefs.setStringList("list2", ["7", "8", "9"]);
//                        await prefs.setStringList("saved_rounds", ["Raund id0", "Raund id1", "Raund id2"]);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BottomNavigationScreen(true)));
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Palun sisesta enda nimi")));
                      }

                  },
                    text: "Hakkame golfi mängima",),
                ),
              ],
            ),),
          ),
        ],
      ),
    );
  }
}
