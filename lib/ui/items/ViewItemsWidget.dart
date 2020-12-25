import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';

class ViewItemsWidget extends StatelessWidget {

  final String familyId;
  ViewItemsWidget({Key key, this.familyId}):super(key: key);

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

                StreamBuilder<QuerySnapshot>(stream: itemRef.orderBy('purchaseDate').where('familyId', isEqualTo: familyId)
                    .snapshots(),
                  builder: (context, snapshot) {
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
                    var elements = snapshot.data.docs.map((e) => Item.fromJson(e.data())).toList();
                    var position = 0;


                    return GroupedListView<Item, String>(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      elements: elements,
                      groupBy: (element) => formattedDate(element.purchaseDate),
                      groupSeparatorBuilder: (String groupByValue) { position=0;
                      return Center(child: textMessage(groupByValue),);  },
                      itemBuilder: (BuildContext context, Item element) {
                        return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: bindPurchaseListItem(context, element, position++, false));
                      },

                      // itemComparator: (item1, item2) => item1['name'].compareTo(item2['name']), // optional
                      useStickyGroupSeparators: true,
                      // optional
                      floatingHeader: true,
                      // optional
                      order: GroupedListOrder.DESC, // optional
                    );
                  }
                )

              ],
            ),
          )
      ),
    );
  }

}
