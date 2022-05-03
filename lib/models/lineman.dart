import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:plms_clz/models/incident.dart';
import 'package:plms_clz/utils/constants.dart';
import 'package:plms_clz/utils/session.dart';

class Lineman {
  int? id;
  String? name;
  String? email;
  String? barangay;
  String? contactNo;
  String? apiToken;
  String? fcmToken;

  Lineman();

  Future<int> resume() async {
    final url = Uri.https(domain, '/api/lineman');
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: "Bearer " + apiToken!,
    };

    final response = await http.get(
      url,
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == HttpStatus.ok) {
      id = data['id'];
      name = data['name'];
      email = data['email'];
      barangay = data['barangay'];
      contactNo = data['contact_no'];
      fcmToken = data['fcmToken'];
    }

    return response.statusCode;
  }

  Future<int> login(String _email, String _password) async {
    final url = Uri.https(domain, "/api/lineman/login");
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: ContentType.json.toString()
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"email": _email, "password": _password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == HttpStatus.ok) {
      id = data['id'];
      name = data['name'];
      email = data['email'];
      barangay = data['barangay'];
      contactNo = data['contact_no'];
      apiToken = data['token'];
      fcmToken = data['fcmToken'];

      await updateFcmToken();
      await Session.refreshIncidents();
      await Session.preferences.setString('apiToken', apiToken!);
    } else {
      Fluttertoast.showToast(
        msg: data['message'] ?? 'Failed to login',
        toastLength: Toast.LENGTH_LONG,
      );
    }

    return response.statusCode;
  }

  Future<int> logout() async {
    final url = Uri.https(domain, "/api/lineman/logout");
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: "Bearer " + apiToken!,
    };

    final response = await http.post(
      url,
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == HttpStatus.ok) {
      id = null;
      name = null;
      email = null;
      barangay = null;
      contactNo = null;
      apiToken = null;
      fcmToken = null;

      await Session.invalidate();
    } else {
      Fluttertoast.showToast(
        msg: data['message'] ?? 'Failed to logout',
        toastLength: Toast.LENGTH_LONG,
      );
    }

    return response.statusCode;
  }

  Future<int> updatePassword(String newPassword) async {
    final url = Uri.https(domain, '/api/lineman/$id');
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: "Bearer " + apiToken!,
    };

    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode({"password": newPassword}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != HttpStatus.ok) {
      final errors = (data['errors']['password'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
      Fluttertoast.showToast(
        msg: errors.isNotEmpty
            ? errors.join('\n')
            : 'Failed to update password.',
        toastLength: Toast.LENGTH_LONG,
      );
    }

    return response.statusCode;
  }

  Future<void> updateFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    final url = Uri.https(domain, '/api/lineman/$id');
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

    final data = jsonDecode(response.body);

    if (response.statusCode == HttpStatus.ok) {
      fcmToken = token;
    } else {
      final errors = (data['errors']['fcm_token'] as List<dynamic>)
          .map((e) => e.toString()) as List<String>;
      Fluttertoast.showToast(
        msg: errors.isNotEmpty
            ? errors.join('\n')
            : 'Failed to update fcm token.',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<List<Incident>> getIncidents() async {
    final url = Uri.https(domain, '/api/lineman/$id/incidents');
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: "Bearer " + apiToken!,
    };

    final response = await http.get(
      url,
      headers: headers,
    );

    final data = jsonDecode(response.body) as List<dynamic>;

    final incidents = data.map((e) => Incident.fromJson(e)).toList();

    return incidents;
  }
}
