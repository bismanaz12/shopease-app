class Admin {
  final String uid;
  final String email;
  final String password;
  final String? imageUrl;
  final String? userName;


  Admin( {
    required this.uid,
    required this.email,
    required this.password,
    this.imageUrl,
    this.userName
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'password': password,
      'userName':userName,
      'imageUrl':imageUrl,

    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      userName: map['userName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',

    );
  }
}
