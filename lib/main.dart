import 'package:plms_clz/models/lineman.dart';
import 'package:plms_clz/views/resume.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:plms_clz/utils/notif.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:plms_clz/views/login.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

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
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Notif.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // If login, change view
    return MaterialApp(
      title: 'PLMS',
      theme: ThemeData.dark(),
      home: const Splash(),
    );
  }
}

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
        final connectionDone = snapshot.connectionState == ConnectionState.done;

        if (connectionDone && snapshot.hasData) {
          final preferences = snapshot.data!;
          final token = preferences.getString('apiToken');
          final lineman = Lineman(preferences);

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    token == null ? Login(lineman) : Resume(lineman, token),
              ),
            );
          });
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
