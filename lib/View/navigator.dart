import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/main_controller.dart';

class TopNavigator extends StatelessWidget implements PreferredSizeWidget {
  const TopNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());
    controller.loadProfileImage();

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
            return controller.profileImageUrl.value.isNotEmpty
                ? CircleAvatar(
              backgroundImage: NetworkImage(controller.profileImageUrl.value),
            )
                : controller.pickedImage.value != null
                ? CircleAvatar(
              backgroundImage: FileImage(File(controller.pickedImage.value!.path)),
            )
                : const Icon(Icons.person_outline);
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
          title: const Text('Pilih Sumber Gambar'),
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
    final MainController controller = Get.find();

    return Obx(() => BottomNavigationBar(
      currentIndex: controller.selectedIndex.value,
      onTap: (index) {
        controller.onTabChanged(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6750A4),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Watchlist'),
        const BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Markets'),
        const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
        const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        const BottomNavigationBarItem(icon: Icon(Icons.policy_rounded), label: 'Porto'),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Music') // Perbaikan di sini
      ],
    ));
  }
}