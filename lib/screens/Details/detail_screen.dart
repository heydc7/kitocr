import 'package:flutter/material.dart';
import 'package:kitocr/models/certificate.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    Key? key,
    required this.certificate
  }) : super(key: key);

  final Certificate certificate;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Details"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16,),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.width * 0.8 * 12 / 16,
                  child: Image.network(widget.certificate.imgUrl, fit: BoxFit.fill,),
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Recipient Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(widget.certificate.recipient),
                SizedBox(height: 8,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Event Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(widget.certificate.event),
                SizedBox(height: 8,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Host",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(widget.certificate.host),
                SizedBox(height: 8,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Type",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(widget.certificate.type),
                SizedBox(height: 8,),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Date",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(widget.certificate.date),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
