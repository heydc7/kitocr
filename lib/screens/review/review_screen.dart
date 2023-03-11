import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitocr/models/certificate.dart';
import 'package:kitocr/utils/custom-widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simple_autocomplete_formfield/simple_autocomplete_formfield.dart';
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
  var days = "";

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
                Text(widget.ocrText),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Type of certificate",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                  initialValue: certificateType,
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
                  onChanged: (value) => setState(() => certificateType = value!),
                  onSaved: (value) => setState(() => certificateType = value!)
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Name of recipient",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                    initialValue: recipient,
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
                    onChanged: (value) => setState(() => recipient = value!),
                    onSaved: (value) => setState(() => recipient = value!)
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Event name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                    initialValue: eventName,
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
                    onChanged: (value) => setState(() => eventName = value!),
                    onSaved: (value) => setState(() => eventName = value!)
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Host",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                    initialValue: hostName,
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
                    onChanged: (value) => setState(() => hostName = value!),
                    onSaved: (value) => setState(() => hostName = value!)
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Date",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                    initialValue: date,
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
                    onChanged: (value) => setState(() => date = value!),
                    onSaved: (value) => setState(() => date = value!)
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text("Duration",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SimpleAutocompleteFormField<String>(
                    initialValue: days,
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
                    onChanged: (value) => setState(() => days = value!),
                    onSaved: (value) => setState(() => days = value!)
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
      var certificate = Certificate(userId: uId ?? "unknown", ocrText: widget.ocrText, type: certificateType, recipient: recipient, event: eventName, host: hostName, date: date, imgUrl: imgUrl, days: days);

      await certificatesRef.add(certificate.toJson()).then((value) {
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
          recipient = ocrTxt.substring(startIndex + l, endIndex);
          break;
        case 2:
          eventName = ocrTxt.substring(startIndex + l, endIndex);
          break;
        case 3:
          hostName = ocrTxt.substring(startIndex + l, endIndex);
          break;
        case 4:
          date = ocrTxt.substring(startIndex + l, endIndex);
          break;
        default:
          print("Last Index");
      }
    }

    var items = ocrTxt.toLowerCase().split(' ');
    if(items.contains('days')) {
      var d = items[items.indexOf('days') - 1];
      days = d + ' Days';
    } else if(items.contains('week')) {
      var w = items[items.indexOf('week') - 1];
      days = w + ' Week';
    } else if(items.contains('months')) {
      var m = items[items.indexOf('months') - 1];
      days = m + ' Months';
    }

    print("Items: $items");
    if(ocrTxt.toLowerCase().contains('certificate of')) {
      var c = items[items.indexOf('certificate') + 2];
      certificateType = c.capitalizeFirstLetter();
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
