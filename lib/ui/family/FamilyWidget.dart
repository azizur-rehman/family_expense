import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/ui/auth/JoinFamilyWidget.dart';
import 'package:family_expense/ui/family/invite_family_member.dart';
import 'package:family_expense/ui/family/sharing_percentage.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:family_expense/utils/extensions/Extensions.dart';

class FamilyWidget extends StatefulWidget {

  @override
  _FamilyWidgetState createState() => _FamilyWidgetState();
}

class _FamilyWidgetState extends State<FamilyWidget> {

  var isAmModerator = false;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

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

          String? familyId = pref.data?.getString(uid!);
          print('Family Id - $familyId');
          print(pref.data?.getKeys());

          return _getMainWidget(familyId);

      },
      ),

    );
  }

  Widget _getMainWidget(String? familyId){

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [


          Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child:Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Statistics',  style: GoogleFonts.raleway().copyWith(fontWeight: FontWeight.w300, fontSize: 20)),

                      ],
                    ),
                    SizedBox(height: 15,),

                    Divider(height: 1,color: Colors.grey,),

                    SizedBox(height: 15,),

                    familyId != null ? FutureBuilder<QuerySnapshot>(
                      future: itemRef.where(key_familyId, isEqualTo: familyId).where(key_familyId, isNotEqualTo: null).get(),
                      builder: (context, snapshot){

                        if(snapshot.hasError)
                          return Text(snapshot.error.toString());

                        if(!snapshot.hasData)
                          return circularProgressBar;

                        var list = snapshot.data!.docs.map((e) => Item.fromJson(e.data() as Map<String, dynamic>)).toList();

                        return Column(
                          children: [

                            ListTile(
                              leading: ralewayText('Items purchased this month'),
                              trailing: ralewayText('${list.where((e) => e.purchaseDate!>=thisMonthStartMillis).length}'),
                            ),

                            ListTile(
                              leading: ralewayText('Money spent this month'),
                              trailing: ralewayText('${formatMoney(list.where((e) => e.purchaseDate!>=thisMonthStartMillis).toList().sumBy((e) => e.itemPrice!).toString())}'),
                            ),

                            SizedBox(height: 20,),

                            ListTile(
                              leading: ralewayText('Total items purchased'),
                              trailing: ralewayText('${snapshot.data?.size??0}'),
                            ),

                            ListTile(
                              leading: ralewayText('Total money spent'),
                              trailing: ralewayText('${formatMoney(list.sumBy((e) => e.itemPrice!).toString())}'),
                            )

                          ],

                        );

                      },) : getPlaceholderWidget('You need to be in a family to view',svgAsset: 'group.svg', height: 80),



                  ],
                ),
              )
          ),


          SizedBox(height: 10,),
          Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child:Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Family Members',  style: GoogleFonts.raleway().copyWith(fontWeight: FontWeight.w300, fontSize: 20)),
                        IconButton(icon: Icon(Icons.person_add_alt_1_rounded), onPressed: (){
                          if(isAmModerator)
                            moveToPage(context, InviteMemberWidget());
                          else
                            showSnackBar(context, 'Only Moderators are allowed to add members');
                        },)
                      ],
                    ),
                    SizedBox(height: 15,),

                    Divider(height: 1,color: Colors.grey,),

                    StreamBuilder<QuerySnapshot>(
                      stream: familyMemberRef.where('familyId', isEqualTo: familyId).snapshots(),
                      builder: (context, snapshot){

                        if(snapshot.hasError)
                          return Text(snapshot.error.toString());

                        if(!snapshot.hasData)
                          return circularProgressBar;


                        if(snapshot.data!.docs.isEmpty || snapshot.data!.size == 0)
                          return getPlaceholderWidget('No members here to show', svgAsset: 'people.svg', height: 100);

                        FamilyMember me;

                        try {
                          me = FamilyMember.fromJson(snapshot.data!.docs.firstWhere((element) => element.get("uid") == uid).data() as Map<String, dynamic>);
                          isAmModerator = me.moderator!;
                        }catch(e){
                          return getPlaceholderWidget('No members here to show', svgAsset: 'people.svg', height: 100);
                        }

                        if(!me.verified!)
                          return getPlaceholderWidget('You need to be verified to view members', svgAsset: 'people.svg', height: 100);

                        List<FamilyMember> members = snapshot.data?.docs.map((e) => FamilyMember.fromJson(e.data() as Map<String, dynamic>)).toList()??[];

                        return Column(
                          children: [
                            ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {

                                FamilyMember member = FamilyMember.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);

                                print('memeber name => ${member.name}');

                                return Slidable(
                                  dragStartBehavior: DragStartBehavior.start,
                                  startActionPane: ActionPane(motion: ScrollMotion(), children: member.uid != uid ? [

                                    SlidableAction(
                                      onPressed: (context) => _removeMember(member),

                                      foregroundColor: Theme.of(context).primaryColor,
                                      backgroundColor: Colors.transparent,
                                      icon: Icons.delete,
                                      label: 'Remove',
                                    ),
                                    SlidableAction(
                                      onPressed: (ctx) async{

                                        if(isAmModerator) {
                                          var confirm = await showConfirmDialog(context, member.moderator! ? 'Remove this user from moderator?' : 'Make this user as moderator?');
                                          if(!confirm) return;

                                          familyMemberRef.doc(member.uid).update(
                                              {'moderator': !member.moderator!});
                                        }
                                        else
                                          showSnackBar(context, 'You are not authorized to do this');
                                      },

                                      foregroundColor: Theme.of(context).primaryColor,
                                      backgroundColor: Colors.transparent,
                                      icon: Icons.person_outline_rounded,
                                      label: '${member.moderator! ? 'Remove' : 'Make' } Moderator',
                                    ),

                                  ]:[]),

                                  child: ListTile(
                                    leading: circleAvatar(getStringInitials(member.name??'Family Member')),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(member.name??'Family Member', style:Theme.of(context).textTheme.subtitle1),
                                         _getListSubtitle(member),
                                      ],
                                    ),

                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        member.moderator! ? Container( decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),border: Border.all(width: 0.1, color: Theme.of(context).textTheme!.bodyText1!.color!) ), child: Text('Moderator', style: Theme.of(context).textTheme.caption,), padding: EdgeInsets.all(10),) : SizedBox()
                                      ],
                                    ),
                                  ),

                                );
                              },
                              itemCount: snapshot.data?.size??0,

                            ),

                            Divider(),

                            Row(
                              mainAxisAlignment:MainAxisAlignment.spaceAround,
                              children: [

                                OutlinedButton.icon(
                                  label: ralewayText('Edit Member Sharing', style: GoogleFonts.raleway().copyWith()),
                                  onPressed: ()=> isAmModerator ? moveToPage(context, SharingPercentWidget(members: members,)) : showSnackBar(context, 'You are not authorized to edit sharing percentage'),
                                  icon: Icon(Icons.edit_outlined, ),
                                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25),),
                                ),
                              ],
                            )
                          ],
                        );
                      },),



                  ],
                ),
              )
          ),

          SizedBox(height: 10,),

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
                  else getPlaceholderWidget('Not joined any family yet', height: 80, svgAsset: 'people.svg', onTap: ()=>moveToPage(context, JoinOrCreateFamilyWidget())),

                  SizedBox(height: 8,)

                ],
              ),
            ),
          ),

          SizedBox(height: 40,),


          TextButton.icon(onPressed: ()async{
            var confirm = await showConfirmDialog(context, 'Are you sure you want to leave this family?');
            if(confirm){

              showProgressSnack(context, 'Exiting the Family');
              var otherMemberSnapshot = await familyMemberRef.where('familyId', isEqualTo: familyId)//.where('uid', isNotEqualTo: uid)
                  .get();
              //make someone admin then leave
              try{
                if(otherMemberSnapshot.docs.isNotEmpty) {
                  FamilyMember me = FamilyMember.fromJson(otherMemberSnapshot.docs.where((e) => e.get('uid') == uid).first.data());
                  var member = FamilyMember.fromJson( otherMemberSnapshot.docs.where((e) => e.get('uid') != uid).first.data());
                  familyMemberRef.doc(member.uid).update({'moderator': true, 'sharePercent':member.sharePercent!+me.sharePercent!});
                }
              }
              catch(err){
                print(err);
                // showSnackBar(context, 'Failed to leave family : $err');
                // return;
              }

              familyMemberRef.doc(uid).delete()
                  .then((value) { ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.popUntil(context, ModalRoute.withName('/'),);
                    //delete family id from pref
                    moveToPage(context, JoinOrCreateFamilyWidget());
                    deleteKey(uid!);

                  })
                  .catchError( (onError) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
            }
          }, icon: Icon(Icons.logout), label: ralewayText('Leave Family'), // padding: EdgeInsets.all(20),
          ),

          SizedBox(height: 20,)

        ],
      ),
    );
  }


  Widget _getListSubtitle(FamilyMember member){

    print(member.toJson());

    if(member.verified!)
      return Text(uid == member.uid ? 'You' : '');

    if(isAmModerator)
      //someone else
      return Row(
        //accept button
        children: [
          ButtonTheme(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            buttonColor: Colors.red,
            child: ElevatedButton(
              // textColor: Colors.white,
              onPressed: () {
                _removeMember(member);
              },
              child: Text("Reject", style: TextStyle(color: Colors.white),),
            ),
          ),

          SizedBox(width: 10,),
          ButtonTheme(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            buttonColor: Colors.green,
            child: ElevatedButton(
              // textColor: Colors.white,
              onPressed: () {
                showProgressSnack(context, 'Accepting Member');
                familyMemberRef.doc(member.uid).update({'verified':true})
                    .then((value) => showSnackBar(context, 'Member request accepted'))
                    .catchError( (onError) => ScaffoldMessenger.of(context).hideCurrentSnackBar());
              },
              child: Text("Accept", style: TextStyle(color: Colors.white)),
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
