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
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(certificate: certificate)));
                      },
                      child: ListTile(
                        title: Text(certificate.recipient),
                        subtitle: Text(certificate.host),
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
}
