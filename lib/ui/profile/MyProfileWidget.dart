import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/ui/auth/LoginMainWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyProfileWidget extends StatefulWidget {
  @override
  _MyProfileWidgetState createState() => _MyProfileWidgetState();
}

class _MyProfileWidgetState extends State<MyProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialButton(
        onPressed: (){
          FirebaseAuth.instance.signOut();
          //clear preferences
          getPref().then((value) => value.clear());
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginMainWidget()
              ),
              ModalRoute.withName("/HomeWidget")
          );
        },
        child: Text('Logout'),
      ),
    );
  }
}
