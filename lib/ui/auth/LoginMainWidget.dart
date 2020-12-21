import 'package:family_expense/ui/auth/OTPWidget.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginMainWidget extends StatefulWidget {
  @override
  _LoginMainWidgetState createState() => _LoginMainWidgetState();
}

class _LoginMainWidgetState extends State<LoginMainWidget> {

  final TextEditingController _phoneNumController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/icons/login.svg", height: 240,),

                SizedBox(height: 30,),
                Text("Login", style: Theme.of(context).textTheme.headline4),
                SizedBox(height: 30,),

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

                      String validatedText = validateMobile(phone);
                      if(validatedText != null)
                      {
                        Fluttertoast.showToast(msg: validatedText);
                        return;
                      }
                      //Do phone authentication
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => OTPWidget(phone: phone,)
                      ));
                    });
                  },
                ),

              ],
            ),
          )),
    );
  }
}
