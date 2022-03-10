import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:plms_clz/views/home.dart';
import 'package:plms_clz/views/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      initialRoute: 'login',
      routes: {
        'login': (context) => const Login(),
        'home': (context) => const Home(),
      },
    );
  }
}
