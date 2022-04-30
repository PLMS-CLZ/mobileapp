class Unit {
  int id;
  String status;
  double latitude;
  double longitude;
  String formattedAddress;

  Unit({
    required this.id,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      status: json['status'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      formattedAddress: json['formatted_address'],
    );
  }
}
