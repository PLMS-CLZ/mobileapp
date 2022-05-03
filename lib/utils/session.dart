import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:plms_clz/models/incident.dart';
import 'package:plms_clz/models/lineman.dart';
import 'package:plms_clz/utils/constants.dart';
import 'package:plms_clz/utils/local_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Lineman _lineman;
late Location _location;
late CameraPosition _cameraPosition;
late SharedPreferences _preferences;

List<Incident> _incidents = [];
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

  static Future<void> centerCamera(GoogleMapController? _controller) async {
    // Cancel previous subscription
    _subscription?.cancel();

    // Create new subscription
    _subscription = _location.onLocationChanged.listen((event) async {
      if (event.latitude == null) return;
      if (event.longitude == null) return;

      try {
        final zoom = await _controller?.getZoomLevel();
        final position = LatLng(event.latitude!, event.longitude!);

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

        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(_cameraPosition),
        );
      } catch (_) {
        _controller?.dispose();
        _subscription?.cancel();
      }
    });
  }
}
