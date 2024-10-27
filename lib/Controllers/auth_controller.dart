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
      // Log the email value
      print('Attempting to log in with email: "${email.value}"');
      print('Checking sign-in methods for: ${email.value}');

      // This line will throw if the email is not found, which is handled in the catch block
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email.value);

      // Attempt to sign in regardless of the previous check
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.value,
          password: password.value,
        );

        if (userCredential.user != null) {
          print('Login successful. User ID: ${userCredential.user?.uid}');
          Get.offAllNamed(AppRoutes.home);
        } else {
          print('Login failed: userCredential.user is null');
          _showLoginErrorMessage(); // Show error message
        }
      } catch (e) {
        print('Sign-in failed: $e'); // Log error when signing in
        _showLoginErrorMessage(); // Show error message
      }
    } catch (e) {
      print('Error checking email: $e'); // Log error when fetching sign-in methods
      _showLoginErrorMessage(); // Show error message
    } finally {
      isLoading.value = false;
    }

    // Check if the email exists and navigate to the registration page if it doesn't
    final signInMethods = await _auth.fetchSignInMethodsForEmail(email.value);
    if (signInMethods.isEmpty) {
      _showLoginErrorMessage(); // Show error message
      await Future.delayed(Duration(seconds: 4)); // Wait for 4 seconds
      Get.offAllNamed(AppRoutes.register); // Navigate to registration page
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
