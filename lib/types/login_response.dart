class LoginResponse {
  String? token;
  String? message;
  int? statusCode;

  LoginResponse(this.statusCode, Map<String, dynamic> json) {
    message = json['message'].toString();
    token = json['token'].toString();
  }
}
