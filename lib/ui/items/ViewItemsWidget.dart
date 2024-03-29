import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:family_expense/utils/extensions/Extensions.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';

class ViewItemsWidget extends StatelessWidget {

  final String? familyId;
  ViewItemsWidget({Key? key, this.familyId}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All items'),),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(0),
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child:Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [


                // FirestoreListView<Map<String, dynamic>>(
                //   physics: NeverScrollableScrollPhysics(),
                //   pageSize: 5,
                //   query: itemRef.orderBy('purchaseDate', descending: true).where('familyId', isEqualTo: familyId),
                //   itemBuilder: (context, snapshot) {
                //     final item = Item.fromJson(snapshot.data());
                //     // return Text('User name is ${user['name']}');
                //
                //     // var elements = snapshot.data().map((e) => Item.fromJson(e.data()  as Map<String, dynamic>)).toList()??[];
                //     var position = 0;
                //     // elements.forEach((element) { print(formattedDate(element.purchaseDate));});
                //
                //     return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                //         child: bindPurchaseListItem(context, item, position++, false));
                //
                //
                //     // return GroupedListView<Item, String>(
                //     //   scrollDirection: Axis.vertical,
                //     //   shrinkWrap: true,
                //     //   elements: elements,
                //     //   groupBy: (element) => formattedDate(element.purchaseDate!),
                //     //   groupSeparatorBuilder: (String groupByValue) { position=0;return Center(child: textMessage(groupByValue),);  },
                //     //   itemBuilder: (BuildContext context, Item element) {
                //     //     return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                //     //         child: bindPurchaseListItem(context, element, position++, false));
                //     //   },
                //     //
                //     //   itemComparator: (item1, item2) => item1.purchaseDate!.compareTo(item2.purchaseDate!), // optional
                //     //   useStickyGroupSeparators: true,
                //     //   // optional
                //     //   floatingHeader: true,
                //     //   // optional
                //     //   order: GroupedListOrder.DESC, // optional
                //     // );
                //   },
                // ),


                StreamBuilder<QuerySnapshot>(stream: itemRef.orderBy('purchaseDate', descending: true).where('familyId', isEqualTo: familyId)
                    .snapshots(),
                  builder: (context, snapshot) {
                    return _bindItem(context, snapshot);
                  }
                )

              ],
            ),
          )
      ),
    );
  }

  _bindItem(BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot){

    if (snapshot.connectionState == ConnectionState.waiting) {
      return circularProgressBar;
    }

    if (snapshot.hasError || !snapshot.hasData) {
      print(snapshot.error);
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(child: textMessage('No Items found'),),
      );
    }
    var elements = snapshot.data?.docs.map((e) => Item.fromJson(e.data()  as Map<String, dynamic>)).toList()??[];
    var position = 0;
    // elements.forEach((element) { print(formattedDate(element.purchaseDate));});


    return GroupedListView<Item, String>(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      elements: elements,
      groupBy: (element) => (formattedDate(element.purchaseDate!)),// + "---"+elements.where((e) => e.purchaseDate == element.purchaseDate).toList().sumBy((i)=>i.itemPrice??0.0).toString()),
      groupSeparatorBuilder: (String groupByValue) { position=0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
          child: Row(
            children: [
              Expanded(child: ralewayText(groupByValue)),
              textMessage('Total : '+formatMoney(elements.where((element) => formattedDate(element.purchaseDate!) == groupByValue).toList().sumBy((element) => element.itemPrice??0).toString())),
            ],
          ),
        );
        },
      itemBuilder: (BuildContext context, Item element) {
        return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: bindPurchaseListItem(context, element, position++, false));
      },

      itemComparator: (item1, item2) => item1.purchaseDate!.compareTo(item2.purchaseDate!), // optional
      useStickyGroupSeparators: true,
      // optional
      floatingHeader: true,
      // optional
      order: GroupedListOrder.DESC, // optional
    );
  }



}
