import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:plms_clz/models/directions.dart';
import 'package:plms_clz/models/incident.dart';
import 'package:plms_clz/models/lineman.dart';
import 'package:plms_clz/models/unit.dart';
import 'package:plms_clz/utils/constants.dart';
import 'package:plms_clz/utils/local_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

late Lineman _lineman;
late Location _location;
late CameraPosition _cameraPosition;
late SharedPreferences _preferences;

List<Incident> _incidents = [];
Marker? _navDestination;
Directions? _navDirections;
StreamSubscription<LocationData>? _subscription;

class Session {
  static Lineman get lineman {
    return _lineman;
  }

  static SharedPreferences get preferences {
    return _preferences;
  }

  static CameraPosition get cameraPosition {
    return _cameraPosition;
  }

  static List<Incident> get incidents {
    return _incidents;
  }

  static Marker? get navDestination {
    return _navDestination;
  }

  static Directions? get navDirections {
    return _navDirections;
  }

  static Future<int> initialize() async {
    int result = 0;

    // Shared Preferences
    _preferences = await SharedPreferences.getInstance();

    // Lineman
    _lineman = Lineman();
    _lineman.apiToken = _preferences.getString('apiToken');
    if (_lineman.apiToken != null) result = await _lineman.resume();

    // Location
    _location = Location();

    // Check if service is enabled
    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
    }

    // Check if app has permission
    PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
    }

    // Request notification permission
    await FirebaseMessaging.instance.requestPermission();

    // Foreground Notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = notification?.android;

      if (_lineman.fcmToken == null) return;
      if (notification == null) return;
      if (android == null) return;

      LocalNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        icon: android.smallIcon,
      );
    });

    final mapZoom = _preferences.getDouble('mapZoom') ?? 19;
    final mapLat = _preferences.getDouble('mapLat');
    final mapLng = _preferences.getDouble('mapLng');

    final mapTarget =
        (mapLat != null && mapLng != null) ? LatLng(mapLat, mapLng) : cadizCity;

    _cameraPosition = CameraPosition(
      target: mapTarget,
      zoom: mapZoom,
    );

    if (result == 200) {
      await refreshIncidents();
      await _lineman.updateFcmToken();
    }

    return result;
  }

  static Future<void> invalidate() async {
    _incidents = [];
    _subscription?.cancel();
    await _preferences.clear();
  }

  static Future<void> refreshIncidents() async {
    _incidents = await _lineman.getIncidents();
  }

  static Future<void> mapUpdates({
    required Function setState,
    GoogleMapController? controller,
  }) async {
    // Cancel previous subscription
    _subscription?.cancel();

    int locationUpdates = 0;

    // Create new subscription
    _subscription = _location.onLocationChanged.listen((event) async {
      if (event.latitude == null) return;
      if (event.longitude == null) return;

      locationUpdates++;

      final position = LatLng(event.latitude!, event.longitude!);

      // Center Camera
      try {
        final zoom = await controller?.getZoomLevel();

        if (zoom != null && _cameraPosition.zoom != zoom) {
          await _preferences.setDouble('mapZoom', zoom);
        }

        if (position.latitude != _cameraPosition.target.latitude) {
          await _preferences.setDouble('mapLat', position.latitude);
        }

        if (position.longitude != _cameraPosition.target.longitude) {
          await _preferences.setDouble('mapLng', position.longitude);
        }

        _cameraPosition = CameraPosition(target: position, zoom: zoom ?? 19);

        controller?.animateCamera(
          CameraUpdate.newCameraPosition(_cameraPosition),
        );
      } catch (_) {
        controller?.dispose();
        _subscription?.cancel();
        return;
      }

      // Recalculate directions
      try {
        if (Session.navDestination == null) throw "";
        if (!(locationUpdates == 1 || locationUpdates % 10 == 0)) throw "";

        final destination = Session.navDestination!.position;

        final url = Uri.https(googleApiDomain, '/maps/api/directions/json', {
          'origin': "${position.latitude},${position.longitude}",
          'destination': "${destination.latitude},${destination.longitude}",
          'key': googleApiKey
        });

        final headers = <String, String>{
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.acceptHeader: ContentType.json.toString(),
        };

        final response = await http.get(url, headers: headers);

        final data = jsonDecode(response.body);
        if (response.statusCode != HttpStatus.ok) throw "";

        _navDirections = Directions.fromJson(data);

        // if no steps, stop navigation
        if (_navDirections!.steps.isEmpty ||
            _navDirections!.totalDistanceInt < 10) {
          _navDirections = null;
          _navDestination = null;

          LocalNotification.show(
            0,
            "PLMS Navigation",
            "You have arrived at your destination!",
          );
        }

        setState(() {});
      } catch (_) {}
    });
  }

  static Future<void> navigateTo(Unit unit) async {
    final location = await _location.getLocation();
    if (location.latitude == null || location.longitude == null) return;
    final destination = LatLng(unit.latitude, unit.longitude);

    _navDestination = Marker(
      markerId: MarkerId(unit.id.toString()),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: "Unit ${unit.id}"),
      position: destination,
    );
  }
}
