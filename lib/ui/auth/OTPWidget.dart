import 'package:family_expense/data/Firebase.dart';
import 'package:family_expense/data/Pref.dart';
import 'package:family_expense/model/Models.dart';
import 'package:family_expense/ui/auth/JoinFamilyWidget.dart';
import 'package:family_expense/ui/auth/pin_view.dart';
import 'package:family_expense/ui/home/HomeWidget.dart';
import 'package:family_expense/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OTPWidget extends StatefulWidget {


  final String phone;

  OTPWidget({Key key, this.phone}):super(key: key);

  @override
  _OTPWidgetState createState() => _OTPWidgetState();
}

class _OTPWidgetState extends State<OTPWidget> {
  String otp;

  String verificationId;

  @override
  Widget build(BuildContext context) {
    // String phone = ModalRoute.of(context).settings.arguments.toString();
    //send otp
    sendOTP(widget.phone);

    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [


              getPlaceholderWidget('An Otp was sent to ${widget.phone}', svgAsset: 'sms.svg', messageFontSize: 20),

              SizedBox(height: 80,),

              Center(
                child: PinEntryTextField(
                  fields: 6,
                  fontSize: 20.0,
                  fieldWidth: 50.0,
                  showFieldAsBox: true,
                  onSubmit: (String pin){
                    otp = pin;
                  },
                ),
              ),

          SizedBox(height: 80,),

          FlatButton(onPressed:(){
            sendOTP(widget.phone);
          }, child: Text('Resend OTP'),),

              MaterialButton(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                color: Colors.grey[200],
                padding: EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                child: Text("Verify Phone Number",
                  style: TextStyle().copyWith(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w400),),

                onPressed: (){


                  if(verificationId == null){
                    Fluttertoast.showToast(msg: "OTP not sent");
                    return;
                  }

                   verifyOTP(otp, verificationId)
                      .then((userCredential) {
                      //save user data
                     print('Verified OTP , user - ${userCredential.user}');
                     String name = userCredential.user.displayName;
                     if(currentUser!=null)
                     currentUser.reload().then((value) => moveToPage(context, CreateUserWidget(name: name,)));
                     else moveToPage(context, CreateUserWidget(name: name,));
                  }
                  ).catchError((onError)=> Fluttertoast.showToast(msg: onError.toString()));

                },
              ),

            ],
          ),
        ),

      ),
    );
  }

  void sendOTP(String phone)async {
    String testPhone = '+44 7123 123 456';
    // phone = testPhone;
    // phone = "+91$phone";
    Fluttertoast.showToast(msg: "Sending OTP to $phone");

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) {
        // var result = await FirebaseAuth.instance.signInWithCredential(credential);
        //   Fluttertoast.showToast(msg: result.user.toString());

          },

      verificationFailed: (FirebaseAuthException e) {
        print(e);
        Fluttertoast.showToast(msg: "Error : ${e.code}");
      },

      codeSent: (String verificationId, int resendToken) {
        Fluttertoast.showToast(msg: "OTP sent to $phone");
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
        },
    );
  }

    Future<UserCredential> verifyOTP(String otp, String verificationId)async{

        if(verificationId == null)
          return null;

      var phoneAuth = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp);
      return await FirebaseAuth.instance.signInWithCredential(phoneAuth);
    }
}



class CreateUserWidget extends StatelessWidget {

  TextEditingController _nameController = TextEditingController();
  var isInserting = false;
  final String name;
  CreateUserWidget({Key key, this.name}):super(key: key);

  @override
  Widget build(BuildContext context) {

    try{
      _nameController.text = name;
    }
    catch(e){

    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: TextField(
                controller: _nameController,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                style: TextStyle().copyWith(fontSize: 30, fontWeight: FontWeight.w500 ),
                decoration: InputDecoration(
                    labelText: "What is your good name?",
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
              child: Text('Proceed', style: TextStyle().copyWith(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w400),),

              onPressed: ()async{
                if(_nameController.text.isEmpty){
                  showSnackBar(context, "Name cannot be empty");
                      return;
                }

                if(isInserting)
                  return;

                var currentUser = FirebaseAuth.instance.currentUser;
                if(currentUser == null){
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: 'Something went wrong');
                }
                String uid = currentUser.uid;

                print(currentUser);

                UserData user = UserData(uid:uid, name: _nameController.text,
                    phone: currentUser.phoneNumber,
                    createdAt: DateTime.now().millisecondsSinceEpoch, updatedOn: DateTime.now().millisecondsSinceEpoch);

                showProgressSnack(context, 'Updating...');
                FirebaseAuth.instance.currentUser.updateProfile(displayName: _nameController.text)
                    .then((value) {
                  currentUser.reload();

                  userRef.doc(uid).set(user.toJson()).then((value)async {

                    //update to family member
                    familyMemberRef.doc(uid).update({'name' : _nameController.text});

                    //now check if already in a family and verified

                    var isAvailable = await familyMemberRef.doc(uid).get();
                    if(isAvailable.exists){
                      if(isAvailable.get('verified') == true) {
                        //write to pref and then move
                         saveKey(uid, isAvailable.get(key_familyId));
                         hideSnackBar(context);
                         await Future.delayed(Duration(seconds: 3)).then((value) => Navigator.pushAndRemoveUntil(
                             context, MaterialPageRoute(builder: (context) => HomeWidget()), ModalRoute.withName("/")
                         ));

                        return;
                      }
                    }

                    hideSnackBar(context);
                    moveToPage(context, JoinOrCreateFamilyWidget());
                    isInserting = false;
                  });
                });


              },
            ),
          ],
        ),
      ),
    );
  }
}