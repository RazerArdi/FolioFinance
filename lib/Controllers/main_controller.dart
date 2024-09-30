import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;
  var portfolioValue = 2331201.0.obs;
  var returnValue = 345406.0.obs;
  var returnPercentage = 17.39.obs;
  var pickedImage = Rxn<XFile>();

  void onTabChanged(int index) {
    selectedIndex.value = index;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedImage.value = image;
    }
  }
}
