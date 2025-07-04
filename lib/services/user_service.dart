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
            .collection('Users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          String role = userDoc.data()!['role'] ?? 'not found'; // fallback role
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

  static Future<Map<String, dynamic>> signInWithGoogle(
    Map<String, dynamic> userData,
  ) async {
    try {
      print('Attempting Google sign-in');

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? '389708759305-3sibfo29sdhf7emp68eg3qld5d3rbhv6.apps.googleusercontent.com'
            : null,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'User cancelled Google login or popup blocked.',
        };
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
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
          print("User data saved to Firestore.");
        }

        // Save role and uid to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', userData['role']);
        await prefs.setString('uid', user.uid); // ← Save UID here

        return {
          'success': true,
          'user': user,
          'message': 'Google sign-in successful.',
        };
      } else {
        return {'success': false, 'message': 'Firebase authentication failed.'};
      }
    } catch (e, stack) {
      print("Google login error: $e");
      print("StackTrace: $stack");

      return {'success': false, 'message': 'An unexpected error occurred: $e'};
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

  static Future<Map<String, dynamic>> updateUserPassword(
    String oldPassword,
    String newPassword,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {'success': false, 'message': "No user is currently signed in."};
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return {'success': true, 'message': "Password updated successfully."};
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'wrong-password':
          errorMessage = "The current password is incorrect.";
          break;
        case 'weak-password':
          errorMessage = "The new password is too weak.";
          break;
        case 'requires-recent-login':
          errorMessage = "Please log in again before updating your password.";
          break;
        default:
          errorMessage = e.message ?? "Failed to update password.";
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': "Unexpected error: ${e.toString()}"};
    }
  }
}
