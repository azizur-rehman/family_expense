import 'dart:io';
import 'dart:math';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/ui/items/AddItemDialogWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:family_expense/utils/extensions/Extensions.dart';
import 'package:random_color/random_color.dart';

String? validateMobile(String value) {
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

Widget ralewayText(String text, {double fontSize = 18, TextStyle? style }) => Text(text.capitalize(), style: (style != null ? style : GoogleFonts.raleway()).copyWith(fontSize: fontSize),);
Widget ralewayTextCentered(String text, {double fontSize = 18, TextStyle? style }) => Text(text.capitalize(), style: (style != null ? style : GoogleFonts.raleway()).copyWith(fontSize: fontSize), textAlign: TextAlign.center,);


Widget numberAvatar(int index) => circleAvatar((index+1).toString());
Widget circleAvatar(String text) =>   Container(
  decoration:  BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
          colors: [
           Color.fromRGBO(0, 198, 255, 1),
            Color.fromRGBO(0, 114, 255, 1),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight
      )
  ),
  child:   CircleAvatar(child: Text(text.toUpperCase(), style: GoogleFonts.roboto().copyWith(color: Colors.white),), backgroundColor: Colors.transparent,),
);

// Widget dateCircle(int millis) {
//   String date = formattedDate(millis);
// }

Widget showProgressSnack(BuildContext context, String text){
  hideSnackBar(context);
  SnackBar snackBar = SnackBar(
    // margin: EdgeInsets.all(10),
    duration: Duration(seconds: 30),
    backgroundColor: Colors.grey[700],
    // behavior: SnackBarBehavior.floating,
    content:new Wrap(
      alignment: WrapAlignment.center,
      children: <Widget>[
        circularProgressBar,
        SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.only(top:8.0),
          child: Text("  $text...", style: GoogleFonts.raleway().copyWith(color: Colors.white),),
        )
      ],
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  return snackBar;

}

String formattedDate(int millis) => DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(millis));
String formatDateWithFormatter(int millis, String format) => DateFormat(format).format(DateTime.fromMillisecondsSinceEpoch(millis));


Widget bindPurchaseListItem(BuildContext context, Item item, int index, bool requireDate){
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  return Slidable(
    startActionPane: ActionPane(motion: ScrollMotion(), children: [
        SlidableAction(
      // caption: 'Remove',
      foregroundColor: Colors.transparent,
      icon: Icons.delete, //Icon(Icons.delete, color: getBlackWhiteColorWithTheme(context) ,),
      onPressed: (context)async {
        var confirm = await showConfirmDialog(context, 'Would you like to delete this item?');
        if(!confirm) return;

        showProgressSnack(context, 'Removing Item');
        itemRef.doc(item.itemId).delete()
            .then((value) async{
          //deduct amount from totals
          hideSnackBar(context); showSnackBar(context, 'Item removed');

          var expenseData = await familyExpenseRef.doc(item.familyId).get();
          if(expenseData.exists){
            familyExpenseRef.doc(item.familyId).update({ key_amount: ((expenseData.get(key_amount)) - item.itemPrice) , 'updatedAt': item.addedOn,
              'remaining': ((expenseData.get('remaining')) - item.itemPrice)  });
          }

        })
            .catchError( (onError) => hideSnackBar(context));

      },
    ),

        SlidableAction(
        // caption: 'Edit',
        foregroundColor: Colors.transparent,
        // color: Colors.green,
        icon:  Icons.edit_outlined, // Icon(Icons.edit_outlined , color: getBlackWhiteColorWithTheme(context),),
        onPressed: (context)async {
          var familyId = await getPrefValue(uid!);
          moveToPage(context, AddItemDialogWidget(familyId: familyId, item: item,));
        },
      ),
      ]),
    child: ListTile(
      leading: numberAvatar(index),
      title: Text(item.itemName!),
      subtitle: loadName(item.addedBy, Theme.of(context).textTheme.bodySmall!),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${getCurrency()} ${item.itemPrice.toString()}', style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w300, fontSize: 22),),
          if(requireDate) Text(formattedDate(item.purchaseDate!), style: Theme.of(context).textTheme.labelSmall,) else SizedBox()
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


Widget getPlaceholderWidget(String text,  {String? svgAsset, double height = 120.0, VoidCallback? onTap, double messageFontSize = 16}){

  String path = "assets/icons";

  if(svgAsset == null)
    svgAsset = "$path/wait.svg";
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
          Center(child: ralewayTextCentered(text, fontSize: messageFontSize,)),
        ],
      ),
      onTap: onTap,
    ),
  );
}

Color randomColor(){
  var colors = [ColorHue.red, ColorHue.blue, ColorHue.green, ColorHue.yellow, ColorHue.purple, ColorHue.orange];
  colors.shuffle();
  // return colors[Random().nextInt(colors.length-1)];
  return RandomColor().randomColor();
}


bool isDarkMode(BuildContext context) => MediaQuery.of(context).platformBrightness == Brightness.dark;

Color getBlackWhiteColorWithTheme(BuildContext context) => isDarkMode(context) ? Colors.white : Colors.black;

Widget delayedWidget(int durationInSeconds, Widget widget){
  return FutureBuilder(future: Future.delayed(Duration(seconds: durationInSeconds),),
      builder: (c,s) => s.connectionState == ConnectionState.done ? widget : circularProgressBar);

}