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

      User? user = userCredential.user;

      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Store basic info
        await prefs.setBool('isRemeber', isRemeber);
        await prefs.setString('uid', user.uid);

        // Now fetch role from Firestore (example)
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          String role = userDoc.data()!['role'] ?? 'user'; // fallback role
          await prefs.setString('role', role);
        } else {
          await prefs.setString('role', 'user'); // default if not found
        }

        return user;
      }

      return null;
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
