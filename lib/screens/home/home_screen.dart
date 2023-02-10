import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitocr/auth/login/login_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("KIT OCR"),
          centerTitle: true,
          automaticallyImplyLeading: false,
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
            )
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
                if(textScanning) const CircularProgressIndicator(),
                if(!textScanning && imageFile == null)
                  Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey,
                  ),
                if(imageFile != null)
                  Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.8 * 12 / 16,
                      child: Image.file(File(imageFile!.path), width: 300, height: 300, fit: BoxFit.fill,),
                  ),
                SizedBox(height: 24,),
                reusableButton(context, "Scan Certificate", (){
                  getImage(ImageSource.camera);
                }),
                SizedBox(height: 8,),
                reusableButton(context, "Pick Image", (){
                  getImage(ImageSource.gallery);
                }),
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
    for(TextBlock block in recognizedText.blocks) {
      for(TextLine line in block.lines) {
        scannedText.add(line.text);
      }
    }
    textScanning = false;
    setState(() {

    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewScreen(image: image, scannedText: scannedText)));
  }


}


