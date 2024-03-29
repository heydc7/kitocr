import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitocr/models/certificate.dart';
import 'package:kitocr/screens/Details/detail_screen.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({Key? key}) : super(key: key);

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Scanned Certificates"),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.all(16),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('certificates').where('userId', isEqualTo: firebaseAuth.currentUser?.uid).snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                List<Map>? items = snapshot.data?.docs.map((e) => e.data() as Map).toList();

                return ListView.builder(
                  itemCount: items?.length,
                  itemBuilder: (context, index){
                    var certificate = Certificate.fromJson(items![index] as Map<String, dynamic>);
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
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          ),
        ),
      ),
    );
  }

  void deleteDoc(Certificate cert) async {
    await FirebaseFirestore.instance.collection('certificates').doc(cert.id).delete().then((value) {
      print("Document Deleted");
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
}
