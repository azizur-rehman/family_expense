import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/ui/home/HomeWidget.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';

class JoinOrCreateFamilyWidget extends StatefulWidget {
  @override
  _JoinOrCreateFamilyWidgetState createState() => _JoinOrCreateFamilyWidgetState();
}

class _JoinOrCreateFamilyWidgetState extends State<JoinOrCreateFamilyWidget> {

  TextEditingController _joinEditingController = TextEditingController();
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.currentUser?.reload();

    _joinEditingController.text = "";

    _loadExistingFamily();
  }

  _loadExistingFamily()async{


    try {
      var familyMemberSnapshot = await familyMemberRef
          .where('uid', isEqualTo: uid!)
      // .doc(uid!)
          .get();


      FamilyMember? alreadyMember = FamilyMember.fromJson(
          familyMemberSnapshot.docs.first.data());

      var familySnapshot = await familyRef.doc(alreadyMember.familyId).get();

      Family? family = Family.fromJson(familySnapshot.data()!);

      print('family code => ${family.code}');

      setState(() {
        _joinEditingController.text = family.code??'';
      });
    }
    catch(e){
      print(e);
    }

    // .then((value) =>)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
      // title: Text('Join or Create a Family'),
      //   centerTitle: true,
      // ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                MaterialButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  color: Colors.grey[200],
                  padding: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                  child: Text('Create Family', style: TextStyle().copyWith(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w400),),

                  onPressed: (){
                    moveToPage(context, CreateFamilyWidget());
                  },
                ),

                SizedBox(height: 30,),
                Text('Or', style: TextStyle().copyWith(fontSize: 24,  fontWeight: FontWeight.w200),),

              SizedBox(height: 40,),

              // FutureBuilder<QuerySnapshot>(
              //     future: familyMemberRef
              //         .where('uid', isEqualTo: '8I3ITwRAHtMbEFZchFTLp9Z7nPw2'!)
              //         // .doc(uid!)
              //         .get(),
              //     builder: (context, snapshot) {
              //       print(uid!);
              //
              //       snapshot.data?.docs?.forEach((element) { print(element.data() as Map<String,dynamic>);});
              //       if (snapshot.hasData) {
              //         FamilyMember? alreadyMember = FamilyMember.fromJson(snapshot.data?.docs.first.data() as Map<String,dynamic>);
              //         //find family code
              //         FutureBuilder(
              //             future: familyRef.doc(alreadyMember.familyId).get(),
              //             builder: (BuildContext context,
              //                 AsyncSnapshot snapshot) {
              //               if (snapshot.hasData) {
              //                 return widgetToBuild;
              //               } else if (snapshot.hasError) {
              //                 return Icon(Icons.error_outline);
              //               } else {
              //                 return CircularProgressIndicator();
              //               }
              //             })
              //         ;
              //         return SizedBox();
              //       } else if (snapshot.hasError) {
              //         return Icon(Icons.error_outline);
              //       } else {
              //         return CircularProgressIndicator();
              //       }
              //     }),

              TextField(
                controller: _joinEditingController,
                  style: TextStyle().copyWith(fontSize: 30, fontWeight: FontWeight.w500 ),
                  decoration: InputDecoration(
                    labelText: "Enter the Family Code",
                    labelStyle: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 2, fontSize: 30),
                    hintText: "Family Code",
                      border: InputBorder.none,

                      hintStyle: TextStyle().copyWith(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.grey[400])
                  ),
                ),

              SizedBox(height: 60,),

              MaterialButton(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                color: Colors.grey[200],
                padding: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                child: Text('  Join Family  ',
                  style: TextStyle().copyWith(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w400),),

                onPressed: ()async{
                  String familyCode = _joinEditingController.text;
                  if(familyCode.isEmpty) return;

                  showProgressSnack(context, "Checking Family Code");
                  //check family code
                  var familySnapshot = await familyRef.where("code", isEqualTo: familyCode).get();
                  // familyRef.where("code", isEqualTo: familyCode).get().then((value) => print('value = ${value.docs}')).catchError((onError) => print('Error $onError'));
                  // print('family - ${familySnapshot.docs}');

                  await FirebaseAuth.instance.currentUser?.reload();
                  var user = FirebaseAuth.instance.currentUser;

                  if(familySnapshot.docs.isNotEmpty){
                    Family family = Family.fromJson(familySnapshot.docs.first.data());
                    String familyId = family.id!;

                    //check if already added
                    var familyMemberSnapshot = await familyMemberRef.where('uid' , isEqualTo: uid).where('familyId', isEqualTo: familyId).get();
                    if(familyMemberSnapshot.size > 0){
                      //already in the family
                      FamilyMember member = FamilyMember.fromJson(familyMemberSnapshot.docs.first.data());
                      member.name = currentUser?.displayName??'Family Member';
                      familyMemberRef.doc(uid).set(member.toJson());

                      await saveKeyAsync(uid!, familyId);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.pushAndRemoveUntil(
                          context, MaterialPageRoute(builder: (context) => HomeWidget()),
                          ModalRoute.withName("/JoinFamilyWidget")
                      );

                    }
                    else{
                      //add as a member
                      familyMemberRef.doc(uid).set(FamilyMember(uid: uid, familyId: familyId, moderator: false, verified: false, name: currentUser?.displayName).toJson())
                          .then((value) async {
                        Fluttertoast.showToast(msg: 'Your family Request is being sent to the moderator');
                        //add notification
                        notificationRef.add(NotificationData(from: uid, familyId: familyId,
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                            title: '${currentUser?.displayName} wants to join the family').toJson());

                        await saveKeyAsync(uid!, familyId);
                        //clear and navigate to stack
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeWidget()
                            ),
                            ModalRoute.withName("/JoinFamilyWidget")
                        );

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();

                      })
                          .catchError((onError)=> Fluttertoast.showToast(msg: onError.toString()));
                    }

                  }
                  else{
                    Fluttertoast.showToast(msg: "Family Code is Incorrect");
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }

                  //check if is moderator in a family
                  


                },
              ),


            ],
          ),

        ),

      ),
    );
  }
}


class CreateFamilyWidget extends StatefulWidget {

  @override
  _CreateFamilyWidgetState createState() => _CreateFamilyWidgetState();
}

class _CreateFamilyWidgetState extends State<CreateFamilyWidget> {
  TextEditingController _editingController = TextEditingController();

  var isUpdating = false;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: TextField(
                controller: _editingController,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                style: TextStyle().copyWith(fontSize: 30, fontWeight: FontWeight.w500 ),
                decoration: InputDecoration(
                    labelText: "What would you like to name your family?",
                    labelStyle: TextStyle(fontWeight: FontWeight.w300,  fontSize: 22, ),
                    hintText: "Name",
                    border: InputBorder.none,

                    hintStyle: TextStyle().copyWith(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.grey[400])
                ),
              ),
            ),

            SizedBox(height: 100,),

            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              color: Colors.grey[200],
              padding: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
              child: Text('Create Family', style: TextStyle().copyWith(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w400),),

              onPressed: (){

                if(isUpdating)
                  return;

                if(_editingController.text.isEmpty || _editingController.text.length < 4){
                  showSnackBar(context, 'Please enter a valid name');
                  return;
                }

                String familyId = "Family_${DateTime.now().millisecondsSinceEpoch}";
                String code = randomAlphaNumeric(6);
                Family family = Family(code: code,
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    id: familyId,
                    createdBy: uid,
                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                    name: _editingController.text);

                //insert family data
                familyRef.doc(familyId).set(family.toJson())
                    .then((value) {
                  //store pref to local
                  saveKey(uid!, familyId);

                  //save current member as family member
                  familyMemberRef.doc(uid).set(
                      FamilyMember(name: currentUser?.displayName,
                          addedOn: DateTime
                              .now()
                              .millisecondsSinceEpoch,
                          moderator: true,
                          verified: true,
                          uid: uid,
                          familyId: familyId,
                          sharePercent: 100.0
                      ).toJson());

                  // Navigator.push(context, MaterialPageRoute(
                  //     builder: (builder)=>HomeWidget()
                  // ));

                  FirebaseAuth.instance.currentUser?.reload().then((value) {
                    print('reloaded after joining - $currentUser');
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeWidget()
                        ),
                        ModalRoute.withName("/JoinFamilyWidget")
                    );
                  });

                })
                .catchError((onError) {
                  isUpdating = false;
                  showSnackBar(context, onError);
                });

              },
            ),
          ],
        ),
      ),
    );
  }
}
