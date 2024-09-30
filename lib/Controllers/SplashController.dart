import 'package:get/get.dart';
import 'package:FFinance/View/halaman_utama.dart'; // Import HalamanUtama

class SplashController extends GetxController {
  void navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(() => HalamanUtama()); // Navigate to HalamanUtama
    });
  }
}
