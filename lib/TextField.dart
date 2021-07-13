import 'package:flutter/material.dart';

class Textfield extends StatelessWidget {
  Textfield({@required this.controller, @required this.labeltext, @required this.hinttext, @required this.error, @required this.selhtext, @required this.icon, @required this.selicon, @required this.obscuretext, @required this.align_centre, @required this.errortext});

  final TextEditingController controller;
  final String labeltext;
  final bool selhtext;
  final IconData icon;
  final String hinttext;
  final bool error;
  final bool selicon;
  final bool obscuretext;
  final bool align_centre;
  final String errortext;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      child: TextField(
        obscureText: obscuretext,
        controller: controller,
        style: TextStyle(
          color: Colors.white,
        ),
        textAlign: align_centre? TextAlign.center : TextAlign.start,
        decoration: InputDecoration(
          errorText:
          error ? errortext : null,
          suffixIcon: selicon ? Icon(
            icon,
            color: Colors.white70,
          ) : null,
          enabledBorder: const UnderlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          labelText: labeltext,
          labelStyle: TextStyle(
            fontSize: 15.0,
            color: Colors.white70,
          ),
          hintText: selhtext ? hinttext : null,
          hintStyle: TextStyle(
            fontSize: 13.0,
            color: Colors.white54,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: const BorderSide(color: Colors.blue, width: 1.0),
          ),
        ),
      ),
    );
  }
}
