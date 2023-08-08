import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentsWidget extends StatelessWidget {

  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ralewayText('Payments'),),
      body: Container(
        child: FutureBuilder(
          future: getPrefValue(uid!),
          builder: (context, familySnapshot){

            if(familySnapshot.connectionState == ConnectionState.waiting)
              return circularProgressBar;

            print(familySnapshot.error);
                //first get individual notifications
            return FutureBuilder<QuerySnapshot>(
              future: familyPaymentsRef.where(key_familyId, isEqualTo: familySnapshot.data).orderBy('updatedOn', descending: true).get(),
              builder: (context, payments){

                if(payments.connectionState == ConnectionState.waiting)
                  return circularProgressBar;

                if(payments.hasError || !payments.hasData)
                  return _bindList([]);


                List<PaymentModel> list = payments.data?.docs.map((e) => PaymentModel.fromJson(e.data()  as Map<String, dynamic>)).toList()??[];

                return _bindList(list);


              },
            );

          },
        ),
      ),
    );
  }

  Widget _bindList(List<PaymentModel> list){

    if(list.isEmpty)
      return getPlaceholderWidget('No payments added yet',  svgAsset: "money.svg");

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index){
        PaymentModel payment = list[index];

        return Card(
          // color: notification.read == true ?  null : Colors.red[300]  ,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: circleAvatar('${index+1}'),
            title:  loadName(payment.uid, GoogleFonts.raleway()),
            // subtitle: ralewayText(list[index].body == null ? '' : list[index].body == null, fontSize: 13),
            subtitle: Text(('${formattedDate(payment.updatedOn!)}'), style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10, ),),
            trailing: Text(('${getCurrency()} ${list[index].amount}'), style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 22, ),),
          ),
        );
      },
    );
  }

}
