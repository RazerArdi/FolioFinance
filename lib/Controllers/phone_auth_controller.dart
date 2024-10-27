import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PhoneAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var phoneNumber = ''.obs;
  var verificationId = ''.obs;
  var isLoading = false.obs;

  // Update phone number in state
  void updatePhoneNumber(String number) {
    phoneNumber.value = number;
  }

  // Request OTP
  Future<void> loginWithPhone() async {
    isLoading.value = true;
    await _auth.verifyPhoneNumber(
      phoneNumber: '+62${phoneNumber.value}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolve on Android devices
        await _auth.signInWithCredential(credential);
        Get.snackbar('Success', 'Logged in successfully!');
      },
      verificationFailed: (FirebaseAuthException e) {
        isLoading.value = false;
        Get.snackbar('Error', e.message ?? 'Verification failed.');
      },
      codeSent: (String verId, int? resendToken) {
        verificationId.value = verId;
        isLoading.value = false;
        Get.toNamed('/otp'); // Navigate to OTP screen
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId.value = verId;
      },
    );
  }

  // Verify OTP
  Future<void> verifyOTP(String otp) async {
    isLoading.value = true;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      Get.snackbar('Success', 'Logged in successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP.');
    } finally {
      isLoading.value = false;
    }
  }
}
