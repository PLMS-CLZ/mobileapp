class IncidentInfo {
  int id;
  String title;
  String description;
  DateTime createdAt;
  DateTime updatedAt;

  IncidentInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncidentInfo.fromJson(Map<String, dynamic> json) {
    return IncidentInfo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
