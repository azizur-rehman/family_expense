import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyWidget extends StatefulWidget {

  @override
  _FamilyWidgetState createState() => _FamilyWidgetState();
}

class _FamilyWidgetState extends State<FamilyWidget> {

  var isAmModerator = false;

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(

      child: FutureBuilder<SharedPreferences>(
        future: getPref(),
        builder: (context, pref) {

          if(pref.hasError)
            return textMessage(pref.error.toString());

          if(!pref.hasData)
            return circularProgressBar;

          String familyId = pref.data.getString(uid);
          print('Family Id - $familyId');
          print(pref.data.getKeys());

          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [

                Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(height: 5,),
                        Text('Family Code',  style: GoogleFonts.raleway().copyWith(fontWeight: FontWeight.w300, fontSize: 20)),
                        Text('Use this code to Join',  style: GoogleFonts.raleway().copyWith(fontWeight: FontWeight.w100, fontSize: 12)),
                        SizedBox(height: 15,),
                        //family id
                        if(familyId != null) loadFamilyCode(familyId)
                        else Padding(padding: const EdgeInsets.all(8.0), child: Text('Failed to load Family Code'),)


                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10,),
                Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child:Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(height: 5,),
                          Text('Family Members',  style: GoogleFonts.raleway().copyWith(fontWeight: FontWeight.w300, fontSize: 20)),
                          SizedBox(height: 15,),

                          Divider(height: 1,color: Colors.grey,),

                          StreamBuilder<QuerySnapshot>(
                            stream: familyMemberRef.where('familyId', isEqualTo: familyId).snapshots(),
                            builder: (context, snapshot){

                              if(snapshot.hasError)
                                return Text(snapshot.error.toString());

                              if(!snapshot.hasData)
                                return circularProgressBar;

                              isAmModerator = FamilyMember.fromJson(snapshot.data.docs.firstWhere((element) => element.get("uid") == uid).data()).moderator;

                              return ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {

                                  FamilyMember member = FamilyMember.fromJson(snapshot.data.docs[index].data());

                                  return Slidable(
                                      actionPane: SlidableDrawerActionPane(),
                                      actionExtentRatio: 0.25,
                                      secondaryActions: <Widget>[
                                       IconSlideAction(
                                          caption: 'Remove',
                                          color: Colors.red,
                                          iconWidget: Icon(Icons.delete),
                                          onTap: () => _removeMember(member),
                                        ),
                                      ],
                                      child: ListTile(
                                      leading: numberAvatar(index),
                                      title: loadName(member.uid, Theme.of(context).textTheme.subtitle1),
                                      subtitle: _getListSubtitle(member),

                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          member.moderator ? Container( decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),border: Border.all(width: 0.1, color: Theme.of(context).textTheme.bodyText1.color) ), child: Text('Moderator', style: Theme.of(context).textTheme.caption,), padding: EdgeInsets.all(10),) : SizedBox()
                                        ],
                                      ),
                                    ),

                                  );
                                },
                                itemCount: snapshot.data.size,

                              );
                            },),



                        ],
                      ),
                    )
                ),
              ],
            ),
          );

      },
      ),

    );
  }


  Widget _getListSubtitle(FamilyMember member){

    print(member.toJson());

    if(member.verified)
      return Text(uid == member.uid ? 'You' : '');

    if(isAmModerator)
      //someone else
      return Row(
        //accept button
        children: [
          ButtonTheme(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            buttonColor: Colors.red,
            child: RaisedButton(
              textColor: Colors.white,
              onPressed: () {
                _removeMember(member);
              },
              child: Text("Reject"),
            ),
          ),

          SizedBox(width: 10,),
          ButtonTheme(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            buttonColor: Colors.green,
            child: RaisedButton(
              textColor: Colors.white,
              onPressed: () {
                showProgressSnack(context, 'Accepting Member');
                familyMemberRef.doc(member.uid).update({'verified':true})
                    .then((value) => showSnackBar(context, 'Member request accepted'))
                    .catchError( (onError) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
              },
              child: Text("Accept"),
            ),
          )
        ],
      );

    return SizedBox();
  }

  void _removeMember(FamilyMember member)async{
    var confirmPrompt = await showConfirmDialog(context, 'Would you like to remove this member?');

    if(!confirmPrompt)
      return;

    if(!isAmModerator){
      showSnackBar(context, "You don't have authority to remove a member");
      return;
    }

    if(member.uid == uid){
      //me
      showSnackBar(context, "You cannot remove yourself as a member");
      return;
    }

    showProgressSnack(context, 'Removing Member');
    familyMemberRef.doc(member.uid).delete()
        .then((value) { ScaffoldMessenger.of(context).hideCurrentSnackBar(); showSnackBar(context, 'Member removed');})
        .catchError( (onError) => ScaffoldMessenger.of(context).hideCurrentSnackBar());

  }

}
