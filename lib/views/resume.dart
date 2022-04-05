import 'package:flutter/material.dart';
import 'package:plms_clz/models/lineman.dart';
import 'package:plms_clz/views/home.dart';
import 'package:plms_clz/views/login.dart';

class Resume extends StatefulWidget {
  final String token;
  final Lineman lineman;

  const Resume(this.lineman, this.token, {Key? key}) : super(key: key);

  @override
  State<Resume> createState() => _ResumeState();
}

class _ResumeState extends State<Resume> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.lineman.resume(widget.token),
      builder: (context, AsyncSnapshot<int> snapshot) {
        final connectionDone = snapshot.connectionState == ConnectionState.done;

        if (connectionDone && snapshot.hasData) {
          int statusCode = snapshot.data!;

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => statusCode == 200
                    ? Home(widget.lineman)
                    : Login(widget.lineman),
              ),
            );
          });
        }

        return const Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        );
      },
    );
  }
}
