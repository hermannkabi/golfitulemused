import 'package:flutter/material.dart';


class Button extends StatelessWidget {

  final String text;
  final Function onPressed;
  final Color color;

  Button({Key key, this.text, this.onPressed, this.color});



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
