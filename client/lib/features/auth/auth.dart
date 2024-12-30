import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  Future<String> register(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "success - Please verify your email";
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'email-already-in-use':
          return 'An account already exists with this email';

        case 'invalid-email':
          return 'Invalid email address format';

        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled';

        case 'weak-password':
          return 'Password is too weak. Please use a stronger password';

        case 'network-request-failed':
          return 'Network error. Please check your connection';

        default:
          debugPrint("Firebase Auth Error: ${e.code}");
          return 'Registration failed: ${e.message}';
      }
    } catch (e) {
      // Handle any other errors
      debugPrint("Registration error: $e");
      return 'An unexpected error occurred. Please try again';
    }
  }

  Future<String> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "success";
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException Code: ${e.code}"); // Debug debugPrint

      if (e.code == 'wrong-password') {
        return 'The password entered is incorrect.';
      } else if (e.code == 'user-not-found') {
        return 'No user found with this email.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format.';
      } else if (e.code == 'user-disabled') {
        return 'This user account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        return 'Too many failed login attempts. Please try again later.';
      } else if (e.code == 'operation-not-allowed') {
        return 'Email & Password sign-in is not enabled.';
      } else if (e.code == 'network-request-failed') {
        return 'Network error. Please check your connection.';
      } else {
        debugPrint("Unhandled FirebaseAuthException: ${e.code}");
        return "Login error: ${e.code}";
      }
    } catch (e) {
      debugPrint("Unexpected error during login: $e");
      return "Login failed. Please try again.";
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint("could not logout user due to $e");
    }
  }

  Future<dynamic> registerOrLoginWithGoogle() async {
    try {
      // Attempt Google sign-in
      debugPrint("Attempting Google sign-in...");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        debugPrint("User cancelled the Google sign-in.");
        return null;
      }

      debugPrint("Google sign-in successful. User: ${googleUser.email}");

      // Get Google authentication tokens
      debugPrint("Retrieving Google authentication tokens...");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint("Access Token: ${googleAuth.accessToken}");
      debugPrint("ID Token: ${googleAuth.idToken}");

      // Create Firebase credential
      debugPrint("Creating Firebase credential...");
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in/up with Firebase
      debugPrint("Signing in with Firebase...");
      UserCredential user = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      debugPrint("Google Sign-in Successful. Email: ${user.user!.email}");
      return user.user!.email;
    } catch (e) {
      debugPrint('Could not sign in through Google because of exception -> $e');
      rethrow;
    }
  }

   Future<User?> getCurrentUser() async {
    try {
      return  FirebaseAuth.instance.currentUser;
    } catch (e) {
      debugPrint("could not get current user");
      return null;
    }
  }

  Future<String> passwordReset(String email) async {
  try {
    String trimmedEmail = email.trim().toLowerCase();

    if (trimmedEmail.isEmpty) {
      return 'Please enter a valid email address.';
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(email: trimmedEmail);

    // If successful, return this message
    return 'Password reset link sent! Check your email';

  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address format';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        debugPrint("Firebase Auth Error: ${e.code}");
        return 'Failed to send password reset link: ${e.message}';
    }
  } catch (e) {
    // Catch any unexpected errors
    debugPrint("Password reset error: $e");
    return 'An unexpected error occurred';
  }
}
}
