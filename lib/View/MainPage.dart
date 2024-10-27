import 'package:FFinance/View/navigator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/main_controller.dart';
import 'package:FFinance/View/Community.dart';
import 'package:FFinance/View/Explore.dart';
import 'package:FFinance/View/Market.dart';
import 'package:FFinance/View/halaman_utama.dart';

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
            // Add more pages as necessary
          ],
        );
      }),
      bottomNavigationBar: const BottomNavigator(),
    );
  }
}
