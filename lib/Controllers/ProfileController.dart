import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController postController = TextEditingController();
  final RxInt selectedTab = 0.obs;
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs; // URL gambar profil

  final ImagePicker _picker = ImagePicker();

  Stream<QuerySnapshot> get userPostsStream => _firestore
      .collection('posts')
      .where('userId', isEqualTo: '@SLRAZER')
      .orderBy('timestamp', descending: true)
      .snapshots();

  Future<void> addPost(String content, [String? postId]) async {
    try {
      if (postId == null) {
        await _firestore.collection('posts').add({
          'content': content,
          'timestamp': Timestamp.now(),
          'userId': '@SLRAZER',
          'profileImage': profileImageUrl.value, // Simpan URL gambar profil
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'content': content,
          'profileImage': profileImageUrl.value, // Update URL gambar profil jika ada
        });
      }
      postController.clear();
    } catch (e) {
      print('Error creating/updating post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
      await uploadProfileImage(); // Meng-upload gambar setelah dipilih
    }
  }

  Future<void> uploadProfileImage() async {
    if (profileImage.value == null) return;
    try {
      // Mendapatkan referensi untuk menyimpan gambar di Firebase Storage
      final ref = _storage.ref().child('profile_images/${_auth.currentUser!.uid}.jpg');
      await ref.putFile(profileImage.value!); // Meng-upload gambar
      profileImageUrl.value = await ref.getDownloadURL(); // Mendapatkan URL gambar
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void removeImage() {
    profileImage.value = null;
    profileImageUrl.value = ''; // Menghapus URL gambar
  }

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed('/FirstLogORRegister');
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
