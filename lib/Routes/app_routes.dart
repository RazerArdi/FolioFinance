import 'package:FFinance/View/Community.dart';
import 'package:FFinance/View/Explore.dart';
import 'package:FFinance/View/MainPage.dart';
import 'package:FFinance/View/Notification.dart';
import 'package:get/get.dart';
import 'package:FFinance/View/SplashScreen.dart';
import 'package:FFinance/View/Market.dart';
import 'package:FFinance/View/FirstLogORRegister.dart';
import 'package:FFinance/View/OTPScreen.dart';
import 'package:FFinance/View/FirstLogORRegister.dart';
import 'package:FFinance/View/login.dart';
import 'package:FFinance/View/Register.dart';

class AppRoutes {
  static const String splashScreen = '/splash';
  static const String home = '/home';
  static const String market = '/market';
  static const String community = '/community';
  static const String explore = '/explore';
  static const String notifications = '/notifications';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String FirstLogORRegisterROUTE = '/FirstLogORRegister';

  static final routes = [
    GetPage(name: splashScreen, page: () => const AnimatedSplashScreenPage()),
    GetPage(name: FirstLogORRegisterROUTE, page: () => const FirstLogORRegister()),
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: register, page: () => DaftarPage()),
    GetPage(name: home, page: () => const MainPage()),
    GetPage(name: market, page: () => const Market()),
    GetPage(name: community, page: () => const Community()),
    GetPage(name: explore, page: () => const Explore()),
    GetPage(name: notifications, page: () => const Notification()),
    GetPage(name: login, page: () => const FirstLogORRegister()),
    GetPage(name: otp, page: () => OTPScreen()),
  ];
}
