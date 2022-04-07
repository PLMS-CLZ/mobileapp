import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:plms_clz/models/incident.dart';
import 'package:shared_preferences/shared_preferences.dart';

const domain = "plms-clz.herokuapp.com";
final preferences = SharedPreferences.getInstance();

class Lineman {
  SharedPreferences preferences;

  int? id;
  String? name;
  String? email;
  String? barangay;
  String? contactNo;
  String? apiToken;
  String? fcmToken;

  Lineman(this.preferences);

  Future<int> resume(String token) async {
    final url = Uri.https(domain, '/api/lineman');
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: "Bearer " + token,
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
      apiToken = token;
      fcmToken = data['fcmToken'];
    } else {
      Fluttertoast.showToast(
        msg: data['message'] ?? 'Failed to resume',
        toastLength: Toast.LENGTH_LONG,
      );
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

      preferences.setString('apiToken', apiToken ?? '');
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

      preferences.remove('apiToken');
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

  Future<void> updateFcmToken(String newToken) async {
    final url = Uri.https(domain, '/api/lineman/$id');
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: ContentType.json.toString(),
      HttpHeaders.authorizationHeader: "Bearer " + apiToken!,
    };

    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode({"fcm_token": newToken}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == HttpStatus.ok) {
      fcmToken = newToken;
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
