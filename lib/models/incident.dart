import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plms_clz/models/incidentinfo.dart';
import 'package:plms_clz/models/location.dart';

class Incident {
  int id;
  bool resolved;
  String createdAt;
  String updatedAt;
  List<IncidentInfo> info;
  List<Location> locations;

  Incident({
    required this.id,
    required this.resolved,
    required this.createdAt,
    required this.updatedAt,
    required this.info,
    required this.locations,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
        id: json['id'],
        resolved: json['resolved'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        info: (json['info'] as List<dynamic>)
            .map((e) => IncidentInfo.fromJson(e))
            .toList(),
        locations: (json['locations'] as List<dynamic>)
            .map((e) => Location.fromJson(e))
            .toList());
  }

  List<Widget> areasAffected() {
    return locations.map((e) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "\t\t\t• ${e.city} - ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: e.barangays.join(", "),
              style: const TextStyle(color: Colors.white70),
            )
          ],
        ),
      );
    }).toList();
  }
}
