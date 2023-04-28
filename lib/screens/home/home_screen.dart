import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitocr/auth/login/login_screen.dart';
import 'package:kitocr/models/end_user.dart';
import 'package:kitocr/screens/certificates/admin_certificate_screen.dart';
import 'package:kitocr/screens/certificates/certificates_screen.dart';
import 'package:kitocr/screens/reports/reports_screen.dart';
import 'package:kitocr/screens/review/review_screen.dart';
import 'package:kitocr/utils/custom-widgets.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static String id = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool textScanning = false;
  XFile? imageFile;
  List<String> scannedText = [];

  var kitUsr = EndUser(id: "", role: "", name: "", dept: "", designation: "", email: "", mobile: "");
  var collection = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("KIT OCR"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20.0)), //this right here
                      child: Container(
                        height: 250,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Spacer(),
                                  Text(
                                      "User Profile",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Spacer()
                                ],
                              ),
                              SizedBox(height: 8,),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("Name",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(kitUsr.name, style: TextStyle(fontSize: 16),),
                              SizedBox(height: 8,),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("Email",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(kitUsr.email, style: TextStyle(fontSize: 16),),
                              SizedBox(height: 8,),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("User Type",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(kitUsr.role == "0" ? "User" : "Admin", style: TextStyle(fontSize: 16),),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                });
              },
            ),
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: collection.doc(firebaseAuth.currentUser?.uid).get(),
                  builder: (_, snapshot) {
                    if (snapshot.hasError) return Text ('Unable to fetch user info');
                    if (snapshot.hasData) {
                      var data = snapshot.data!.data();
                      kitUsr = EndUser.fromJson(data!);
                      return Text(
                          'Welcome ${kitUsr.name}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                        ),
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
                SizedBox(height: 16,),
                if(textScanning) const CircularProgressIndicator(),
                Image(image: AssetImage("assets/images/bg-icon.png"), fit: BoxFit.fitWidth, width: 240, height: 240,),
                SizedBox(height: 8,),
                reusableButton(context, "Scan Certificate", (){
                  getImage(ImageSource.camera);
                }),
                reusableButton(context, "Pick Image", (){
                  getImage(ImageSource.gallery);
                }),
                reusableButton(context, "View Certificates", (){
                  if(kitUsr.role == "0") {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CertificatesScreen()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AdminCertificateScreen()));
                  }
                }),
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: collection.doc(firebaseAuth.currentUser?.uid).get(),
                  builder: (_, snapshot) {
                    if (snapshot.hasError) return Text ('Unable to fetch user info');
                    if (snapshot.hasData) {
                      var data = snapshot.data!.data();
                      kitUsr = EndUser.fromJson(data!);
                      if(kitUsr.role == "1") {
                        return reusableButton(context, "All Reports", (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ReportsScreen()));
                        });
                      }
                    }
                    return SizedBox(height: 8,);
                  },
                ),
                SizedBox(height: 16,),
                Spacer()
              ],
            ),
          ),
        )
      ),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if(pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {

        });
        getRecognizedText(pickedImage);
      }
    } catch(err) {
      textScanning = false;
      imageFile = null;
      scannedText = [];
    }
  }

  void getRecognizedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = [];
    var ocrText = "";
    for(TextBlock block in recognizedText.blocks) {
      for(TextLine line in block.lines) {
        ocrText += line.text + " ";
        scannedText.add(line.text);
      }
    }
    print("OCR: $ocrText");
    textScanning = false;
    setState(() {

    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewScreen(image: image, ocrText: ocrText, scannedText: scannedText, kitUsr: kitUsr)));
  }

}


