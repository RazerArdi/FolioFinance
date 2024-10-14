import 'package:FFinance/View/navigator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/main_controller.dart';
import 'package:FFinance/View/Community.dart';
import 'package:FFinance/View/Explore.dart';
import 'package:FFinance/View/Market.dart';
import 'package:FFinance/View/halaman_utama.dart';

class MainPage extends StatelessWidget {
  final MainController controller = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigator(),
      body: Obx(() {
        return IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            HalamanUtama(),
            Market(),
            Community(),
            Explore(),
            // Add more pages as necessary
          ],
        );
      }),
      bottomNavigationBar: BottomNavigator(),
    );
  }
}
