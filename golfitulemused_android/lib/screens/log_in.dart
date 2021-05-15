import 'package:flutter/material.dart';
import 'package:golfitulemused/components/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/networking.dart';
import 'my_rounds_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool linkRoundsAfterLogin;
  LoginScreen({this.linkRoundsAfterLogin  = false});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailCon = TextEditingController();
  TextEditingController passwordCon = TextEditingController();
  bool showConfirmPassword = false;
  String password;


  @override
  void dispose() {
    super.dispose();
    emailCon.dispose();
    passwordCon.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Logi sisse", style: TextStyle(color: Colors.white, fontSize: 23),),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ListView(
          children: [
            Visibility(
              visible: widget.linkRoundsAfterLogin,
              child: Text("Sisse logides või konto luues seote ringid kontoga.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),),
            ),
            SizedBox(height: widget.linkRoundsAfterLogin ? 20 : 0,),
            TextField(
              controller: emailCon,
              decoration:InputDecoration(hintText: "E-posti aadress"),
              autocorrect: false,
            ),
            InkWell(onTap: ()async{
              showDialog(context: context, builder: (_)=>AlertDialog(
                title: Text("Lähtesta salasõna"),
                content: TextField(
                  controller: emailCon,
                  autocorrect: false,
                  decoration:InputDecoration(hintText: "E-posti aadress"),
                ),
                actions: [
                  MaterialButton(child: Text("Lähtesta"), onPressed: ()async{
                    if(emailCon.text.isNotEmpty){
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailCon.text);
                      Navigator.pop(context);
                    }
                  },),
                ],
              ));
            }, child: Text("Unustasid salaõna?", style: TextStyle(color: Colors.black, decoration: TextDecoration.underline),)),
            SizedBox(height: 8,),
            TextField(
              obscureText: true,
              controller: passwordCon,
              decoration:InputDecoration(hintText:"Parool"),
              autocorrect: false,
            ),
            Visibility(
              visible: showConfirmPassword,
              child: Column(
                children: [
                  SizedBox(height: 8,),
                  TextField(
                    autocorrect: false,
                    decoration: InputDecoration(hintText:"Kinnita parool"),
                    obscureText: true,
                    onChanged: (val){
                      password = val;
                    },
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
            SizedBox(height: 13,),

            Button(
              text: "Loo konto",
              color: Colors.green,
              onPressed:()async{
                if(emailCon.text.isEmpty && passwordCon.text.isEmpty ) return;
                if(password == null){
                  setState(() {
                    showConfirmPassword = true;
                  });
                }else{
                  if(password == passwordCon.text && passwordCon.text.length >=6){
                    try{
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailCon.text, password: password);
                      await FirebaseAuth.instance.currentUser.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Konto loodud. E-posti aadressi kinnitamiseks on saadetud e-mail"),));
                      if(widget.linkRoundsAfterLogin){
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>MyRoundsScreen()));
                        Networking().linkRoundsToEmail(emailCon.text, context);
                      }else{
                        Navigator.pop(context, true);
                      }

                    }catch(e){
                      print(e.code);
                      switch (e.code){
                        case "email-aleady-in-use":
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Konto juba eksisteerib teise salasõnaga"),));
                          return;
                        case "weak-password":
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Parool on liiga nõrk"),));
                          return;
                        case "invalid-email":
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("E-posti aadress on valesti vormistatud"),));
                          return;
                      }
                    }
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Paroolid ei kattu või on liiga lühikesed")));
                  }
                }

              },
            ),
            SizedBox(height: 15,),
            Button(
              text: "Logi sisse",
              color: Colors.blue,
              onPressed: ()async{
                if(emailCon.text.isEmpty && passwordCon.text.isEmpty ) return;
                try{
                  await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailCon.text, password: passwordCon.text);
                  if(widget.linkRoundsAfterLogin){
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>MyRoundsScreen()));
                    print(FirebaseAuth.instance.currentUser.uid);
                    Networking().linkRoundsToEmail(FirebaseAuth.instance.currentUser.uid, context);
                  }else{
                    Navigator.pop(context, true);
                  }
                }catch(e){
                  print(e);
                  switch(e.code){
                    case "user-not-found":
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sellist kasutajat ei leitud"),));
                      return;
                    case "wrong-password":
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Parool on vale"),));
                      return;
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
