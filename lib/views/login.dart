import 'package:flutter/material.dart';
import 'package:plms_clz/models/lineman.dart';
import 'package:plms_clz/views/home.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Power Line Monitoring Systems"),
      ),
      body: Center(
        child: ListView(
          children: [
            const SizedBox(
              height: 50,
            ),
            CircleAvatar(
              child: Image.asset('assets/logo.png'),
              radius: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      hintText: "E-mail",
                      icon: Icon(Icons.email_outlined),
                    ),
                    controller: emailController,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Password",
                      hintText: "Password",
                      icon: Icon(Icons.lock_outline),
                    ),
                    controller: passwordController,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    child: const Text("Login"),
                    onPressed: () async {
                      final email = emailController.text;
                      final password = passwordController.text;

                      final lineman = Lineman(email, password);
                      final result = await lineman.login();

                      if (result == 200) {
                        Navigator.of(context).popUntil(
                            (route) => Navigator.of(context).canPop());

                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Home(lineman),
                        ));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
