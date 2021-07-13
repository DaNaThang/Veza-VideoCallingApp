import 'package:flutter/material.dart';


class LoginSignUp extends StatelessWidget {
  LoginSignUp({@required this.top,@required this.text,@required this.color, @required this.onpressed,@required this.textcolor});

  final double top;
  final Color color;
  final Color textcolor;
  final String text;
  final Function onpressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, top, 10.0, 0.0),
      child: GestureDetector(
        onTap: ()  {
          onpressed();
        },
        child: Container(
          alignment: Alignment.center,
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: color,
          ),
          child: Text(
            text,
            style: TextStyle(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              fontSize: 24.0,
              color: textcolor,
            ),
          ),
        ),
      ),
    );
  }
}