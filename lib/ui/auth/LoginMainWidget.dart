import 'dart:io';

import 'package:country_codes/country_codes.dart';
import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/ui/auth/OTPWidget.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intl/locale.dart';

class LoginMainWidget extends StatefulWidget {
  @override
  _LoginMainWidgetState createState() => _LoginMainWidgetState();
}

class _LoginMainWidgetState extends State<LoginMainWidget> {

  final TextEditingController _phoneNumController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reloadCurrentUser();

    CountryCodes.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Background(
        child: Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [



                SvgPicture.asset("assets/icons/login.svg", height: 220,),

                SizedBox(height: 20,),
                ralewayText("Login with your Phone", fontSize: 22),
                SizedBox(height: 40,),

                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 10),
                  child: TextField(
                    autofocus: true,
                    style: TextStyle().copyWith(fontSize: 30, fontWeight: FontWeight.w500 ),
                    controller: _phoneNumController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        labelText: "Enter your Phone Number",
                        labelStyle: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 2, fontSize: 28),
                        hintText: "Phone Number",
                        border: InputBorder.none,
                        hintStyle: TextStyle().copyWith(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.grey[400])
                    ),
                  ),
                ),

                SizedBox(height: 50,),

                MaterialButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  color: Colors.grey[200],
                  padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
                  child: Text('Login with Phone',
                    style: TextStyle().copyWith(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500),),
                  onPressed: (){
                    setState(() {
                      String phone = _phoneNumController.text;
                      print("Phone number : "+phone);

                      String? validatedText = validateMobile(phone);
                      if(validatedText != null)
                      {
                        Fluttertoast.showToast(msg: validatedText);
                        return;
                      }
                      String dialCode = CountryCodes.dialCode()??'+91';
                      //Do phone authentication
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => OTPWidget(phone: '$dialCode$phone',)
                      ));
                    });
                  },
                ),

              ],
            )),
      ),
    );
  }
}


class _Background extends StatelessWidget {
  final Widget child;
  const _Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "assets/images/main_top.png",
              width: size.width * 0.35,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              "assets/images/login_bottom.png",
              width: size.width * 0.4,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
