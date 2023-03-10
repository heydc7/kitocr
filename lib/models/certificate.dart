// To parse this JSON data, do
//
//     final certificate = certificateFromJson(jsonString);

import 'dart:convert';

Certificate certificateFromJson(String str) => Certificate.fromJson(json.decode(str));

String certificateToJson(Certificate data) => json.encode(data.toJson());

class Certificate {
  Certificate({
    required this.userId,
    required this.ocrText,
    required this.type,
    required this.recipient,
    required this.event,
    required this.host,
    required this.date,
    required this.imgUrl,
    required this.days,
  });

  String userId;
  String ocrText;
  String type;
  String recipient;
  String event;
  String host;
  String date;
  String imgUrl;
  String days;

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
    userId: json["userId"],
    ocrText: json["ocrText"],
    type: json["type"],
    recipient: json["recipient"],
    event: json["event"],
    host: json["host"],
    date: json["date"],
    imgUrl: json["imgUrl"],
    days: json["days"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "ocrText": ocrText,
    "type": type,
    "recipient": recipient,
    "event": event,
    "host": host,
    "date": date,
    "imgUrl": imgUrl,
    "days": days,
  };
}
