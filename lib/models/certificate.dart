// To parse this JSON data, do
//
//     final certificate = certificateFromJson(jsonString);

import 'dart:convert';

Certificate certificateFromJson(String str) => Certificate.fromJson(json.decode(str));

String certificateToJson(Certificate data) => json.encode(data.toJson());

class Certificate {
  Certificate({
    required this.id,
    required this.userId,
    required this.name,
    required this.dept,
    required this.designation,
    required this.ocrText,
    required this.type,
    required this.recipient,
    required this.event,
    required this.host,
    required this.date,
    required this.imgUrl,
    required this.days,
    required this.createdAt,
  });

  String id;
  String userId;
  String name;
  String dept;
  String designation;
  String ocrText;
  String type;
  String recipient;
  String event;
  String host;
  String date;
  String imgUrl;
  String days;
  String createdAt;

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
    id: json["id"],
    userId: json["userId"],
    name: json["name"],
    dept: json["dept"],
    designation: json["designation"],
    ocrText: json["ocrText"],
    type: json["type"],
    recipient: json["recipient"],
    event: json["event"],
    host: json["host"],
    date: json["date"],
    imgUrl: json["imgUrl"],
    days: json["days"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "name": name,
    "dept": dept,
    "designation": designation,
    "ocrText": ocrText,
    "type": type,
    "recipient": recipient,
    "event": event,
    "host": host,
    "date": date,
    "imgUrl": imgUrl,
    "days": days,
    "createdAt": createdAt,
  };
}
