// To parse this JSON data, do
//
//     final endUser = endUserFromJson(jsonString);

import 'dart:convert';

EndUser endUserFromJson(String str) => EndUser.fromJson(json.decode(str));

String endUserToJson(EndUser data) => json.encode(data.toJson());

class EndUser {
  EndUser({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
  });

  String id;
  String name;
  String email;
  String mobile;

  factory EndUser.fromJson(Map<String, dynamic> json) => EndUser(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
  };
}

