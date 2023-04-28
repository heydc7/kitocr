import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitocr/models/certificate.dart';
import 'package:kitocr/models/end_user.dart';
import 'package:kitocr/utils/custom-widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simple_autocomplete_formfield/simple_autocomplete_formfield.dart';
import '../home/home_screen.dart';
import 'package:uuid/uuid.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    Key? key,
    required this.image,
    required this.ocrText,
    required this.scannedText,
    required this.kitUsr
  }) : super(key: key);

  final XFile image;
  final String ocrText;
  final List<String> scannedText;
  final EndUser kitUsr;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {

  TextEditingController certificateTypeTextController = TextEditingController();
  TextEditingController recipientTextController = TextEditingController();
  TextEditingController eventNameTextController = TextEditingController();
  TextEditingController hostNameTextController = TextEditingController();
  TextEditingController dateTextController = TextEditingController();
  TextEditingController daysTextController = TextEditingController();


  final certTypes = ["Participation", "Appreciation", "Achievement", "Excellence", "Award", "Recognition", "Completion", "Other"];

  final certificatesRef = FirebaseFirestore.instance.collection('certificates');
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // NAME
  final group1 = ["certify that"];
  // EVENT NAME
  final group2 = ["has participated in", "has organized"];
  // HOST NAME
  final group3 = ["organized by"];
  // DATE
  final group4 = ["from"];

  var isLoading = false;

  @override
  void initState() {
    super.initState();
    analyzeText(widget.ocrText, widget.scannedText);
    print(widget.scannedText);
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
                SelectableText(widget.ocrText),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Type of certificate",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                  controller: certificateTypeTextController,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  itemBuilder: (context, item) => Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text(item!),
                  ),
                  maxSuggestions: 20,
                  suggestionsHeight: 250,
                  onSearch: (String search) async => search.isEmpty ? certTypes : certTypes.where((txt) => txt.toLowerCase().contains(search.toLowerCase())).toList(),
                  itemFromString: (string) => certTypes.singleWhere((txt) => txt == string.toLowerCase(), orElse: () => ''),
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Name of recipient",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                    controller: recipientTextController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    itemBuilder: (context, item) => Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(item!),
                    ),
                    maxSuggestions: 20,
                    suggestionsHeight: 300,
                    onSearch: (String search) async => search.isEmpty ? widget.scannedText : widget.scannedText.where((txt) => txt.toLowerCase().contains(search.toLowerCase())).toList(),
                    itemFromString: (string) => widget.scannedText.singleWhere((txt) => txt == string.toLowerCase(), orElse: () => ''),
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Event name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                    controller: eventNameTextController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    itemBuilder: (context, item) => Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(item!),
                    ),
                    maxSuggestions: 30,
                    suggestionsHeight: 300,
                    onSearch: (String search) async => search.isEmpty ? widget.scannedText : widget.scannedText.where((txt) => txt.toLowerCase().contains(search.toLowerCase())).toList(),
                    itemFromString: (string) => widget.scannedText.singleWhere((txt) => txt == string.toLowerCase(), orElse: () => ''),
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Host",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                    controller: hostNameTextController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    itemBuilder: (context, item) => Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(item!),
                    ),
                    maxSuggestions: 30,
                    suggestionsHeight: 300,
                    onSearch: (String search) async => search.isEmpty ? widget.scannedText : widget.scannedText.where((txt) => txt.toLowerCase().contains(search.toLowerCase())).toList(),
                    itemFromString: (string) => widget.scannedText.singleWhere((txt) => txt == string.toLowerCase(), orElse: () => ''),
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Date",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                    controller: dateTextController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    itemBuilder: (context, item) => Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(item!),
                    ),
                    maxSuggestions: 30,
                    suggestionsHeight: 300,
                    onSearch: (String search) async => search.isEmpty ? widget.scannedText : widget.scannedText.where((txt) => txt.toLowerCase().contains(search.toLowerCase())).toList(),
                    itemFromString: (string) => widget.scannedText.singleWhere((txt) => txt == string.toLowerCase(), orElse: () => ''),
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Duration",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                    controller: daysTextController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    itemBuilder: (context, item) => Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(item!),
                    ),
                    maxSuggestions: 30,
                    suggestionsHeight: 300,
                    onSearch: (String search) async => search.isEmpty ? widget.scannedText : widget.scannedText.where((txt) => txt.toLowerCase().contains(search.toLowerCase())).toList(),
                    itemFromString: (string) => widget.scannedText.singleWhere((txt) => txt == string.toLowerCase(), orElse: () => ''),
                ),
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
    buildShowDialog(context);
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference refRoot = FirebaseStorage.instance.ref();
    Reference refDir = refRoot.child('images');
    Reference refImgUpload = refDir.child(uniqueFileName);
    final uId = firebaseAuth.currentUser?.uid;

    try {
      await refImgUpload.putFile(File(widget.image.path));
      var imgUrl = await refImgUpload.getDownloadURL();
      var cId = Uuid().v4().replaceAll('-', '');
      var certificate = Certificate(id: cId, userId: uId ?? "unknown", name: widget.kitUsr.name, dept: widget.kitUsr.dept, designation: widget.kitUsr.designation, ocrText: widget.ocrText, type: certificateTypeTextController.text, recipient: recipientTextController.text, event: eventNameTextController.text, host: hostNameTextController.text, date: dateTextController.text, imgUrl: imgUrl, days: daysTextController.text, createdAt: DateTime.now().toString());



      await certificatesRef.doc(cId).set(certificate.toJson()).then((value) {
        showSnakbar("Upload successful");
        Navigator.pop(context);
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

    final ocrTxt = widget.ocrText;
    var indexes = [];

    for(final keyword in group1) {
      if(ocrTxt.toLowerCase().contains(keyword.toLowerCase())) {
        indexes.add("${ocrTxt.toLowerCase().indexOf(keyword)}:${keyword.length}:1");
        break;
      }
    };
    for(final keyword in group2) {
      if(ocrTxt.toLowerCase().contains(keyword.toLowerCase())) {
        indexes.add("${ocrTxt.toLowerCase().indexOf(keyword)}:${keyword.length}:2");
        break;
      }
    };
    for(final keyword in group3) {
      if(ocrTxt.toLowerCase().contains(keyword.toLowerCase())) {
        indexes.add("${ocrTxt.toLowerCase().indexOf(keyword)}:${keyword.length}:3");
        break;
      }
    };
    for(final keyword in group4) {
      if(ocrTxt.toLowerCase().contains(keyword.toLowerCase())) {
        indexes.add("${ocrTxt.toLowerCase().indexOf(keyword)}:${keyword.length}:4");
        break;
      }
    };
    indexes.add("${ocrTxt.length}:0:-1");
    indexes.sort((a,b) {
      var s1 = int.parse(a.split(':')[0]);
      var s2 = int.parse(b.split(':')[0]);
      return s1.compareTo(s2);
    });
    print("Indexes: " + indexes.toString());

    for(var i=0; i < indexes.length - 1; i++) {
      var p1 = indexes[i].split(':');
      var g = int.parse(p1[2]);
      var p2 = indexes[i + 1].split(':');
      var l = int.parse(p1[1]);
      final startIndex = int.parse(p1[0]);
      final endIndex = int.parse(p2[0]);
      print("$g : ${ocrTxt.substring(startIndex + l, endIndex)}");
      switch(g){
        case 1:
          recipientTextController.text = ocrTxt.substring(startIndex + l, endIndex);
          break;
        case 2:
          eventNameTextController.text = ocrTxt.substring(startIndex + l, endIndex);
          break;
        case 3:
          hostNameTextController.text = ocrTxt.substring(startIndex + l, endIndex);
          break;
        case 4:
          dateTextController.text = ocrTxt.substring(startIndex + l, endIndex);
          break;
        default:
          print("Last Index");
      }
    }

    var items = ocrTxt.toLowerCase().split(' ');
    if(items.contains('days')) {
      var d = items[items.indexOf('days') - 1];
      daysTextController.text = d + ' Days';
    } else if(items.contains('week')) {
      var w = items[items.indexOf('week') - 1];
      daysTextController.text = w + ' Week';
    } else if(items.contains('months')) {
      var m = items[items.indexOf('months') - 1];
      daysTextController.text = m + ' Months';
    }

    print("Items: $items");
    if(ocrTxt.toLowerCase().contains('certificate of')) {
      var c = items[items.indexOf('certificate') + 2];
      certificateTypeTextController.text = c.capitalizeFirstLetter();
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

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
