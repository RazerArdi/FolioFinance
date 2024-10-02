import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/main_controller.dart';

class TopNavigator extends StatelessWidget implements PreferredSizeWidget {
  final MainController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Folio Finance'),
      backgroundColor: Color(0xFF16329F),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none),
        ),
        IconButton(
          onPressed: () => _showImageSourceDialog(context),
          icon: Obx(() {
            return controller.pickedImage.value == null
                ? Icon(Icons.person_outline)
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
          title: Text('TESTING'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeri'),
                onTap: () {
                  controller.pickImageFromGallery();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Kamera'),
                onTap: () {
                  controller.pickImageFromCamera();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever),
                title: Text('Hapus Foto'),
                onTap: () {
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
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class BottomNavigator extends StatelessWidget {
  final MainController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => BottomNavigationBar(
      currentIndex: controller.selectedIndex.value,
      onTap: controller.onTabChanged,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFF6750A4),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Watchlist'),
        BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Markets'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
      ],
    ));
  }
}
