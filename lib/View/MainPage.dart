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

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController()); // Move this line here

    return Scaffold(
      appBar: const TopNavigator(),
      body: Obx(() {
        return IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            HalamanUtama(),
            const Market(),
            const Community(),
            const Explore(),
            const Porto(),
            Profil(),
          ],
        );
      }),
      bottomNavigationBar: const BottomNavigator(),
    );
  }
}
