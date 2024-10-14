import 'package:FFinance/View/Community.dart';
import 'package:FFinance/View/Explore.dart';
import 'package:FFinance/View/MainPage.dart';
import 'package:FFinance/View/Notification.dart';
import 'package:get/get.dart';
import 'package:FFinance/View/SplashScreen.dart';
import 'package:FFinance/View/halaman_utama.dart';
import 'package:FFinance/View/Market.dart';
import 'package:FFinance/View/Community.dart';

class AppRoutes {
  static const String splashScreen = '/splash';
  static const String home = '/home';
  static const String market = '/market';
  static const String community = '/community';
  static const String explore = '/explore';
  static const String notifications = '/notifications';

  static final routes = [
    GetPage(name: splashScreen, page: () => AnimatedSplashScreenPage()),
    GetPage(name: home, page: () => MainPage()),
    GetPage(name: market, page: () => Market()),
    GetPage(name: community, page: () => Community()),
    GetPage(name: explore, page: () => Explore()),
    GetPage(name: notifications, page: () => Notification()),
  ];
}
