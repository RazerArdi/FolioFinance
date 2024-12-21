import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController postController = TextEditingController();

  final RxInt selectedTab = 0.obs;
  final RxList<Map<String, dynamic>> posts = RxList<Map<String, dynamic>>([]);
  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<File?> postMediaFile = Rx<File?>(null);
  final RxBool isVideo = false.obs;
  final GetStorage _getStorage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;

        final querySnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: userId)
            .get();

        posts.value = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'postId': doc.id,
            'content': data['content'],
            'timestamp': data['timestamp'],
            'username': data['username'],
            'mediaUrl': data['mediaUrl'],
            'contentType': data['contentType'],
          };
        }).toList();
      }
    } catch (e) {
      print('Error loading posts from Firestore: $e');
      Get.snackbar('Error', 'Gagal memuat postingan.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> savePosts() async {
    await _getStorage.write('posts', posts);
  }

  void addPost(String content) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;
        final dateTime = DateTime.now(); // Objek DateTime
        final timestamp = Timestamp.fromDate(dateTime);

        final newPostRef = await FirebaseFirestore.instance.collection('posts').add({
          'userId': userId,
          'content': content,
          'timestamp': timestamp,
          'username': currentUser.displayName ?? 'Anonymous',
          'mediaUrl': postMediaFile.value != null ? postMediaFile.value!.path : '',
          'contentType': isVideo.value ? 'video' : 'image',
        });

        print('Post added to Firestore');
        final newPost = {
          'postId': newPostRef.id,
          'content': content,
          'timestamp': timestamp,
          'username': currentUser.displayName ?? 'Anonymous',
          'mediaUrl': postMediaFile.value != null ? postMediaFile.value!.path : '',
          'contentType': isVideo.value ? 'video' : 'image',
        };
        posts.add(newPost);
        savePosts();
        postController.clear();
        postMediaFile.value = null;
      }
    } catch (e) {
      print('Error adding post to Firestore: $e');
      Get.snackbar('Error', 'Gagal menambahkan postingan.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void deletePost(int postIndex) async {
    try {
      String postId = posts[postIndex]['postId'];
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

      posts.removeAt(postIndex);
      savePosts();
    } catch (e) {
      print('Error deleting post: $e');
      Get.snackbar('Error', 'Gagal menghapus postingan.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void editPost(int postIndex, String newContent) async {
    try {
      String postId = posts[postIndex]['postId'];
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update({'content': newContent});

      posts[postIndex]['content'] = newContent;
      savePosts();
    } catch (e) {
      print('Error editing post: $e');
      Get.snackbar('Error', 'Gagal mengubah postingan.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickImageOrVideo(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.video_camera_back),
                title: Text('Take a Video'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickVideoFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImageOrVideoFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      postMediaFile.value = File(imageFile.path);
      isVideo.value = false;
    }
  }

  Future<void> _pickVideoFromCamera() async {
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      postMediaFile.value = File(pickedFile.path);
      isVideo.value = true;
    }
  }

  Future<void> _pickImageOrVideoFromGallery() async {
    PermissionStatus permission = await Permission.photos.status;
    if (permission != PermissionStatus.granted) {
      permission = await Permission.photos.request();
    }

    if (permission.isGranted) {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        postMediaFile.value = File(pickedFile.path);
        isVideo.value = false;
      } else {
        final XFile? videoFile = await _picker.pickVideo(source: ImageSource.gallery);
        if (videoFile != null) {
          postMediaFile.value = File(videoFile.path);
          isVideo.value = true;
        }
      }
    } else {
      print('Gallery permission denied');
    }
  }

  void removeImage() {
    profileImage.value = null;
  }

  void logout() async {
    Get.offAllNamed('/FirstLogORRegister');
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}