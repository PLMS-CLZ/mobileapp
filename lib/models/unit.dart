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
}
