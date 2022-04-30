class Location {
  String city;
  List<String> barangays;

  Location(this.city, this.barangays);

  factory Location.fromJson(Map<dynamic, dynamic> json) {
    return Location(
      json['city'],
      (json['barangays'] as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }
}
