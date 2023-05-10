import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitocr/models/FilterModel.dart';
import 'package:kitocr/models/certificate.dart';
import 'package:kitocr/screens/Details/detail_screen.dart';
import 'package:amazon_like_filter/amazon_like_filter.dart';
import 'package:path_provider/path_provider.dart';

class AdminCertificateScreen extends StatefulWidget {
  const AdminCertificateScreen({Key? key}) : super(key: key);

  @override
  State<AdminCertificateScreen> createState() => _AdminCertificateScreenState();
}

class _AdminCertificateScreenState extends State<AdminCertificateScreen> {

  var collection = FirebaseFirestore.instance.collection('certificates');

  List<FilterItemModel> users = [];
  List<FilterItemModel> depts = [];
  List<FilterItemModel> desgn = [];

  List<String> applied = [];

  List<Certificate> allCertificates = [];
  List<Certificate> certificates = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFunc();
  }

  void initFunc() {
    collection.get().then((value) {
      setState(() {
        certificates = value.docs.map((doc) => Certificate.fromJson(doc.data())).toList();
        allCertificates = certificates;
        for(var c in certificates) {
          var userModel = FilterItemModel(filterTitle: c.name, filterKey: c.name);
          var deptModel = FilterItemModel(filterTitle: c.dept, filterKey: c.dept);
          var desgModel = FilterItemModel(filterTitle: c.designation, filterKey: c.designation);
          if(!users.contains(userModel)) {
            users.add(userModel);
          }
          if(!depts.contains(deptModel)) {
            depts.add(deptModel);
          }
          if(!desgn.contains(desgModel)) {
            desgn.add(desgModel);
          }
        }
      });
      print(certificates.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Scanned Certificates"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.file_open_outlined),
              onPressed: (){
                showCustomAlertDialog(context);
              },
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(16),
          child: ListView.builder(
              itemCount: certificates.length,
              itemBuilder: (context, index){
                var certificate = certificates[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(certificate: certificate)));
                    },
                    onLongPress: () {
                      showDeleteAlertDialog(context, certificate);
                    },
                    title: Text(certificate.recipient),
                    leading: Image.network(certificate.imgUrl),
                  ),
                );
              }
          )
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.filter_alt),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext bc) {
                  return FilterWidget(
                      filterProps: FilterProps(
                          onFilterChange: (value) {
                            setState(() {
                              var temp = value.map((e) => e.toMap());
                              print(temp);
                              if(temp.isEmpty) {
                                certificates = allCertificates;
                              } else {
                                List<String> u = [];
                                List<String> d = [];
                                List<String> s = [];
                                var t = "";
                                for(var x in temp) {
                                  var m = FilterModel.fromJson(x);
                                  switch(m.filterKey) {
                                    case 'users':
                                      for(var p in m.appliedFilter) {
                                        u.add(p.filterTitle);
                                      }
                                      break;
                                    case 'dept':
                                      for(var p in m.appliedFilter) {
                                        d.add(p.filterTitle);
                                      }
                                      break;
                                    case 'desg':
                                      for(var p in m.appliedFilter) {
                                        s.add(p.filterTitle);
                                      }
                                      break;
                                    case 'time':
                                      if(m.appliedFilter.length != 0) {
                                        t = m.appliedFilter.first.filterKey;
                                      }
                                      break;
                                  }
                                }
                                runFilter(u, d, s, t);
                              }
                              //applied = value;
                            });
                            //print('Applied filer - $applied');
                          },
                          filters: [
                            FilterListModel(
                              filterOptions: users,
                              previousApplied: [],
                              title: 'Users',
                              filterKey: 'users',
                            ),
                            FilterListModel(
                              filterOptions: depts,
                              previousApplied: [],
                              title: 'Department',
                              filterKey: 'dept',
                            ),
                            FilterListModel(
                              filterOptions: desgn,
                              previousApplied: [],
                              title: 'Designation',
                              filterKey: 'desg',
                            ),
                            FilterListModel(
                              filterOptions: [
                                FilterItemModel(filterTitle: "1 Month", filterKey: "1M"),
                                FilterItemModel(filterTitle: "3 Months", filterKey: "6M"),
                                FilterItemModel(filterTitle: "6 Months", filterKey: "9M"),
                                FilterItemModel(filterTitle: "12 Months", filterKey: "12M")
                              ],
                              previousApplied: [],
                              title: 'Timestamp',
                              filterKey: 'time',
                            ),
                          ]
                      )
                  );
                }
            );
          },
        ),
      ),
    );
  }

  void deleteDoc(Certificate cert) async {
    await FirebaseFirestore.instance.collection('certificates').doc(cert.id).delete().then((value) {
      print("Document Deleted");
      initFunc();
    });
  }

  void generateReport() async {
    if(certificates.length != 0) {
      List<List<String>> certData = [["Recipient", "Event", "Host", "Type", "Date", "Duration", "CreatedBy", "Department", "Designation", "CreatedAt","Image"]];
      for(var c in certificates) {
        List<String> detail = [];
        detail.add(c.recipient);
        detail.add(c.event);
        detail.add(c.host);
        detail.add(c.type);
        detail.add(c.date);
        detail.add(c.days);
        detail.add(c.name);
        detail.add(c.dept);
        detail.add(c.designation);
        final cDate = DateTime.parse(c.createdAt);
        detail.add("${cDate.day}-${cDate.month}-${cDate.year}");
        detail.add(c.imgUrl);
        certData.add(detail);
      }
      String csvData = ListToCsvConverter().convert(certData);
      String fileName = "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}-${DateTime.now().hour}-${DateTime.now().minute}.csv";
      final String directory = (await getApplicationSupportDirectory()).path;
      final path = "$directory/$fileName";
      final File file = File(path);
      await file.writeAsString(csvData);
      Reference refRoot = FirebaseStorage.instance.ref();
      Reference refDir = refRoot.child('reports');
      Reference refFileUpload = refDir.child(fileName);
      try {
        await refFileUpload.putFile(file).then((value) {
          showSnakbar("Report generated & Saved to the storage");
        });
      } catch(err) {
        showSnakbar("Upload error: ${err.toString()}");
        print("Failed to upload report!");
      }
    } else {
      // Show Alert
    }
  }

  void runFilter(List<String> names, List<String> departments, List<String> designations, String timestamp) {
    List<Certificate> results = [];
    results = certificates.where((cert) {
      for(var name in names) {
        if(cert.name == name) {
          return true;
        }
      }
      for(var dept in departments) {
        if(cert.dept == dept) {
          return true;
        }
      }
      for(var desg in designations) {
        if(cert.designation == desg) {
          return true;
        }
      }

      final certDate = DateTime.parse(cert.createdAt);
      var now = DateTime.now();
      var m1 = DateTime(now.year, now.month-1, now.day);
      var m3 = DateTime(now.year, now.month-3, now.day);
      var m6 = DateTime(now.year, now.month-6, now.day);
      var m12 = DateTime(now.year-1, now.month, now.day);

      switch(timestamp) {
        case "1M":
          if(certDate.isAfter(m1)) {
            return true;
          }
          break;
        case "3M":
          if(certDate.isAfter(m3)) {
            return true;
          }
          break;
        case "6M":
          if(certDate.isAfter(m6)) {
            return true;
          }
          break;
        case "12M":
          if(certDate.isAfter(m12)) {
            return true;
          }
          break;
      }

      return false;
    }).toList();

    setState(() {
      certificates = results;
    });
  }

  void showDeleteAlertDialog(BuildContext context, Certificate cert) {

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
        deleteDoc(cert);
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

  void showCustomAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed:  () {
        Navigator.of(context).pop();
        generateReport();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Generate Report"),
      content: Text("Would you like to create a report for the ${certificates.length} certificates?"),
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
