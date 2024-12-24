import 'package:FFinance/View/Porto.dart';
import 'package:FFinance/View/navigator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/main_controller.dart';
import 'package:FFinance/View/Community.dart';
import 'package:FFinance/View/Explore.dart';
import 'package:FFinance/View/Market.dart';
import 'package:FFinance/View/halaman_utama.dart';
import 'package:FFinance/View/Profil.dart';
import 'package:FFinance/View/Music.dart';
import 'package:FFinance/View/navigator.dart';
import 'package:FFinance/View/navigator.dart' as navigator_view;


class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());

    return Scaffold(
      appBar: const navigator_view.TopNavigator(),
      body: Obx(() {
        return IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            HalamanUtama(),
            const Market(),
            const Community(),
            Explore(),
            const Porto(),
            Profil(),
            MusicPage(),
          ],
        );
      }),
      bottomNavigationBar: const BottomNavigator(),
    );
  }
}
