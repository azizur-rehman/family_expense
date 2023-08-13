import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/ui/auth/LoginMainWidget.dart';
import 'package:family_expense/ui/profile/check_for_update.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:family_expense/utils/extensions/Extensions.dart';
import 'package:in_app_update/in_app_update.dart';

class MyProfileWidget extends StatefulWidget {
  @override
  _MyProfileWidgetState createState() => _MyProfileWidgetState();
}

class _MyProfileWidgetState extends State<MyProfileWidget> {

  TextEditingController _nameController = TextEditingController();
  var uid = FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser?.uid : null;

  @override
  void initState() {
    // FirebaseAuth.instance.currentUser.reload().then((value) =>
    _nameController.text = (FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser?.displayName : null)!;
    // );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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

                      FutureBuilder<QuerySnapshot>(
                        future: itemRef.where('addedBy', isEqualTo: uid).get(),
                        builder: (context, snapshot){

                          if(snapshot.hasError)
                            return Text(snapshot.error.toString());

                          if(!snapshot.hasData)
                            return circularProgressBar;

                          var list = snapshot.data!.docs.map((e) => Item.fromJson(e!.data() as Map<String, dynamic>)).toList();

                          return Column(
                            children: [

                              ListTile(
                                leading: ralewayText('Items purchased this month'),
                                trailing: ralewayText('${list.where((e) => e.purchaseDate!>=thisMonthStartMillis).length}'),
                              ),

                              ListTile(
                                leading: ralewayText('Money spent this month'),
                                trailing: ralewayText('${formatMoney(list.where((e) => e.purchaseDate!>=thisMonthStartMillis).toList().sumBy((e) => e.itemPrice?.toDouble()??0.0).toString())}'),
                              ),

                              SizedBox(height: 20,),

                              ListTile(
                                leading: ralewayText('Total items purchased'),
                                trailing: ralewayText('${snapshot.data?.size??0}'),
                              ),

                              ListTile(
                                leading: ralewayText('Total money spent'),
                                trailing: ralewayText('${formatMoney(list.sumBy((e) => e.itemPrice?.toDouble()??0.0).toString())}'),
                              )

                            ],

                          );

                        },),



                    ],
                  ),
                )
            ),


            SizedBox(height: 8,),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle().copyWith(fontSize: 30, fontWeight: FontWeight.w500 ),
                      decoration: InputDecoration(
                          labelText: "What's your good name?",
                          labelStyle: TextStyle(fontWeight: FontWeight.w300,  fontSize: 22, ),
                          hintText: "Name",
                          border: InputBorder.none,

                          hintStyle: TextStyle().copyWith(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.grey[400])
                      ),
                    ),
                    SizedBox(height: 20,),
                    MaterialButton(
                      minWidth: 180,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: Colors.lightBlueAccent,
                      child: ralewayText('Save', style: GoogleFonts.raleway().copyWith(color: Colors.white)),
                      onPressed: ()async{
                        //save user name
                        String name = _nameController.text;
                        if(name.isEmpty){
                          showSnackBar(context, 'Name cannot be empty');
                          return;
                        }
                        showProgressSnack(context, 'Updating your name');

                        FirebaseAuth.instance.currentUser?.updateDisplayName(name).then((value) {
                          currentUser?.reload();
                          print('Updating name to ${name} at ${userRef.doc(uid).path}, user = $currentUser');
                          userRef.doc(uid).update({'name': name}).then((value) {
                            hideSnackBar(context);
                            showSnackBar(context, 'Your name has been updated');
                            //update to family member
                            familyMemberRef.doc(uid).update({'name' : name});
                          } )
                              .catchError((onError) {hideSnackBar(context); showSnackBar(context, onError); });

                        } );


                      },
                    )
                  ],
                ),
              ),
            ),

            // SizedBox(height: 20,),
            //
            // TextButton(onPressed: ()async{
            //   moveToPage(context, CheckForUpdateScreen());
            // },
            //   child: Text('Check For Update'),
            //
            // ),


            SizedBox(height: 50,),

            TextButton.icon(onPressed: ()async{
              var confirmation = await showConfirmDialog(context, 'Are you sure you want to logout?');
              if(!confirmation) return;

              await FirebaseAuth.instance.signOut();
              //clear preferences
              getPref().then((value) => value.clear());
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginMainWidget()
                  ),
                  ModalRoute.withName("/HomeWidget")
              );
            }, icon: Icon(Icons.logout), label: ralewayText('Logout'), style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(20)
            ), ),


          ],
        ),
      ),
    );
  }
}
