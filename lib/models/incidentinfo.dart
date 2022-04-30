import 'package:flutter/material.dart';

class IncidentInfo {
  int id;
  String title;
  String description;
  String createdAt;
  String updatedAt;

  IncidentInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncidentInfo.fromJson(Map<String, dynamic> json) {
    int i = 0;
    return IncidentInfo(
      id: json['id'],
      title: (json['title'] as String)
          .split("")
          .map((e) => i++ == 0 ? e.toUpperCase() : e)
          .join(""),
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  List<Widget> format() {
    return [
      RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16),
          children: [
            TextSpan(
              text: "$title - ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: description,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Text(updatedAt, style: const TextStyle(color: Colors.white60)),
      const SizedBox(height: 15),
    ];
  }
}
