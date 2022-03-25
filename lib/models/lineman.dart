import 'dart:convert';

import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

const domain = "plms-clz.herokuapp.com";

class Lineman {
  String email;
  String password;

  int? id;
  String? name;
  String? barangay;
  String? apiToken;
  String? fcmToken;

  Lineman(this.email, this.password);

  Future<int> login() async {
    final url = Uri.https(domain, "/api/lineman/login");
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: ContentType.json.toString()
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == HttpStatus.ok) {
      id = data['id'];
      name = data['name'];
      barangay = data['barangay'];
      apiToken = data['token'];
      fcmToken = data['fcmToken'];

      Fluttertoast.showToast(
        msg: 'Logged In!',
      );
    } else {
      Fluttertoast.showToast(
        msg: data['message'] ?? 'Failed to login',
      );
    }

    return response.statusCode;
  }
}
