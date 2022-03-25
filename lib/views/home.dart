import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plms_clz/models/lineman.dart';
import 'package:plms_clz/utils/notif.dart';

class Home extends StatefulWidget {
  final Lineman lineman;

  const Home(this.lineman, {Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = notification?.android;

      if (notification != null && android != null) {
        Notif.show(
          notification.hashCode,
          notification.title,
          notification.body,
          icon: android.smallIcon,
        );
      }
    });

    FirebaseMessaging.instance.getToken().then((token) {
      widget.lineman.fcmToken = token;
      Fluttertoast.showToast(msg: token ?? 'No Token');
    });
  }

  static const CameraPosition cadizCity = CameraPosition(
    target: LatLng(10.94463755493866, 123.27352044217186),
    zoom: 13,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: cadizCity,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
