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
        msg: "Logged in!",
      );
    } else {
      Fluttertoast.showToast(
        msg: data['message'] ?? 'Failed to login',
      );
    }

    return response.statusCode;
  }

  Future<void> updateFcmToken(String token) async {
    final url = Uri.https(domain, "/api/lineman/" + id.toString());
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: "Bearer " + apiToken!,
    };

    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode({"fcm_token": token}),
    );

    if (response.statusCode == HttpStatus.ok) {
      fcmToken = token;
    } else {
      Fluttertoast.showToast(
        msg: response.body,
      );
    }
  }
}
