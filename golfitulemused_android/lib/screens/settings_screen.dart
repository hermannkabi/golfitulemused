import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:golfitulemused/components/button.dart';
import 'package:golfitulemused/data/networking.dart';
import 'package:golfitulemused/screens/add_data_coordinates.dart';
import 'package:golfitulemused/screens/add_data_map.dart';
import 'package:golfitulemused/screens/intro_screen.dart';
import 'package:golfitulemused/screens/log_in.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  Future<SharedPreferences>initiateSharedPrefs()async => await SharedPreferences.getInstance();
  String name = "";
  bool waterValue = true;
  bool popupValue = true;

  @override
  void initState() {

    super.initState();
    initiateSharedPrefs().then((value) {
      setState(() {
        prefs=value;
        name = prefs.getString("name");
        User user = FirebaseAuth.instance.currentUser;
        if(user==null){
          Future.delayed(Duration(milliseconds: 200)).then((value){
            user = FirebaseAuth.instance.currentUser;
            setState(() {
              name = user == null ? prefs.getString("name") : user.displayName;

            });

          });
        }

        waterValue = prefs.getBool("water_notific") ?? true;
        popupValue = prefs.getBool("popup_wanted") ?? true;
      });

    });

  }

  SharedPreferences prefs;





  void deleteAccount()async{
  bool confirm = await Networking.confirmDecision(context, message: "See kustutab sinu konto ja kõik pilve salvestatud ringid. Seadmesse salvestatud ringid ei kao. Kas tahad jätkata", confirmButton: "Jah, tahan konto kustutada");
  if(confirm){
    try{
      await FirebaseAuth.instance.currentUser.delete();
    }catch(e){
      if(e.code=="requires-recent-login"){
        bool result = await Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
        if(result){
          deleteAccount();
        }
      }
    }
  }
  Navigator.pop(context);
  setState(() {

  });
}

  Future<String>createAlertDialog(String title)async{
    String name;
    String toReturn = await showDialog(context: context,
    builder: (context)=>AlertDialog(
      title: Text(title),
      content: TextField(
        onChanged: (value){
          setState(() {
            name = value;
          });
        },
      ),
      actions: <Widget>[
        MaterialButton(
          child: Text("Loobu"),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        MaterialButton(
          child: Text("Kinnita"),
          onPressed: (){
            Navigator.pop(context, name);
          },
        )
      ],
    )
    );
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Seaded", style: TextStyle(color: Colors.white70, fontSize: 35),),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        backgroundColor: Colors.lightBlueAccent,
        body: Builder(
          builder:(context)=> Container(
            child: ListView(

              children: <Widget>[
                ListTile(
                  title: Text("Nimi"),
                  subtitle: Text(name??"Viga!"),
                  leading: Icon(Icons.person, color: Colors.blueAccent,),
                  onTap: ()async{
                    String newName=await createAlertDialog("Sisesta enda uus nimi");
                    if(newName!=null && newName.trim().length!=0){
                      await prefs.setString("name", newName);
                      setState(() {
                        name = prefs.getString("name");
                      });
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selline nimi pole lubatud")));
                    }
                  },
                ),
                Divider(color: Colors.white70),
                ListTile(
                  leading: Icon(Icons.account_circle_outlined),
                  title: Text(FirebaseAuth.instance.currentUser != null ? "Minu konto" : "Konto"),
                  subtitle: FirebaseAuth.instance.currentUser != null ? Text("${FirebaseAuth.instance.currentUser.email}") : Text("Logi sisse või loo konto"),
                  onTap: FirebaseAuth.instance.currentUser == null ? ()async{
                    await Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
                    setState(() {
                    });
                  } : ()async{
                    showDialog(context: context, builder: (_)=>SimpleDialog(
                      title: Text("Konto"),
                      children: [
                        Column(
                          children: [
                            MaterialButton(onPressed: ()async{
                              User user = FirebaseAuth.instance.currentUser;
                              Navigator.pop(context);
                              showModalBottomSheet(context: context, builder: (_)=>Material(
                                child: Container(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 15,),
                                        Center(child: CircleAvatar(radius: 30, backgroundColor: Colors.teal, child: Text(user.email[0].toUpperCase(), style: TextStyle(fontSize: 27),),),),
                                        SizedBox(height: 20,),
                                        InfoColumn(
                                          info: "nimi",
                                          data: FirebaseAuth.instance.currentUser.displayName ?? "lisa nimi",
                                          onTap: ()async{
                                            String newName;
                                            Navigator.pop(context);
                                            showDialog(context: context, builder: (_)=>AlertDialog(
                                              title: Text("Muuda nime"),
                                              content: TextField(
                                                decoration: InputDecoration(hintText: "Uus nimi"),
                                                autocorrect: false,
                                                onChanged: (val){
                                                  newName = val;
                                                },
                                              ),
                                              actions: [
                                                MaterialButton(child: Text("Muuda"), onPressed: ()async{
                                                  if(newName.isNotEmpty){
                                                    await FirebaseAuth.instance.currentUser.updateProfile(displayName: newName);
                                                    await prefs.setString("name", newName);
                                                    setState(() {
                                                      name = newName;
                                                    });
                                                    Navigator.pop(context);
                                                  }
                                                },),
                                              ],
                                            ));
                                          },
                                        ),
                                        InfoColumn(info: "e-post", data: FirebaseAuth.instance.currentUser.email,onTap: ()async{
                                          Navigator.pop(context);
                                          String newEmail;
                                          showDialog(barrierDismissible: true, context: context, builder: (_)=>AlertDialog(
                                            title: Text("Uuenda e-posti aadressi"),
                                            content: TextField(
                                              autocorrect: false,
                                              decoration: InputDecoration(hintText:  "Uus e-posti aadress"),
                                              onChanged: (val){
                                                newEmail = val;
                                              },
                                            ),
                                            actions: [
                                              MaterialButton(child: Text("Uuenda"), onPressed: ()async{
                                                if(newEmail.isNotEmpty){
                                                  await FirebaseAuth.instance.currentUser.verifyBeforeUpdateEmail(newEmail);
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("E-posti aadress uuendatakse, kui  oled selle kinnitanud. Vaata postkasti")));
                                                }
                                              },),
                                            ],
                                          ));
                                        },),
                                        InfoColumn(info: "parool", data: "muuda parooli", onTap: ()async{
                                          await FirebaseAuth.instance.sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser.email);
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("E-post parooli lähtestamiseks on saadetud!")));
                                        },),
                                        SizedBox(height: 60,),
                                        Button(
                                          text: "Kustuta konto",
                                          color: Colors.red,
                                          onPressed: deleteAccount,
                                        )

                                      ],
                                    ),
                                  ),
                                ),
                              ));
                            }, child: Text("Vaata konto andmeid")),
                          ],
                        ),

                        MaterialButton(onPressed: ()async{
                          await FirebaseAuth.instance.signOut();
                          await Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
                          setState(() {
                          });
                        }, child: Text("Logi välja", style: TextStyle(color: Colors.red),),),

                      ],

                    ));

                  },
                ),

                Divider(color: Colors.white70,),
                ListTile(
                  title: Text("Näita veetarbimise meeldetuletusi"),
                  leading: Icon(Icons.notifications, color:waterValue ? Colors.yellow : Colors.grey,),
                  trailing: Switch(
                    activeColor: Colors.lightGreen,
                      activeTrackColor: Colors.lightGreenAccent,
                      value: waterValue,
                      onChanged:(value)async{
                        await prefs.setBool("water_notific", value);
                        setState(() {
                          waterValue = prefs.getBool("water_notific");
                        });
                      },
                  ),
                ),
                Divider(color: Colors.white70,),
                ListTile(
                  title: Text("Küsi aeg-ajalt hinnangut"),
                  leading: Icon(Icons.rate_review, color:popupValue ? Colors.blueGrey : Colors.grey,),
                  trailing: Switch(
                    activeColor: Colors.lightGreen,
                    activeTrackColor: Colors.lightGreenAccent,
                    value: popupValue,
                    onChanged:(value)async{
                      await prefs.setBool("popup_wanted", value);
                      setState(() {
                        popupValue = prefs.getBool("popup_wanted");
                      });
                      if(value==true){
                        await prefs.setInt("opening_times", 1);
                        await prefs.setInt("opening_req", 5);
                      }
                    },
                  ),
                ),
                Divider(color: Colors.white70,),
                ListTile(
                  title: Text("Näita litsentse"),
                  leading: Icon(Icons.picture_as_pdf, color: Colors.black,),
                  onTap: (){
                    showAboutDialog(context: context,
                      applicationName: "Golfitulemused",
                      applicationVersion: "2.2.1",
                      applicationIcon: Icon(Icons.golf_course),
                      applicationLegalese: "Golfitulemused on äpp, millega saate kiiresti ja kergelt oma golfitulemusi salvestada",

                    );
                  },
                ),
                Divider(color: Colors.white70,),
                ListTile(
                  title: Text("Hinda Golfitulemusi"),
                  leading: FaIcon(FontAwesomeIcons.googlePlay, color: Colors.blue,),
                  onTap: ()async{
                    await InAppReview.instance.openStoreListing(appStoreId: "1564386222");
                  },
                ),
                SizedBox(height: 20,),
                ListTile(
                  leading: Icon(Icons.add, color: Colors.green[700],),
                  title: Text("Aita kaasa - lisa andmeid"),
                  onTap: (){
                    showDialog(context: context, builder: (_)=>SimpleDialog(
                      title: Text("Vali, kuidas kaasa aidata"),
                      children: [
                        Column(
                          children: [
                            MaterialButton(
                              child: Text("Lisa olemasolevale väljakule rajakaarte"),
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>AddDataMap()));
                              },
                            ),
                            MaterialButton(
                              child: Text("Lisa olemasolevale väljakule augukoordinaadid"),
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>AddDataCoordinates()));
                              },
                            ),
                          ],
                        ),

                      ],
                    ));
                  },
                ),
                SizedBox(height: 50,),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red,),
                  title: Text("Lähtesta kõik andmed", style: TextStyle(color: Colors.red),),
                  onTap: ()async{
                    bool confirmed = await Networking.confirmDecision(context, title: "Lähtsesta kõik andmed?", message: "See tegevus on tagasivõtmatu. Kas minna edasi?");
                    if(confirmed){
                      await FirebaseAuth.instance.signOut();
                      for(String key in prefs.getKeys()){
                        if(key!="intro_screen_seen"){
                          await prefs.remove(key);
                        }
                      }
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(
                              builder: (context)=>IntroScreen()
                          ));
                    }

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoColumn extends StatelessWidget {
  final String info;
  final String data;
  final Function onTap;
  const InfoColumn({
    Key key,
    this.data,
    this.info,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(info, style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.black),),
          Text(data, style: TextStyle(color: Colors.black),),
        ],
      ),
    );
  }
}
