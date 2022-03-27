import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool inputEnabled = true;
  bool passwordObscured = true;
  bool newPasswordObscured = true;
  bool confirmPasswordObscured = true;
  bool changePassword = false;
  late Lineman lineman;

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
                    enabled: inputEnabled && !changePassword,
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
                    enabled: inputEnabled && !changePassword,
                    obscureText: passwordObscured || changePassword,
                  ),
                  ...changePassword
                      ? [
                          const SizedBox(height: 30),
                          const Text("Change Password:"),
                          TextField(
                            controller: newPasswordController,
                            decoration: InputDecoration(
                              labelText: "New Password",
                              hintText: "Password",
                              icon: const Icon(Icons.password),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  newPasswordObscured
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    newPasswordObscured = !newPasswordObscured;
                                  });
                                },
                              ),
                            ),
                            enabled: inputEnabled,
                            obscureText: newPasswordObscured,
                          ),
                          TextField(
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              hintText: "Password",
                              icon: const Icon(Icons.password),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  confirmPasswordObscured
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    confirmPasswordObscured =
                                        !confirmPasswordObscured;
                                  });
                                },
                              ),
                            ),
                            enabled: inputEnabled,
                            obscureText: confirmPasswordObscured,
                          )
                        ]
                      : [],
                  const SizedBox(height: 40),
                  ElevatedButton(
                    child: Text(changePassword ? "Update Password" : "Login"),
                    onPressed: inputEnabled
                        ? () {
                            // dismiss keyboard during async call
                            FocusScope.of(context).requestFocus(FocusNode());

                            // start the modal progress HUD
                            setState(() {
                              inputEnabled = false;
                            });

                            Future((() async {
                              if (changePassword) {
                                final newPassword = newPasswordController.text;
                                final confirmPassword =
                                    confirmPasswordController.text;

                                if (newPassword != confirmPassword) {
                                  Fluttertoast.showToast(
                                    msg: "Password does not match.",
                                  );

                                  setState(() {
                                    inputEnabled = true;
                                  });
                                } else if (newPassword == "plmsystem") {
                                  Fluttertoast.showToast(
                                    msg:
                                        "New password must not be the default password.",
                                  );

                                  setState(() {
                                    inputEnabled = true;
                                  });
                                } else {
                                  final statusCode =
                                      await lineman.updatePassword(newPassword);

                                  if (statusCode == 200) {
                                    Navigator.of(context).popUntil((route) =>
                                        Navigator.of(context).canPop());
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => const Login(),
                                    ));
                                  } else {
                                    setState(() {
                                      inputEnabled = true;
                                    });
                                  }
                                }
                              } else {
                                final email = emailController.text;
                                final password = passwordController.text;
                                lineman = Lineman(email, password);
                                final statusCode = await lineman.login();

                                if (statusCode == 200) {
                                  if (password == "plmsystem") {
                                    setState(() {
                                      changePassword = true;
                                      inputEnabled = true;
                                    });
                                  } else {
                                    Navigator.of(context).popUntil((route) =>
                                        Navigator.of(context).canPop());
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => Home(lineman),
                                    ));
                                  }
                                } else {
                                  setState(() {
                                    inputEnabled = true;
                                  });
                                }
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
