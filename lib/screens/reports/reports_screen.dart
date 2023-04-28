import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kitocr/models/firebase_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:core';
import 'package:open_file/open_file.dart';


class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {

  List<FirebaseFile> allFiles = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFunc();
  }
  
  void initFunc() {
    listAllReports().then((value) {
      setState(() {
        allFiles = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports"),
      ),
      body: Container(
        margin: EdgeInsets.all(16),
        child: ListView.builder(
            itemCount: allFiles.length,
            itemBuilder: (context, index){
              var file = allFiles[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  onTap: () {
                    downloadFile(file);
                  },
                  onLongPress: () {
                    showCustomAlertDialog(context, file);
                  },
                  title: Text(
                    file.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  leading: Icon(Icons.insert_drive_file, size: 32, color: Colors.deepPurpleAccent,),
                ),
              );
            }
        )
      ),
    );
  }

  Future<List<String>> getDownloadLinks(List<Reference> refs) => Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  Future<List<FirebaseFile>> listAllReports() async {
    final ref = FirebaseStorage.instance.ref('reports/');
    final result = await ref.listAll();

    final urls = await getDownloadLinks(result.items);

    return urls
        .asMap()
        .map((index, url) {
          final ref = result.items[index];
          final name = ref.name;
          final file = FirebaseFile(ref: ref, name: name, url: url);

          return MapEntry(index, file);
    }).values.toList();
  }

  Future downloadFile(FirebaseFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = File("${dir.path}/${file.name}");
    await file.ref.writeToFile(path);

    await OpenFile.open(path.path);
  }

  void deleteFile(FirebaseFile file) async {
    final ref = FirebaseStorage.instance.ref('reports/${file.name}');
    await ref.delete().then((value) => initFunc());
  }

  void showCustomAlertDialog(BuildContext context, FirebaseFile file) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Delete", style: TextStyle(color: Colors.red),),
      onPressed:  () {
        Navigator.of(context).pop();
        deleteFile(file);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Report"),
      content: Text("Are you sure to delete this report permanently?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
