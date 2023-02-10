import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitocr/utils/custom-widgets.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    Key? key,
    required this.image,
    required this.scannedText
  }) : super(key: key);

  final XFile image;
  final List<String> scannedText;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {

  var certificateType = "";
  var recipient = "";
  var hostName = "";
  var date = "";

  final certTypes = ["Participation", "Appreciation", "Achievement", "Excellence", "Award", "Recognition", "Completion", "Other"];

  @override
  void initState() {
    super.initState();
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
                  child: Text("Type of certificate",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                reusableAutocomplete(certTypes, (value) {
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
                reusableAutocomplete(ocrOptions, (value) {
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
                reusableAutocomplete(ocrOptions, (value) {
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
                reusableAutocomplete(ocrOptions, (value) {
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
                reusableAutocomplete(ocrOptions, (value) {
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
}
