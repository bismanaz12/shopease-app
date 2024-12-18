class LoginModel {
  String? id;
  String? email;
  String? password;

  LoginModel({this.id, this.email, this.password});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
        id: json['id'], email: json['email'], password: json['password']);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "email": email, "password": password};
  }
}
