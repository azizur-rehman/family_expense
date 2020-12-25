import 'dart:io';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/model/Models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

String validateMobile(String value) {
  String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return 'Please enter mobile number';
  }
  else if (!regExp.hasMatch(value)) {
    return 'Please enter valid mobile number';
  }
  return null;
}


void showSnackBar(BuildContext context, String text){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text),));

}

Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

Widget circularProgressBar = Center(child:Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2,),));


Widget textMessage(String message ) => Padding(padding: EdgeInsets.all(15), child: Text(message),);

Widget numberAvatar(int index) =>   CircleAvatar(child: Text((index+1).toString(),style: GoogleFonts.roboto().copyWith(color: Colors.white),), backgroundColor: Colors.redAccent,);

// Widget dateCircle(int millis) {
//   String date = formattedDate(millis);
// }

Widget showProgressSnack(BuildContext context, String text){
  SnackBar snackBar = SnackBar(
    // margin: EdgeInsets.all(10),
    duration: Duration(seconds: 30),
    backgroundColor: Colors.grey[700],
    // behavior: SnackBarBehavior.floating,
    content:new Row(
      children: <Widget>[
        circularProgressBar,
        Text("  $text...", style: GoogleFonts.raleway().copyWith(color: Colors.white),)
      ],
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  return snackBar;

}

String formattedDate(int millis) => DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(millis));
String formatDateWithFormatter(int millis, String format) => DateFormat(format).format(DateTime.fromMillisecondsSinceEpoch(millis));


Widget bindPurchaseListItem(BuildContext context, Item item, int index, bool requireDate){
  return Slidable(
    actionPane: SlidableDrawerActionPane(),
    actionExtentRatio: 0.25,
    secondaryActions: <Widget>[
      IconSlideAction(
        caption: 'Remove',
        color: Colors.red,
        iconWidget: Icon(Icons.delete),
        onTap: ()async {
          var confirm = await showConfirmDialog(context, 'Would you like to delete this item?');
            if(!confirm) return;

          showProgressSnack(context, 'Removing Item');
          itemRef.doc(item.itemId).delete()
              .then((value) { ScaffoldMessenger.of(context).hideCurrentSnackBar(); showSnackBar(context, 'Item removed');})
              .catchError( (onError) => ScaffoldMessenger.of(context).hideCurrentSnackBar());

        },
      ),
    ],
    child: ListTile(
      leading: numberAvatar(index),
      title: Text(item.itemName),
      subtitle: loadName(item.addedBy, Theme.of(context).textTheme.caption),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${getCurrency()} ${item.itemPrice.toString()}', style: GoogleFonts.roboto().copyWith(fontWeight: FontWeight.w100, fontSize: 24),),
          if(requireDate) Text(formattedDate(item.purchaseDate), style: Theme.of(context).textTheme.caption,) else SizedBox()
        ],
      ),
    ),
  );
}


String rupee_symbol = '₹';
String getCurrency() {
  var format = NumberFormat.simpleCurrency(locale: Platform.localeName);
  return format.currencySymbol;
}

Future<bool> showConfirmDialog(BuildContext context, String message)async{
  return  await confirm(
    context,
    title: Text('Confirm'),
    content: Text(message),
    textOK: Text('Yes'),
    textCancel: Text('No'),
  );
}