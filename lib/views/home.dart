import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:plms_clz/models/lineman.dart';
import 'package:plms_clz/utils/notif.dart';
import 'package:plms_clz/views/incidents.dart';
import 'package:plms_clz/views/profile.dart';

class Home extends StatefulWidget {
  final Lineman lineman;

  const Home(this.lineman, {Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedScreen = 0;

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
      if (token == null) return;
      widget.lineman.updateFcmToken(token);
    });
  }

  CameraPosition initialCenter = const CameraPosition(
    target: LatLng(10.94463755493866, 123.27352044217186),
    zoom: 13,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        toolbarOpacity: 0,
        shadowColor: Colors.transparent,
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Incidents',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Incidents(widget.lineman),
                  ),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(widget.lineman),
                  ),
                );
            }
          }),
      body: FutureBuilder(
        future: () async {
          final location = Location();

          bool _serviceEnabled = await location.serviceEnabled();
          if (!_serviceEnabled) {
            _serviceEnabled = await location.requestService();
            if (!_serviceEnabled) {
              return null;
            }
          }

          PermissionStatus _permissionGranted = await location.hasPermission();
          if (_permissionGranted == PermissionStatus.denied) {
            _permissionGranted = await location.requestPermission();
            if (_permissionGranted != PermissionStatus.granted) {
              return null;
            }
          }

          return location.getLocation();
        }(),
        builder: (context, AsyncSnapshot<LocationData?> snapshot) {
          final connectionDone =
              snapshot.connectionState == ConnectionState.done;

          if (connectionDone) {
            if (snapshot.hasData) {
              final location = snapshot.data!;

              if (location.latitude != null && location.longitude != null) {
                initialCenter = CameraPosition(
                  target: LatLng(location.latitude!, location.longitude!),
                  zoom: 18,
                );
              }

              return GoogleMap(
                mapType: MapType.terrain,
                initialCameraPosition: initialCenter,
                compassEnabled: true,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              );
            } else {
              return const Center(
                child: Text('Location Permission Denied'),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
