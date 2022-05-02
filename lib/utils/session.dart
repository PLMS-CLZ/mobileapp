import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:plms_clz/models/lineman.dart';
import 'package:plms_clz/utils/constants.dart';
import 'package:plms_clz/utils/local_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Lineman _lineman;
late SharedPreferences _preferences;

Location _location = Location();
StreamSubscription<LocationData>? _subscription;

class Session {
  static Lineman get lineman {
    return _lineman;
  }

  static SharedPreferences get preferences {
    return _preferences;
  }

  static Future<int> initialize() async {
    int result = 0;

    _preferences = await SharedPreferences.getInstance();

    _lineman = Lineman();
    _lineman.apiToken = _preferences.getString('apiToken');
    if (_lineman.apiToken != null) result = await _lineman.resume();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = notification?.android;

      if (_lineman.fcmToken != null) return;
      if (notification != null) return;
      if (android != null) return;

      LocalNotification.show(
        notification!.hashCode,
        notification.title,
        notification.body,
        icon: android!.smallIcon,
      );
    });

    return result;
  }

  static Future<LatLng> location() async {
    // Check if service is enabled
    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return cadizCity;
      }
    }

    // Check if app has permission
    PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return cadizCity;
      }
    }

    final location = await _location.getLocation();
    if (location.latitude == null || location.longitude == null) {
      return cadizCity;
    }

    return LatLng(location.latitude!, location.longitude!);
  }

  static Future<void> centerMapLocation(
      GoogleMapController? _controller) async {
    // Check if service is enabled
    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if app has permission
    PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Cancel previous subscription
    _subscription?.cancel();

    // Create new subscription
    _subscription = _location.onLocationChanged.listen((event) async {
      if (event.latitude == null) return;
      if (event.longitude == null) return;

      try {
        final zoom = await _controller?.getZoomLevel();
        final position = LatLng(event.latitude!, event.longitude!);
        final cameraPosition =
            CameraPosition(target: position, zoom: zoom ?? 15);

        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
      } catch (_) {
        _controller?.dispose();
        _subscription?.cancel();
      }
    });
  }
}
