import 'package:flutter/material.dart';
import 'package:plms_clz/models/incident.dart';
import 'package:plms_clz/utils/session.dart';
import 'package:plms_clz/views/home.dart';
import 'package:plms_clz/views/profile.dart';
import 'package:plms_clz/views/units.dart';

class Incidents extends StatefulWidget {
  const Incidents({Key? key}) : super(key: key);

  @override
  State<Incidents> createState() => _IncidentsState();
}

class _IncidentsState extends State<Incidents> {
  List<Incident> _incidents = Session.incidents;

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
        currentIndex: 1,
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
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home(),
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
      body: RefreshIndicator(
        onRefresh: () async {
          await Session.refreshIncidents();

          setState(() {
            _incidents = Session.incidents;
          });
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: _incidents.length,
          itemBuilder: (context, index) {
            final incident = _incidents[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Units(incident),
                  ),
                );
              },
              child: Card(
                elevation: 10,
                child: ListTile(
                  title: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Incident ${incident.id}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(incident.createdAt),
                        ],
                      ),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(thickness: 2),
                      const SizedBox(height: 5),
                      ...incident.info.reversed
                          .map((e) => e.format())
                          .reduce((value, element) {
                        element.addAll(value);
                        return element;
                      }).toList(),
                      const Divider(thickness: 2),
                      const SizedBox(height: 5),
                      const Text(
                        "Areas Affected:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ...incident.areasAffected(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
