import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/custom-widgets.dart';
import '../../utils/utils.dart';

class ResetScreen extends StatefulWidget {
  const ResetScreen({Key? key}) : super(key: key);

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {

  TextEditingController _emailTextController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("CB2B93"),
        elevation: 0,
        title: Text("Reset Password",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
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
                  SizedBox(height: 16,),
                  Text(
                    "Forgot your password?",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 24,),
                  reusableTextField("Email Address", Icons.email_outlined, false, _emailTextController),
                  SizedBox(height: 24,),
                  if(isLoading) CircularProgressIndicator(),
                  if(!isLoading)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 50,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        if(_emailTextController.text != '') {
                          await _firebaseAuth.sendPasswordResetEmail(email: _emailTextController.text).then((value) {
                            print("Reset Successful");
                            setState(() {
                              isLoading = false;
                            });
                            showSnakbar("Reset Successful, Check Email Instructions");
                            Navigator.pop(context);
                          }).onError((error, stackTrace) {
                              print(error);
                              showSnakbar("Error: $error");
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pop(context);
                          });
                        }

                      },
                      child: Text(
                        "Reset Password",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16
                        ),
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if(states.contains(MaterialState.pressed)) {
                              return Colors.white24;
                            }
                            return Colors.white;
                          }),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                          )
                      ),
                    ),
                  ),
                  SizedBox(height: 24,),
                ],
              ).paddingSymmetric(horizontal: 16)
          ),
        ),
      ),
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
