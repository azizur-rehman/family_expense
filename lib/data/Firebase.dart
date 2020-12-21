import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:family_expense/utils/extensions/Extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var rootRef = FirebaseFirestore.instance;
var familyRef = rootRef.collection("family");
var familyMemberRef = rootRef.collection("family_members");
var itemRef = rootRef.collection('items');
var userRef = rootRef.collection('users');
var notificationRef = rootRef.collection('notifications');


FutureBuilder<DocumentSnapshot> loadName(String uid){
  return FutureBuilder(builder: (builder, snapshot){
    // if(snapshot.hasData)
    //   return snapshot.
    if(snapshot.hasData) {
      var user = UserData.fromJson(snapshot.data.data());
      return Text(user.name.capitalize());
    }
    return Text('');

  }, future: userRef.doc(uid).get());
}


FutureBuilder<DocumentSnapshot> loadFamilyCode(String familyId){

  print('Family Id - $familyId');

  // if(familyId.isEmpty)
  //   return Text('Failed to load Family Code, For Reference use : $familyId');

  return FutureBuilder(builder: (builder, snapshot){
    // if(snapshot.hasData)
    //   return snapshot.
    if(snapshot.hasData) {
      var family = Family.fromJson(snapshot.data.data());
      return Text(family.code, style: Theme.of(builder).textTheme.headline3.copyWith(color: Colors.blue, fontFamily: "raleway"));
    }
    return circularProgressBar;

  }, future: familyRef.doc(familyId).get());
}
