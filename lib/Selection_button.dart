import 'package:flutter/material.dart';

class SelectionButton extends StatelessWidget {
  SelectionButton({@required this.top,@required this.text, @required this.onpressed, @required this.color, this.left = 120.0, this.radius = 20.0, this.bold = false});

  final double top;
  final String text;
  final Function onpressed;
  final Color color;
  final double left;
  final double radius;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, left, 0.0),
      child: GestureDetector(
        onTap: () {
          onpressed();
        },
        child: Container(
          alignment: Alignment.center,
          height: 40.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: color,
          ),
          child: Text(
            text,
            style: TextStyle(
              letterSpacing: 1.0,
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
