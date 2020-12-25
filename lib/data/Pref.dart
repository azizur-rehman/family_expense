import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';


void saveKey(String key, String value) {
  getPref().then((pref) =>
  {
    print("Saved : "+key + "-> "+value),
    pref.setString(key, value)

  });
}

Future<String> getValue(String key)async{
  return await getPref().then((value) => value.getString(key));
}

Future<SharedPreferences> getPref()async{

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences;
}



void deleteKey(String key)async{
  return getPref().then((value) => value.remove(key));
}


User currentUser = FirebaseAuth.instance.currentUser;
String uid = currentUser.uid;