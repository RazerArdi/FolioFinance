import 'package:get/get.dart';
import 'package:FFinance/View/SplashScreen.dart';
import 'package:FFinance/View/halaman_utama.dart';

class AppRoutes {
  // Define route names
  static const String splashScreen = '/splash';
  static const String home = '/home';

  // Define routes
  static final routes = [
    GetPage(name: splashScreen, page: () => AnimatedSplashScreenPage()),
    GetPage(name: home, page: () => HalamanUtama()),
  ];
}
