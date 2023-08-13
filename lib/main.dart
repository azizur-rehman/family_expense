import 'package:avatar_glow/avatar_glow.dart';
import 'package:family_expense/ui/auth/JoinFamilyWidget.dart';
import 'package:family_expense/ui/auth/LoginMainWidget.dart';
import 'package:family_expense/ui/auth/OTPWidget.dart';
import 'package:family_expense/ui/home/HomeWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/auth/delayed_animation.dart';
import 'data/Pref.dart';

Future<void> main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIOverlays([]);

  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(secondary: Colors.lightBlueAccent,),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: TextStyle(color:Colors.lightBlueAccent,)
          )
        )
      ),
      theme: ThemeData.light().copyWith(colorScheme: ColorScheme.dark(secondary: Colors.lightBlueAccent),
          brightness: Brightness.light,
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  textStyle: TextStyle(color:Colors.lightBlueAccent )
              )
          )),
      // ui.home: LandingPage()
      home: LandingPage(),
    );
  }
}


class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

          print('Current User ${currentUser}');

    return currentUser == null ? LoginLandingPageWidget() : HomeWidget();

    //  return StreamBuilder<User>(
    //     stream: FirebaseAuth.instance.authStateChanges(),
    //     builder: (context, user)  {
    //       print('Current User ${user.data}');
    //       if(user.data != null){
    //         return HomeWidget();
    //       }
    //
    //       return LoginLandingPageWidget();
    //     }
    // );
  }
}


class LoginLandingPageWidget extends StatefulWidget {
  @override
  _LoginLandingPageWidgetState createState() => _LoginLandingPageWidgetState();
}

class _LoginLandingPageWidgetState extends State<LoginLandingPageWidget> with SingleTickerProviderStateMixin {
  final int delayedAmount = 100;
  late double _scale;
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.white;
    _scale = 1 - _controller.value;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.blue,
          body: SafeArea(
            child: Center(
              child: Column(
                children: <Widget>[
                  AvatarGlow(
                    endRadius: 90,
                    duration: Duration(seconds: 2),
                    glowColor: Colors.white24,
                    repeat: true,
                    repeatPauseDuration: Duration(seconds: 2),
                    startDelay: Duration(seconds: 1),
                    child: Material(
                        elevation: 8.0,
                        shape: CircleBorder(),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          child: FlutterLogo(
                            size: 50.0,
                          ),
                          radius: 50.0,
                        )),
                  ),
                  DelayedAnimation(
                    child: Text(
                      "Hi There",
                      style: TextStyle(
                          fontSize: 35.0,
                          color: color),
                    ),
                    delay: delayedAmount + 1000,
                  ),
                  DelayedAnimation(
                    child: Text(
                      "I'm Fex",
                      style: TextStyle(
                          fontSize: 35.0,
                          color: color),
                    ),
                    delay: delayedAmount + 2000,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  DelayedAnimation(
                    child: Text(
                      "Your New Personal",
                      style: TextStyle(fontSize: 20.0, color: color),
                    ),
                    delay: delayedAmount + 3000,
                  ),
                  DelayedAnimation(
                    child: Text(
                      "Family Expense Helper",
                      style: TextStyle(fontSize: 20.0, color: color),
                    ),
                    delay: delayedAmount + 3000,
                  ),
                  SizedBox(
                    height: 100.0,
                  ),
                  DelayedAnimation(
                    child: GestureDetector(
                      onTapDown: _onTapDown,
                      onTapUp: _onTapUp,
                      child: Transform.scale(
                        scale: _scale,
                        child: _animatedButtonUI,
                      ),
                    ),
                    delay: delayedAmount + 4000,
                  ),
                  SizedBox(height: 50.0,),
                ],
              ),
            ),
          )
      ),
    );
  }

  Widget get _animatedButtonUI => Container(
    height: 60,
    width: 270,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(100.0),
      color: Colors.white,
    ),
    child: Center(
      child: Text(
        'Get Started',
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.blue,
        ),
      ),
    ),
  );

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();

    //save pref file

    // saveKey(key_user, "some text");

    // Navigatpushor.push(context, MaterialPageRoute(
    //   builder: (context) => LoginMainWidget(),
    // ));
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => LoginMainWidget()),
        ModalRoute.withName("/LandingPageWidget")
    );
  }
}


class LoggedInIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("You are already logged In"),
      ),
    );
  }
}
