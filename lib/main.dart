import 'package:flutter/material.dart';
import 'package:plms_clz/views/home.dart';
import 'package:plms_clz/views/login.dart';

void main() {
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
