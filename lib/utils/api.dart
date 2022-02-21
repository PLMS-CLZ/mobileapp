import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:plms_clz/types/login_data.dart';
import 'package:plms_clz/types/login_response.dart';

const domain = "plms-clz.herokuapp.com";

class API {
  static Future<LoginResponse> login(String email, String password) async {
    final url = Uri.https(domain, "/api/auth/lineman/login");
    final body = LoginData(email, password).toJson();
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: ContentType.json.toString()
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    final result = LoginResponse(
      response.statusCode,
      jsonDecode(response.body),
    );
    return result;
  }
}
