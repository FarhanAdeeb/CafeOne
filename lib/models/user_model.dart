class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;
  String? role;

  UserModel({this.uid, this.fullname, this.email, this.profilepic, this.role});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
    role = map["role"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
      "role": role,
    };
  }
}
