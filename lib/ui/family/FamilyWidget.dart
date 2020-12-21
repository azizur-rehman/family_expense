import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyWidget extends StatefulWidget {

  @override
  _FamilyWidgetState createState() => _FamilyWidgetState();
}

class _FamilyWidgetState extends State<FamilyWidget> {

  var isModerator = false;

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(

      child: StreamBuilder<SharedPreferences>(
        stream: getPref().asStream(),
        builder: (context, pref) {

        if(pref.hasData)
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
                        if(pref.data.getString(uid) != null) loadFamilyCode(pref.data.getString(uid))
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

                          FutureBuilder<QuerySnapshot>(future: familyMemberRef.where('familyId', isEqualTo: pref.data.getString(uid)).get(),
                            builder: (context, snapshot){

                              if(snapshot.hasError)
                                return Text(snapshot.error.toString());

                              if(!snapshot.hasData)
                                return circularProgressBar;

                              isModerator = FamilyMember.fromJson(snapshot.data.docs.firstWhere((element) => element.get("uid") == uid).data()).moderator;

                              return ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {

                                  FamilyMember member = FamilyMember.fromJson(snapshot.data.docs[index].data());

                                  return ListTile(
                                    leading: CircleAvatar(child: Text((index+1).toString(),style: Theme.of(context).textTheme.headline5,), backgroundColor: Colors.green,),

                                    title: loadName(member.uid),
                                    subtitle: _getListSubtitle(member),

                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        member.moderator ? Container( decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),border: Border.all(width: 0.1, color: Theme.of(context).textTheme.bodyText1.color) ), child: Text('Moderator', style: Theme.of(context).textTheme.caption,), padding: EdgeInsets.all(10),) : SizedBox()
                                      ],
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

        return circularProgressBar;
      },
      ),

    );
  }


  Widget _getListSubtitle(FamilyMember member){

    print(member.toJson());

    if(member.verified)
      return Text(uid == member.uid ? 'You' : '');

    if(isModerator)
      //someone else
      return Row(
        //accept button
        children: [
          ButtonTheme(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            buttonColor: Colors.red,
            child: RaisedButton(
              textColor: Colors.white,
              onPressed: () {},
              child: Text("Reject"),
            ),
          ),

          SizedBox(width: 10,),
          ButtonTheme(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            buttonColor: Colors.green,
            child: RaisedButton(
              textColor: Colors.white,
              onPressed: () {},
              child: Text("Accept"),
            ),
          )
        ],
      );

    return SizedBox();
  }

}
