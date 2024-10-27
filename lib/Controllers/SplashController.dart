import 'package:get/get.dart';
import 'package:FFinance/View/FirstLogORRegister.dart';

class SplashController extends GetxController {
  void navigateToLogin() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(() => const FirstLogORRegister());
    });
  }
}
