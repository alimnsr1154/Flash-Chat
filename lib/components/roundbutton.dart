import 'package:flutter/material.dart';

class Roundbutton extends StatelessWidget {
  Roundbutton({required this.col, required this.value, required this.onpress});
  late Color col;
  late String value;
  VoidCallback onpress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: col,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onpress,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// () {
// Navigator.pushNamed(context, LoginScreen.id);
// },
