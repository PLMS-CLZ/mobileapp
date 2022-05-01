import 'package:flutter/material.dart';

class Unit {
  int id;
  String status;
  double latitude;
  double longitude;
  String phoneNumber;
  String createdAt;
  String updatedAt;
  String formattedAddress;

  Unit({
    required this.id,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedAddress,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      status: json['status'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      phoneNumber: json['phone_number'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      formattedAddress: json['formatted_address'],
    );
  }

  List<Widget> format() {
    int i = 0;

    return [
      const Divider(thickness: 2),
      RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14),
          children: [
            const TextSpan(
              text: "Status: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: status
                  .split("")
                  .map((e) => i++ == 0 ? e.toUpperCase() : e)
                  .join(""),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
      const SizedBox(height: 5),
      RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14),
          children: [
            const TextSpan(
              text: "Address: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: formattedAddress,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
      const SizedBox(height: 5),
      RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14),
          children: [
            const TextSpan(
              text: "Last Updated: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: updatedAt,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
      const SizedBox(height: 15),
    ];
  }
}
