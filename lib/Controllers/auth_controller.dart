import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:FFinance/Routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

  // Track the number of failed login attempts
  var loginAttempts = 0.obs;

  void updateEmail(String value) {
    email.value = value.trim();
    print('Updated email: ${email.value}'); // Debugging log
  }

  void updatePassword(String value) {
    password.value = value.trim();
    print('Updated password: ${password.value}'); // Debugging log
  }


  Future<void> loginOrRegister() async {
    isLoading.value = true;

    try {
      print('Attempting to log in with email: "${email.value}"');

      // Attempt to sign in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      if (userCredential.user != null) {
        print('Login successful. User ID: ${userCredential.user?.uid}');
        Get.offAllNamed(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific error codes
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        Get.snackbar('Login Error', 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        Get.snackbar('Login Error', 'Wrong password provided.');
      } else {
        print('Error: $e');
        Get.snackbar('Login Error', 'An unknown error occurred.');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Login Error', 'An unexpected error occurred.');
    } finally {
      isLoading.value = false;
    }
  }


// Helper method to show login error message
  void _showLoginErrorMessage() {
    Get.snackbar(
      'Login Error',
      'Email/Password mungkin salah atau belum terdaftar.',
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP, // Position at the top
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }


  // Register with email and password
  Future<void> registerWithEmail() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Email and password cannot be empty');
      return;
    }

    isLoading.value = true;

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );

      // Show success notification
      Get.snackbar('Success', 'Registration successful! Welcome!');
      Get.offAllNamed(AppRoutes.home); // Navigate to MainPage on successful registration
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Google Sign-In implementation
  Future<void> signInWithGoogle() async {
    isLoading.value = true;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        Get.snackbar('Login Cancelled', 'User cancelled the Google login.');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      Get.offAllNamed(AppRoutes.home); // Navigate to MainPage on success
    } catch (e) {
      Get.snackbar('Google Login Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Placeholder Microsoft sign-in
  Future<void> signInWithMicrosoft() async {
    Get.snackbar('Microsoft Login', 'Microsoft login not implemented yet.');
  }

  void updateTermsAccepted(bool isChecked) {}
}
