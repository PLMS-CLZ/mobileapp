import 'package:plms_clz/models/incidentinfo.dart';

class Incident {
  int id;
  bool resolved;
  String createdAt;
  String updatedAt;
  List<IncidentInfo> info;

  Incident({
    required this.id,
    required this.resolved,
    required this.createdAt,
    required this.updatedAt,
    required this.info,
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
    );
  }
}
