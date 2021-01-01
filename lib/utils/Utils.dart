import 'dart:io';
import 'dart:math';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/ui/items/AddItemDialogWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:family_expense/utils/extensions/Extensions.dart';

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

void hideSnackBar(BuildContext context) => ScaffoldMessenger.of(context).hideCurrentSnackBar();


Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

Widget circularProgressBar = Center(child:Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2,),));


Widget textMessage(String message ) => Padding(padding: EdgeInsets.all(15), child: Text(message),);

Widget ralewayText(String text, {double fontSize = 18, TextStyle style }) => Text(text.capitalize(), style: (style != null ? style : GoogleFonts.raleway()).copyWith(fontSize: fontSize),);


Widget numberAvatar(int index) => circleAvatar((index+1).toString());
Widget circleAvatar(String text) =>   CircleAvatar(child: Text(text.toUpperCase(),style: GoogleFonts.roboto().copyWith(color: Colors.white),), backgroundColor: Colors.blueAccent,);

// Widget dateCircle(int millis) {
//   String date = formattedDate(millis);
// }

Widget showProgressSnack(BuildContext context, String text){
  SnackBar snackBar = SnackBar(
    // margin: EdgeInsets.all(10),
    duration: Duration(seconds: 30),
    backgroundColor: Colors.grey[700],
    behavior: SnackBarBehavior.floating,
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
    actionExtentRatio: 0.12,
    secondaryActions: <Widget>[
      IconSlideAction(
        // caption: 'Remove',
        color: Colors.transparent,
        iconWidget: Icon(Icons.delete, color: getBlackWhiteColorWithTheme(context) ,),
        onTap: ()async {
          var confirm = await showConfirmDialog(context, 'Would you like to delete this item?');
            if(!confirm) return;

          showProgressSnack(context, 'Removing Item');
          itemRef.doc(item.itemId).delete()
              .then((value) { ScaffoldMessenger.of(context).hideCurrentSnackBar(); showSnackBar(context, 'Item removed');})
              .catchError( (onError) => ScaffoldMessenger.of(context).hideCurrentSnackBar());

        },
      ),

      IconSlideAction(
        // caption: 'Edit',
        color: Colors.transparent,
        // color: Colors.green,
        iconWidget: Icon(Icons.edit_outlined , color: getBlackWhiteColorWithTheme(context),),
        onTap: ()async {
          var familyId = await getPrefValue(uid);
          moveToPage(context, AddItemDialogWidget(familyId: familyId, item: item,));
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
          Text('${getCurrency()} ${item.itemPrice.toString()}', style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.w300, fontSize: 22),),
          if(requireDate) Text(formattedDate(item.purchaseDate), style: Theme.of(context).textTheme.overline,) else SizedBox()
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

var thisMonthStartMillis = DateFormat("dd-MM-yyyy").parse("01-${DateTime.now().month}-${DateTime.now().year}").millisecondsSinceEpoch;


moveToPage(BuildContext context, Widget widget) => Navigator.push(context, MaterialPageRoute(builder: (builder) => widget));


Widget getPlaceholderWidget(String text,  {String svgAsset, double height = 160.0, VoidCallback onTap,}){

  String path = "assets/icons";

  if(svgAsset == null)
    svgAsset = "$path/login.svg";
  else
    svgAsset = "$path/$svgAsset";

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GestureDetector(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(svgAsset, height: height,),
          SizedBox(height: 30,),
          Center(child: ralewayText(text)),
        ],
      ),
      onTap: onTap,
    ),
  );
}

Color randomColor(){
  var colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.deepOrange, Colors.cyanAccent];
  colors.shuffle();
  return colors[Random().nextInt(colors.length-1)];
}


bool isDarkMode(BuildContext context) => MediaQuery.of(context).platformBrightness == Brightness.dark;

Color getBlackWhiteColorWithTheme(BuildContext context) => isDarkMode(context) ? Colors.white : Colors.black;
