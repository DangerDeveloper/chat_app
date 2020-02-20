import 'package:flutter/material.dart';

class TextFormFieldFill extends StatelessWidget {

  final Color color;
  final String text;
  final Function onPressed;

  TextFormFieldFill({@required this.color,@required this.text,@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}