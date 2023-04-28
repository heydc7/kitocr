
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitocr/models/end_user.dart';
import 'package:kitocr/models/end_user.dart';
import 'package:kitocr/screens/home/home_screen.dart';

import '../../utils/custom-widgets.dart';
import '../../utils/utils.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _deptTextController = TextEditingController();
  TextEditingController _designationTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _mobileTextController = TextEditingController();
  TextEditingController _passTextController = TextEditingController();

  final usersRef = FirebaseFirestore.instance.collection('users');

  final departments = ["Computer Science & Engineering", "Biotech", "Civil", "Environment"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: [
                SizedBox(height: 24,),
                reusableTextField("Full Name", Icons.person_outline, false, _nameTextController),
                SizedBox(height: 24,),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.groups_outlined,
                      color: Colors.white70,
                    ),
                    labelText: "Department",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(width: 0, style: BorderStyle.none)
                    ),
                  ),
                    items: departments.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _deptTextController.text = value!;
                      });
                }),
                SizedBox(height: 24,),
                reusableTextField("Designation", Icons.leaderboard, false, _designationTextController),
                SizedBox(height: 24,),
                reusableTextField("Email Address", Icons.email_outlined, false, _emailTextController),
                SizedBox(height: 24,),
                reusableTextField("Mobile Number", Icons.phone, false, _mobileTextController),
                SizedBox(height: 24,),
                reusableTextField("Enter Password", Icons.lock_outline, true, _passTextController),
                SizedBox(height: 24,),
                authButton(context, false, () {
                  var name = _nameTextController.text;
                  var email = _emailTextController.text;
                  var dept = _deptTextController.text;
                  var desg = _designationTextController.text;
                  var num = _mobileTextController.text;
                  var pass = _passTextController.text;
                  if(email != '' && pass != '' && name != '' && dept != '' && desg != '' && num != '') {
                    FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass).then((value) {
                      var uid = value.user?.uid;
                      createUser(id: uid ?? num, name: name, dept: dept, designation: desg, email: email, mobile: num);
                    }).onError((error, stackTrace) {
                      print("Signup Error ${error.toString()}");
                    });
                  } else {
                    showSnakbar("Please fill all fields");
                  }
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future createUser({required String id, required String name, required String dept, required String designation, required String email, required String mobile}) async {
    final user = EndUser(id: id, role:"0", dept: dept, designation: designation, name: name, email: email, mobile: mobile);
    await usersRef.doc(id).set(user.toJson()).then((value) {
      showSnakbar("Signup successful, Welcome!");
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }).onError((error, stackTrace) {
      showSnakbar("Create User error: ${error.toString()}");
      print("Error creating profile: ${error}");
    });
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
