import 'package:FFinance/View/MainPage.dart';
import 'package:get/get.dart';
import 'package:FFinance/View/halaman_utama.dart';

class SplashController extends GetxController {
  void navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(() => MainPage());
    });
  }
}
