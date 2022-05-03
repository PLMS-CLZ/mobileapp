import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plms_clz/utils/session.dart';
import 'package:plms_clz/views/incidents.dart';
import 'package:plms_clz/views/profile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedScreen = 0;
  Completer<GoogleMapController> gMapCompleter = Completer();

  @override
  void initState() {
    gMapCompleter.future.then(Session.centerCamera);

    super.initState();
  }

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
                  builder: (context) => const Incidents(),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Profile(),
                ),
              );
          }
        },
      ),
      body: GoogleMap(
        mapType: MapType.terrain,
        initialCameraPosition: Session.cameraPosition,
        compassEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        onMapCreated: gMapCompleter.complete,
      ),
    );
  }
}
