import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plms_clz/models/incidentinfo.dart';
import 'package:plms_clz/models/location.dart';
import 'package:plms_clz/models/unit.dart';
import 'package:plms_clz/utils/constants.dart';
import 'package:plms_clz/utils/session.dart';

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

  Future<List<Unit>> getUnits() async {
    final url = Uri.https(domain, '/api/incidents/$id/units');
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: "Bearer " + Session.lineman.apiToken!,
    };

    final response = await http.get(
      url,
      headers: headers,
    );

    final data = jsonDecode(response.body) as List<dynamic>;

    final units = data.map((e) => Unit.fromJson(e)).toList();

    return units;
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
