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
    return IncidentInfo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
