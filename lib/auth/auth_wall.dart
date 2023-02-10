import 'package:flutter/material.dart';
import 'package:kitocr/auth/login/login_screen.dart';
import 'package:kitocr/auth/signup/signup_screen.dart';

class AuthWall extends StatefulWidget {
  const AuthWall({Key? key}) : super(key: key);

  @override
  State<AuthWall> createState() => _AuthWallState();
}

class _AuthWallState extends State<AuthWall> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('images/bg-icon.png'), width: 200,),
            SizedBox(height: 24,),
            Text("Welcome to KIT OCR", style: TextStyle(fontSize: 32, color: Colors.black)),
            SizedBox(height: 24,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, elevation: 1),
              child: Text(
                "Login".toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 24,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, elevation: 1),
              child: Text(
                "Sign Up".toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
