import 'package:flutter/material.dart';


class RoundButton extends StatelessWidget {

  final Color color;
  final Widget child;
  final Function onPressed;

  RoundButton({@required this.color, @required this.onPressed, @required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        backgroundColor: color,
        child: child,
        radius: 25,
      ),
    );
  }
}
