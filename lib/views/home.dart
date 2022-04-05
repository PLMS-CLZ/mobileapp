import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:plms_clz/models/incident.dart';
import 'package:plms_clz/models/lineman.dart';
import 'package:plms_clz/utils/notif.dart';
import 'package:plms_clz/views/login.dart';

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
          currentIndex: selectedScreen,
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
            setState(() {
              selectedScreen = index;
            });
          }),
      body: selectedScreen == 0
          ? homeScreen()
          : selectedScreen == 1
              ? incidentsScreen()
              : profileScreen(),
    );
  }

  Widget homeScreen() {
    return FutureBuilder(
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
        final connectionDone = snapshot.connectionState == ConnectionState.done;

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
    );
  }

  Widget incidentsScreen() {
    return FutureBuilder(
      future: widget.lineman.getIncidents(),
      builder: (context, AsyncSnapshot<List<Incident>> snapshot) {
        final connectionDone = snapshot.connectionState == ConnectionState.done;

        if (connectionDone && snapshot.hasData) {
          final incidents = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(5),
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];

              return Card(
                child: ListTile(
                  minLeadingWidth: 0,
                  leading: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        incident.id.toString(),
                        style: const TextStyle(fontSize: 35),
                      )
                    ],
                  ),
                  title: Text(incident.info[0].title),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(incident.info[0].description),
                        const SizedBox(height: 10),
                        Text(incident.info[0].updatedAt),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget profileScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 100,
                  ),
                  radius: 60,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.lineman.name!,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'ID:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.lineman.id?.toString() ?? 'Not Set',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Email:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.lineman.email ?? 'Not Set',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Designation:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.lineman.barangay ?? 'Not Set',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Contact Number:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.lineman.barangay ?? 'Not Set',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: () async {
                int statusCode = await widget.lineman.logout();

                if (statusCode == 200) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(widget.lineman),
                    ),
                  );
                }
              },
              child: const Text(
                'Log out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
