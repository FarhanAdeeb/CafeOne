import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_chat_app/models/user_model.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel;

    DocumentSnapshot docsnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docsnap.data() != null) {
      userModel = UserModel.fromMap(docsnap.data() as Map<String, dynamic>);
    }
    return userModel;
  }
}
