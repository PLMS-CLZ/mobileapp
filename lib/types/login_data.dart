class LoginData {
  String? email;
  String? password;

  LoginData(this.email, this.password);

  toJson() {
    return {"email": email, "password": password};
  }
}
