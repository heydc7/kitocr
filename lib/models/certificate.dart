// To parse this JSON data, do
//
//     final certificate = certificateFromJson(jsonString);

import 'dart:convert';

Certificate certificateFromJson(String str) => Certificate.fromJson(json.decode(str));

String certificateToJson(Certificate data) => json.encode(data.toJson());

class Certificate {
  Certificate({
    required this.ocrText,
    required this.type,
    required this.recipient,
    required this.event,
    required this.host,
    required this.date,
    required this.imgUrl,
  });

  String ocrText;
  String type;
  String recipient;
  String event;
  String host;
  String date;
  String imgUrl;

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
    ocrText: json["ocrText"],
    type: json["type"],
    recipient: json["recipient"],
    event: json["event"],
    host: json["host"],
    date: json["date"],
    imgUrl: json["imgUrl"],
  );

  Map<String, dynamic> toJson() => {
    "ocrText": ocrText,
    "type": type,
    "recipient": recipient,
    "event": event,
    "host": host,
    "date": date,
    "imgUrl": imgUrl,
  };
}
