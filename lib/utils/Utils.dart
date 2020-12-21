import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

String validateMobile(String value) {
  String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return 'Please enter mobile number';
  }
  else if (!regExp.hasMatch(value)) {
    return 'Please enter valid mobile number';
  }
  return null;
}


void showSnackBar(BuildContext context, String text){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text),));

}

Widget circularProgressBar = Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(),);


Widget textMessage(String message ) => Padding(padding: EdgeInsets.all(15), child: Text(message),);

Widget showProgressSnack(BuildContext context, String text){
  SnackBar snackBar = SnackBar(
    duration: Duration(seconds: 30),
    content:new Row(
      children: <Widget>[
        new CircularProgressIndicator(strokeWidth: 2,),
        new Text("  $text...")
      ],
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  return snackBar;

}