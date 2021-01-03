
import 'dart:collection';

import 'package:contacts_service/contacts_service.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:family_expense/utils/extensions/Extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class InviteMemberWidget  extends StatelessWidget {

  final SearchBarController _searchBarController = SearchBarController();

  final String uid = FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser.uid : null;

  Future<List<UserData>> _getUsers(String text) async {
    // await Future.delayed(Duration(seconds: text.length == 4 ? 10 : 1));

    if (text.length < 8) return [];

    String phone = '$currentDialCode$text';

    print('Searching for - $phone');
    var users = await userRef.where('phone', isLessThanOrEqualTo: phone).where('phone', isGreaterThanOrEqualTo: phone).get();
    var userList = users.docs.map((e) => UserData.fromJson(e.data())).toList();
    // userList.forEach((element) { print(element.phone);});
    print('List = $userList');

    userList.removeWhere((element) => element.uid == uid);

    return userList;
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: Permission.contacts.isGranted,
          builder: (context, isGranted){

            if(isGranted.hasData){

              if(!isGranted.data){
                return FutureBuilder<PermissionStatus>(
                  future: Permission.contacts.request(),
                  builder: (context, status){

                    if(status.connectionState == ConnectionState.done)
                      return _searchWidget(context, status.data.isGranted);

                    return circularProgressBar;
                  },
                );
              }

              return _searchWidget(context, isGranted.data);
            }


            return circularProgressBar;
          },
        ),
      ),
    );

  }

  Map<String, String> phoneContacts = Map();
  Widget _searchWidget(BuildContext context, bool hasContactPermission){

    //bind contact list if has permission
    if(hasContactPermission){
      ContactsService.getContacts().then((value) {
        // phoneContacts = Map.fromIterable(value.toList(), key: (e) => e['label'], value: (e) => e['phone']);
        value.forEach((e) {
          // phoneContacts[element.phones.map((e) => e.value)] = element.phones.first.value;
          phoneContacts[e.displayName] = e.phones.map((e) => e.value).toList().join("|");
        });
        print(phoneContacts);
      }
      );
    }

    return SearchBar<UserData>(
      searchBarPadding: EdgeInsets.symmetric(horizontal: 15),
      searchBarStyle: SearchBarStyle(borderRadius: BorderRadius.circular(30), padding: EdgeInsets.only(left: 10)),
      headerPadding: EdgeInsets.symmetric(horizontal: 10),
      listPadding: EdgeInsets.symmetric(horizontal: 10),
      textStyle: GoogleFonts.roboto().copyWith(fontSize: 20),
      onSearch: _getUsers,
      placeHolder: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ralewayText("Search Phone Numbers"),
      ),
      cancellationWidget: Text("Cancel"),
      emptyWidget: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ralewayText('No Users Found'),
      ),
      onError: (err){
        return textMessage('Error occurred ${err.stackTrace.toString()}');
      },

      // mainAxisSpacing: 10,
      // crossAxisSpacing: 10,
      // crossAxisCount: 2,
      onItemFound: (UserData user, int index) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            // leading: numberAvatar(index),
            title: Text(user.name.capitalize(), style: GoogleFonts.raleway().copyWith(fontSize: 16),),
            leading: circleAvatar(getStringInitials(user.name)),
            trailing: Container(
              margin: EdgeInsets.all(5),
              child: FittedBox(
                child: OutlineButton(
                    disabledBorderColor: Theme.of(context).accentColor,
                    color: Theme.of(context).accentColor,
                    textColor: getBlackWhiteColorWithTheme(context),
                    onPressed: ()=>_inviteUser(context, user),
                    child: Row(
                      children: [ralewayText('Invite', fontSize: 15), SizedBox(width: 8,),
                      Icon(Icons.person_add_alt_1_outlined, color: getBlackWhiteColorWithTheme(context),)],),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0))
                ),
              ),
            ),

            subtitle:  hasContactPermission ? _findPhone(context, user.phone,) : SizedBox(),
          ),
        );
      },
    );
  }

  Widget _findPhone(BuildContext context, String phone){

    phone = phone.replaceAll(currentDialCode, '');
    Widget widget = ralewayText('Not in contact', fontSize: 10,);

    phoneContacts.forEach((key, value) {

      if(value.contains(phone))
        {
          widget = ralewayText('In your contact with name $key', fontSize: 10,);
          return;
        }

    });

    return widget;

  }

   _inviteUser(BuildContext context, UserData user)async{
      //check if user has joined any family
     var familyMemberSnapshot = await familyMemberRef.doc(user.uid).get();
     var familyId = await getPrefValue(uid);

     if(familyMemberSnapshot.exists){
       showSnackBar(context, 'This user is already in a family. We will send a notification to this user');

       var id = 'Notification_${DateTime.now().millisecondsSinceEpoch}';
       var data = NotificationData(from: uid, familyId: familyId,
           createdAt: DateTime.now().millisecondsSinceEpoch,
           title: '${currentUser.displayName} has requested you to join his family',
           to: user.uid,
       id: id)
           .toJson();

       notificationRef.doc(id).set(data);
       showSnackBar(context, 'User Notified');
       return;
     }

     //user not exists will add him
     var confirmation = await showConfirmDialog(context, 'You are about to add ${user.name} to your family.\n\nNote: User will be able to see your expense data as soon as you add him');
     if(!confirmation) return;


      familyMemberRef.doc(user.uid).set(FamilyMember(uid: user.uid, familyId: familyId, moderator: false, verified: true).toJson())
          .then((value) {
        Fluttertoast.showToast(msg: 'User added successfully');
        Navigator.pop(context);
     });

  }


  // _getUsers(String text){
  //
  // }
}



