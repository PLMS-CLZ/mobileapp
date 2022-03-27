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

  bool inputEnabled = true;
  bool passwordObscured = true;

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
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      hintText: "E-mail",
                      icon: Icon(Icons.email_outlined),
                    ),
                    enabled: inputEnabled,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Password",
                      icon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordObscured
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordObscured = !passwordObscured;
                          });
                        },
                      ),
                    ),
                    enabled: inputEnabled,
                    obscureText: passwordObscured,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    child: const Text("Login"),
                    onPressed: inputEnabled
                        ? () {
                            final email = emailController.text;
                            final password = passwordController.text;
                            final lineman = Lineman(email, password);

                            // dismiss keyboard during async call
                            FocusScope.of(context).requestFocus(FocusNode());

                            // start the modal progress HUD
                            setState(() {
                              inputEnabled = false;
                            });

                            Future((() async {
                              final statusCode = await lineman.login();

                              if (statusCode == 200) {
                                Navigator.of(context).popUntil(
                                    (route) => Navigator.of(context).canPop());
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Home(lineman),
                                ));
                              } else {
                                setState(() {
                                  inputEnabled = true;
                                });
                              }
                            }));
                          }
                        : null,
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
