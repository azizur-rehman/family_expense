
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/ui/auth/JoinFamilyWidget.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:family_expense/utils/extensions/Extensions.dart';
import 'package:google_fonts/google_fonts.dart';
class AddPaymentWidget extends StatelessWidget {

  final String familyId;
  final List<FamilyMember> members;

  final Map maxCollection ;
  AddPaymentWidget({Key key, this.familyId, this.members, this.maxCollection}):super(key:key);
  final String uid = FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser.uid : null;


  @override
  Widget build(BuildContext context) {
    // String familyId = familyId;
    var query = familyMemberRef.where("uid", isEqualTo: uid).where("familyId", isEqualTo: familyId).where('verified', isEqualTo: true);
    if(familyId == null || familyId.isEmpty){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'You are not in a family yet');
      return SizedBox();
    }

    print('MAx  = ${this.maxCollection}');


    return Scaffold(
      appBar: AppBar(title: ralewayText('Add Payment'),),
      body: Column(
        children: [

          FutureBuilder<QuerySnapshot>(
              future: query.get(),
              builder: (context, snapshot){

                if(snapshot.connectionState == ConnectionState.waiting)
                  return Center( child: circularProgressBar);

                if(!snapshot.hasData || snapshot.hasError)
                  return getPlaceholderWidget('You are not allowed to add items. Contact the moderator');

                return _bodyContainer(familyId: familyId, members: members , maxCollection: this.maxCollection,);
            }
          )


        ],
      ),
    );
  }


}

// ignore: camel_case_types
class _bodyContainer extends StatefulWidget {

  final String familyId;
  final List<FamilyMember> members;
  final String uid = FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser.uid : null;

  final Map maxCollection ;
  _bodyContainer({Key key, this.familyId, this.members, this.maxCollection}):super(key:key);

  @override
  __bodyContainerState createState() => __bodyContainerState();
}

// ignore: camel_case_types
class __bodyContainerState extends State<_bodyContainer> {


  final TextEditingController _priceController = TextEditingController();

  var isInserting = false;
  var _memberListIndex = 0;
  FamilyMember member;


  @override
  Widget build(BuildContext context) {
    print(widget.members.map((e) => e.name));
    return Container(
        child: Column(
          children: [

            SizedBox(height: 20,),

            ralewayText('Select the Member'),

            SizedBox(height: 20,),

            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: List.generate(widget.members.length, (index) {
                FamilyMember member = widget.members[index];
                return Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilterChip(
                  labelStyle: TextStyle(color: Colors.white),
                  // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  labelPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  label: ralewayText(member.name.toString().capitalize()),
                  // labelStyle: TextStyle(color: Colors.white),
                  selected: _memberListIndex == index,
                  selectedColor: Colors.lightBlue,
                  // avatar: circleAvatar(getStringInitials(member.name)),
                  onSelected: (bool selected) {
                    setState(() {
                      print(index );
                      print(selected);
                      _memberListIndex = selected ? index : null;
                    });
                  },
                ),
              );
              }),
            ),

            SizedBox(height: 30,),

            Row(
              children: [

                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _priceController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      style: TextStyle().copyWith(fontSize: 26, fontWeight: FontWeight.w500 ),
                      decoration: InputDecoration(
                          labelText: "Enter amount",
                          labelStyle: TextStyle(fontWeight: FontWeight.w300,  fontSize: 22, ),
                          hintText: "Price",
                          border: InputBorder.none,
                          hintStyle: TextStyle().copyWith(fontSize: 26, fontWeight: FontWeight.w300, color: Colors.grey[400])
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 20),

              ],
            ),


            SizedBox(height: 50,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                FutureBuilder(
                  future: getPrefValue(widget.uid),
                  builder: (context, familyId) => MaterialButton(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    color: Colors.grey[200],
                    padding: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                    child: Text('Add Payment', style: TextStyle().copyWith(fontSize: 22, color: Colors.black, fontWeight: FontWeight.w400),),

                    onPressed: ()async{
                      if(isInserting)
                        return;

                      if(familyId == null){
                        Navigator.popUntil(context, ModalRoute.withName('/'),);

                        Navigator.push(context, MaterialPageRoute(builder: (builder)=>JoinOrCreateFamilyWidget()));
                        Fluttertoast.showToast(msg: "You have not joined any family yet.");
                        return;
                      }

                      if( _priceController.text.isEmpty){
                        showSnackBar(context, "All fields required");
                        return;
                      }

                      if(_memberListIndex == null){
                        showSnackBar(context, "Please choose a member");
                        return;
                      }

                      FamilyMember member = widget.members[_memberListIndex];

                      num price = num.tryParse(_priceController.text);
                      print('Max amount = ${widget.maxCollection[member.uid] }');


                      if(price <= 0)
                        return;

                      if(price > widget.maxCollection[member.uid] ){
                        showSnackBar(context, "You cannot collect more than ${member.name}'s balance");
                        return;
                      }

                      if(!await showConfirmDialog(context, 'Add payment for ${member.name}?'))
                        return;

                      //add payment and deduct from remaining amount
                      //first get all payments
                      // var currentFamilyPayments = await familyPaymentsRef.where(key_familyId, isEqualTo: familyId.data).get();
                      // if(currentFamilyPayments.docs.isEmpty)
                      familyPaymentsRef.add(PaymentModel(uid: member.uid, familyId: familyId.data,
                          updatedOn: DateTime.now().millisecondsSinceEpoch, amount: num.parse(_priceController.text)).toJson())
                      .then((value) {
                        Navigator.pop(context);
                        showSnackBar(context, 'Payment added for ${member.name}');
                      });

                    },
                  ),
                ),
              ],
            ),
          ],
        )
    );
  }
}



