import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:family_expense/utils/extensions/Extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';

var rootRef = FirebaseFirestore.instance;
var familyRef = rootRef.collection("family");
var familyMemberRef = rootRef.collection("family_members");
var itemRef = rootRef.collection('items');
var userRef = rootRef.collection('users');
var notificationRef = rootRef.collection('notifications');
var familyPaymentsRef = rootRef.collection('family_payments');
var familyExpenseRef = rootRef.collection('family_expense');
var messagingRef = rootRef.collection('messages');

const String key_familyId = 'familyId';
const String key_amount = 'amount', key_remaining = 'remaining';


Widget loadName(String? uid, TextStyle style){
  print('Loading name for - $uid');
  if(uid == null)
    return Text('No Name');

  if(FirebaseAuth.instance.currentUser?.uid == uid) {
    try {
      return Text(currentUser?.displayName?.capitalize()??'', style: style,);
    } catch (e) {
      return SizedBox();
    }
  }

  return FutureBuilder(builder: (builder, snapshot){
    // if(snapshot.hasData)
    //   return snapshot.
    if(snapshot.hasData && !snapshot.hasError) {
      try {
        UserData user = UserData.fromJson(snapshot.data as Map<String, dynamic> );
        return Text(user.name!.capitalize(), style: style, textAlign: TextAlign.start,);
      }
      catch(e){
        print('err - $e');
        return Text('No Name', style: style, textAlign: TextAlign.start,);
      }
    }
    return Text('Loading...');

  }, future: userRef.doc(uid).get());
}


String getStringInitials(String text){
  print('Getting initials for -> $text');

  if(text.split(' ').length == 1)
    return text[0].toUpperCase();

  try { return text.split(' ').reduce((value, element) => '${value[0].toUpperCase()}${element[0]}').toUpperCase(); }
  catch(e){
    return text[0].toUpperCase();
  }
}

Widget loadNameAvatar(String uid){
  print('Loading name for - $uid');

  if(currentUser != null && currentUser?.uid == uid)
    return circleAvatar(getStringInitials(currentUser!.displayName!));

  return FutureBuilder(builder: (builder, snapshot){
    // if(snapshot.hasData)
    //   return snapshot.
    if(snapshot.hasData && !snapshot.hasError) {
      try {
        var user = UserData.fromJson(snapshot.data as Map<String, dynamic>);
        return circleAvatar(getStringInitials(user.name!));
      }
      catch(e){
        print('err - $e');
        return Text('');
      }
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
      var family = Family.fromJson(snapshot.data?.data() as Map<String, dynamic>);
      return Column(
        children: [
          // QrImage(data: family.code, size: 320, gapless: false,),
          // textMessage('Or'),
          Column(
            children: [
              Text(family.code??'', style: GoogleFonts.ubuntu().copyWith(color: Theme.of(builder).colorScheme.secondary, fontSize: 36)),
              SizedBox(height: 15,),

              OutlinedButton.icon(
                label: ralewayText('Share Code', style: GoogleFonts.raleway().copyWith()),
                onPressed: ()async=> await Share.share('Use the code - ${family.code} to join ${family.name}.\n\nDownload the android app - https://familyexpense.page.link/app'),
                icon: Icon(Icons.share_outlined, ),
                // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25),),
              ),
            ],
          ),
        ],
      );
    }
    return circularProgressBar;

  }, future: familyRef.doc(familyId).get());
}

void reloadCurrentUser(){
  try{
    currentUser?.reload();
  }
  catch(e){ }
}


