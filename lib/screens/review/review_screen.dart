import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitocr/models/certificate.dart';
import 'package:kitocr/utils/custom-widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../home/home_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    Key? key,
    required this.image,
    required this.ocrText,
    required this.scannedText
  }) : super(key: key);

  final XFile image;
  final String ocrText;
  final List<String> scannedText;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {

  var certificateType = "";
  var recipient = "";
  var eventName = "";
  var hostName = "";
  var date = "";

  final certTypes = ["Participation", "Appreciation", "Achievement", "Excellence", "Award", "Recognition", "Completion", "Other"];

  final typeController = TextEditingController();
  final recipientController = TextEditingController();
  final eventController = TextEditingController();
  final hostController = TextEditingController();
  final dateController = TextEditingController();

  final certificatesRef = FirebaseFirestore.instance.collection('certificates');

  @override
  void initState() {
    super.initState();
    analyzeText(widget.ocrText, widget.scannedText);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ocrOptions = widget.scannedText;
    return Scaffold(
      appBar: AppBar(
        title: Text("Review Details"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.file_upload,
              color: Colors.white,
            ),
            onPressed: () {
              saveData();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Scanned Text",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(widget.ocrText),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Type of certificate",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                reusableAutocomplete(certTypes, typeController, (value) {
                  setState(() {
                    certificateType = value;
                  });
                }),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Name of recipient",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                reusableAutocomplete(ocrOptions, recipientController, (value) {
                  setState(() {
                    certificateType = value;
                  });
                }),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Event name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                reusableAutocomplete(ocrOptions, eventController, (value) {
                  setState(() {
                    certificateType = value;
                  });
                }),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Host",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                reusableAutocomplete(ocrOptions, hostController, (value) {
                  setState(() {
                    certificateType = value;
                  });
                }),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Date",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                reusableAutocomplete(ocrOptions, dateController, (value) {
                  setState(() {
                    certificateType = value;
                  });
                }),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Certificate",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.width * 0.8 * 12 / 16,
                  child: Image.file(File(widget.image!.path), fit: BoxFit.fill,),
                )
              ],
            ),
          )
      ),
    );
  }

  void saveData() async {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference refRoot = FirebaseStorage.instance.ref();
    Reference refDir = refRoot.child('images');
    Reference refImgUpload = refDir.child(uniqueFileName);

    try {
      await refImgUpload.putFile(File(widget.image.path));
      var imgUrl = await refImgUpload.getDownloadURL();
      var certificate = Certificate(ocrText: widget.ocrText, type: typeController.text, recipient: recipientController.text, event: eventController.text, host: hostController.text, date: dateController.text, imgUrl: imgUrl);

      await certificatesRef.add(certificate.toJson()).then((value) {
        showSnakbar("Upload successful");
        Navigator.pop(context);
      }).onError((error, stackTrace) {
        showSnakbar("Upload error: ${error.toString()}");
        print("Error creating profile: ${error}");
      });
    } catch(err) {
      showSnakbar("Upload error: ${err.toString()}");
      print("Failed to upload certificate!");
    }
  }

  void analyzeText(String txt, List<String> items) {
    int nameIndex =  items.indexWhere((element) => element.contains('certify that'));
    if(nameIndex != -1) {
      setState(() {
        recipientController.text = items[nameIndex + 1];
      });
    }
    int typeIndex =  items.indexWhere((element) => element.contains('certificate of'));
    if(typeIndex != -1) {
      setState(() {
        typeController.text = items[typeIndex];
      });
    }

    int eventIndex =  items.indexWhere((element) => element.contains('participated'));
    if(eventIndex != -1) {
      setState(() {
        eventController.text = items[eventIndex];
      });
    }

    int hostIndex =  items.indexWhere((element) => element.contains('organized'));
    if(hostIndex != -1) {
      setState(() {
        hostController.text = items[hostIndex];
      });
    }

    int dateIndex =  items.indexWhere((element) => element.contains('from'));
    if(dateIndex != -1) {
      setState(() {
        dateController.text = items[dateIndex + 1];
      });
    }
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
