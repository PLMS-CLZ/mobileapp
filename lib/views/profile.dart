import 'package:flutter/material.dart';
import 'package:plms_clz/utils/session.dart';
import 'package:plms_clz/views/home.dart';
import 'package:plms_clz/views/incidents.dart';
import 'package:plms_clz/views/login.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
          currentIndex: 2,
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
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Incidents(),
                  ),
                );
            }
          }),
      body: Padding(
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
                    Session.lineman.name!,
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
              Session.lineman.id?.toString() ?? 'Not Set',
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
              Session.lineman.email ?? 'Not Set',
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
              Session.lineman.barangay ?? 'Not Set',
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
              Session.lineman.contactNo ?? 'Not Set',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () async {
                  int statusCode = await Session.lineman.logout();

                  if (statusCode == 200) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
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
      ),
    );
  }
}
