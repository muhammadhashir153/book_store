import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

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

  static Future<bool> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store basic info
    try {
      await FirebaseAuth.instance.signOut();
      await prefs.remove('isRemeber');
      await prefs.remove('uid');
      await prefs.remove('role');
      return true;
    } catch (e) {
      print("Error logging out user: $e");
      return false;
    }
  }

  static Future<User?> signInWithGoogle(Map<String, dynamic> userData) async {
    try {
      print('Attempting Google sign-in');
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? '389708759305-3sibfo29sdhf7emp68eg3qld5d3rbhv6.apps.googleusercontent.com'
            : null,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("User cancelled Google login or popup blocked.");
        return null;
      }

      print("Google user: ${googleUser.displayName}, ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final user = userCredential.user;
      print("Firebase user: ${user?.uid}");

      if (user != null) {
        final docRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid);
        final doc = await docRef.get();

        if (!doc.exists) {
          userData['email'] = user.email;
          userData['name'] = user.displayName ?? '';
          userData['profileImage'] = user.photoURL ?? '';
          await docRef.set(userData);
          print("User data saved to Firestore.");
        } else {
          print("User already exists in Firestore.");
        }
      }

      return user;
    } catch (e, stack) {
      print("Google login error: $e");
      print("StackTrace: $stack");
      return null;
    }
  }

  static Future<User?> signInWithFacebook(Map<String, dynamic> userData) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return null;

      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        final docRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid);
        final doc = await docRef.get();

        if (!doc.exists) {
          userData['email'] = user.email;
          userData['name'] = user.displayName ?? '';
          userData['profileImage'] = user.photoURL ?? '';
          await docRef.set(userData);
        }
      }

      return user;
    } catch (e) {
      print("Facebook login error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Handle your user data here
        return userDoc.data() as Map<String, dynamic>?;
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  static Future<void> updateUserData(
    String userId,
    Map<String, dynamic> newData,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update(newData);
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  static Future<void> updateUserPassword(
      String oldPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No user is currently signed in.");
    }

    try {
      AuthCredential credential =
          EmailAuthProvider.credential(email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception("Failed to update password: ${e.message}");
    }
  }
}
