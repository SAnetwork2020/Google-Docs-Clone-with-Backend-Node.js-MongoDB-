import 'dart:convert';

class UserModel {
  final String email, profilePic, name, uid, token;

  UserModel(
      {required this.email,
      required this.profilePic,
      required this.name,
      required this.uid,
      required this.token});

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "name": name,
      "profilePic": profilePic,
      "uid": uid,
      "token": token,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map["email"] ?? "",
      name: map["name"] ?? "",
      profilePic: map["profilePic"] ?? "",
      uid: map["_id"] ?? "",
      token: map["token"] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({String? email, name, profilePic, uid, token}) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      uid: uid ?? this.uid,
      token: token ?? this.token,
    );
  }
}
