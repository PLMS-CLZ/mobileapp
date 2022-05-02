import 'package:flutter/material.dart';
import 'package:plms_clz/models/incident.dart';
import 'package:plms_clz/models/unit.dart';
import 'package:plms_clz/views/home.dart';
import 'package:plms_clz/views/profile.dart';

class Units extends StatefulWidget {
  final Incident incident;
  const Units(this.incident, {Key? key}) : super(key: key);

  @override
  State<Units> createState() => _UnitsState();
}

class _UnitsState extends State<Units> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Incident ${widget.incident.id}"),
        centerTitle: true,
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
      body: FutureBuilder(
        future: widget.incident.getUnits(),
        builder: (context, AsyncSnapshot<List<Unit>> snapshot) {
          final connectionDone =
              snapshot.connectionState == ConnectionState.done;

          if (connectionDone && snapshot.hasData) {
            final units = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(5),
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];

                return Card(
                  elevation: 10,
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Unit ${unit.id}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: unit.format(),
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
      ),
    );
  }
}
