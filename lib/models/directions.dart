import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final List<dynamic> steps;
  final String totalDistance;
  final int totalDistanceInt;
  final String totalDuration;

  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.steps,
    required this.totalDistance,
    required this.totalDistanceInt,
    required this.totalDuration,
  });

  factory Directions.fromJson(Map<String, dynamic> json) {
    if ((json['routes'] as List<dynamic>).isEmpty) throw "";

    final data = Map<String, dynamic>.from(json['routes'][0]);

    final neBound = data['bounds']['northeast'];
    final swBound = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(neBound['lat'], neBound['lng']),
      southwest: LatLng(swBound['lat'], swBound['lng']),
    );

    String totalDistance = "";
    int totalDistanceInt = 0;
    String totalDuration = "";
    List<dynamic> steps = [];

    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      totalDistance = leg['distance']['text'];
      totalDistanceInt = leg['distance']['value'];
      totalDuration = leg['duration']['text'];
      steps = leg['steps'];
    }

    return Directions(
      bounds: bounds,
      polylinePoints: PolylinePoints().decodePolyline(
        data['overview_polyline']['points'],
      ),
      steps: steps,
      totalDistance: totalDistance,
      totalDistanceInt: totalDistanceInt,
      totalDuration: totalDuration,
    );
  }
}
