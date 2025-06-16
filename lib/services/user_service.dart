import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  static Future<User?> registerUser(
    String email,
    String pass,
    Map<String, dynamic> userData,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .set(userData);
      }
      return user;
    } catch (e) {
      print("Error registering user: $e");
      return null;
    }
  }

  static Future<User?> loginUser(
    String email,
    String pass,
    bool isRemeber,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      if (isRemeber) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isRemeber', isRemeber);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isRemeber', isRemeber);
      }
      return userCredential.user;
    } catch (e) {
      print("Error logging in user: $e");
      return null;
    }
  }

  static Future<void> logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Error logging out user: $e");
    }
  }
}
