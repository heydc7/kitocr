import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitocr/auth/reset/reset_screen.dart';
import 'package:kitocr/auth/signup/signup_screen.dart';
import 'package:kitocr/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../screens/home/home_screen.dart';
import '../../utils/custom-widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static String id = 'login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            hexStringToColor("CB2B93"),
            hexStringToColor("9546C4"),
            hexStringToColor("5E61F4")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image(image: AssetImage("assets/images/bg-icon.png"), fit: BoxFit.fitWidth, width: 240, height: 240,),
                SizedBox(height: 16,),
                Text(
                    "Sign In",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 24,),
                reusableTextField("Email Address", Icons.email_outlined, false, _emailTextController),
                SizedBox(height: 24,),
                reusableTextField("Password", Icons.lock_outline, true, _passTextController),
                SizedBox(height: 24,),
                authButton(context, true, () {
                  var email = _emailTextController.text;
                  var pass = _passTextController.text;
                  if(email != '' && pass != '') {
                    FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass).then((value) {
                      showSnakbar("Logged in successfully");
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    }).onError((error, stackTrace) {
                      showSnakbar("Login Error: ${error.toString()}");
                      print("Login Error ${error.toString()}");
                    });
                  } else {
                    showSnakbar("Please fill all required fields");
                  }
                }),
                signupOption(),
                SizedBox(height: 16,),
                forgetPassOption()
              ],
            ).paddingSymmetric(horizontal: 16)
          ),
        ),
      ),
    );
  }

  Row signupOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have account?",
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(width: 8,),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => SignupScreen())
            );
          },
          child: Text("Sign Up",
            style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold
            ),
          ),
        )
      ],
    );
  }

  Row forgetPassOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Forgot your password?",
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(width: 8,),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ResetScreen())
            );
          },
          child: Text("Reset",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold
            ),
          ),
        )
      ],
    );
  }

  void showSnakbar(String msg) {
    var snackBar = SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void hideSnakbar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

