import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/main_controller.dart';

class TopNavigator extends StatelessWidget implements PreferredSizeWidget {
  const TopNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find(); // Move this line here

    return AppBar(
      title: const Text('Folio Finance'),
      backgroundColor: const Color(0xFF16329F),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
        IconButton(
          onPressed: () => _showImageSourceDialog(context),
          icon: Obx(() {
            return controller.pickedImage.value == null
                ? const Icon(Icons.person_outline)
                : CircleAvatar(
              backgroundImage: Image.file(
                File(controller.pickedImage.value!.path),
              ).image,
            );
          }),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('TESTING'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  final MainController controller = Get.find();
                  controller.pickImageFromGallery();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  final MainController controller = Get.find();
                  controller.pickImageFromCamera();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Hapus Foto'),
                onTap: () {
                  final MainController controller = Get.find();
                  controller.clearImage();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


class BottomNavigator extends StatelessWidget {
  const BottomNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find(); // Move this line here

    return Obx(() => BottomNavigationBar(
      currentIndex: controller.selectedIndex.value,
      onTap: (index) {
        controller.onTabChanged(index); // Update the selected index
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6750A4),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Watchlist'),
        BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Markets'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.policy_rounded), label: 'Porto'),
      ],
    ));
  }
}