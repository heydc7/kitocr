// To parse this JSON data, do
//
//     final endUser = endUserFromJson(jsonString);

import 'dart:convert';

EndUser endUserFromJson(String str) => EndUser.fromJson(json.decode(str));

String endUserToJson(EndUser data) => json.encode(data.toJson());

class EndUser {
  EndUser({
    required this.id,
    required this.role,
    required this.name,
    required this.dept,
    required this.designation,
    required this.email,
    required this.mobile,
  });

  String id;
  String role;
  String name;
  String dept;
  String designation;
  String email;
  String mobile;

  factory EndUser.fromJson(Map<String, dynamic> json) => EndUser(
    id: json["id"],
    role: json["role"],
    name: json["name"],
    dept: json["dept"],
    designation: json["designation"],
    email: json["email"],
    mobile: json["mobile"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "role": role,
    "name": name,
    "dept": dept,
    "designation": designation,
    "email": email,
    "mobile": mobile,
  };
}
