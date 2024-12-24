import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;
  var pickedImage = Rxn<XFile>();
  var profileImageUrl = ''.obs;
  var portfolioValue = 2331201.0.obs;
  var returnValue = 345406.0.obs;
  var returnPercentage = 17.39.obs;

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedImage.value = XFile(pickedFile.path);
      await _cacheImage(pickedFile.path);
      await _uploadImage(File(pickedFile.path));
    }
  }

  void onTabChanged(int index) {
    selectedIndex.value = index;
  }

  Future<void> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      pickedImage.value = XFile(pickedFile.path);
      await _cacheImage(pickedFile.path);
      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _cacheImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cachedImagePath', path);
  }

  Future<String?> _getCachedImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cachedImagePath');
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      // Upload to Firebase Storage
      final ref = _storage.ref().child('fotoprofil/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save URL to Firestore
      await _firestore.collection('fotoprofil').doc('profile').set({'url': downloadUrl});

      // Update profileImageUrl
      profileImageUrl.value = downloadUrl;

      // Clear cached image after successful upload
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('cachedImagePath');
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
    }
  }

  Future<void> loadProfileImage() async {
    try {
      // Check Firestore for existing profile image
      final doc = await _firestore.collection('fotoprofil').doc('profile').get();
      if (doc.exists) {
        profileImageUrl.value = doc['url'];
      } else {
        // If no image in Firestore, check local cache
        final cachedImagePath = await _getCachedImage();
        if (cachedImagePath != null) {
          pickedImage.value = XFile(cachedImagePath);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile image: $e');
    }
  }

  void clearImage() async {
    pickedImage.value = null;
    profileImageUrl.value = '';
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('cachedImagePath');
  }
}

