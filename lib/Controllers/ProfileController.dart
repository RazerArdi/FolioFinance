import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:math';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController postController = TextEditingController();
  final RxInt selectedTab = 0.obs;
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;
  final Rx<File?> postMediaFile = Rx<File?>(null);
  final RxString postMediaUrl = ''.obs;

  // Stream to get user posts
  Stream<QuerySnapshot> get userPostsStream => _firestore
      .collection('posts')
      .where('userId', isEqualTo: _auth.currentUser?.uid) // Adjust the condition for actual user
      .orderBy('timestamp', descending: true)
      .snapshots();

  @override
  void onInit() {
    super.onInit();
    requestPermissions(); // Request permissions at startup
    loadProfileImage(); // Load profile image if exists
  }

  // Request necessary permissions
  Future<void> requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();
    final locationStatus = await Permission.location.request();

    if (cameraStatus.isDenied || storageStatus.isDenied || locationStatus.isDenied) {
      print("One or more permissions were denied. Some features may not work as expected.");
    }
  }

  // Load profile image from Firebase Storage
  Future<void> loadProfileImage() async {
    try {
      final ref = _storage.ref().child('profile_images/${_auth.currentUser!.uid}.jpg');
      final url = await ref.getDownloadURL();
      profileImageUrl.value = url; // Update URL setelah berhasil mengambil gambar
    } catch (e) {
      print('No profile image found, showing default icon.');
      profileImageUrl.value = ''; // Gunakan gambar default jika tidak ada gambar
    }
  }


  // Add a post to Firestore with text content and optional media
  // Add a post to Firestore with text content and optional media
  Future<void> addPost(String content, [String? postId]) async {
    try {
      Position? location;
      if (await Permission.location.isGranted) {
        location = await Geolocator.getCurrentPosition();
      }

      // Upload media first if necessary
      String contentType = 'image'; // Default to 'image'
      if (postMediaFile.value != null) {
        await uploadPostMedia();  // Ensure media is uploaded and URL is set
        if (postMediaUrl.value.isEmpty) {
          await Future.delayed(Duration(seconds: 2));  // Wait for URL to be available
        }

        // Determine the content type (image or video)
        contentType = postMediaUrl.value.endsWith('.mp4') ? 'video' : 'image';
      }

      final postData = {
        'content': content,
        'timestamp': Timestamp.now(),
        'userId': _auth.currentUser?.uid ?? '',
        'profileImage': profileImageUrl.value,
        'mediaUrl': postMediaUrl.value.isEmpty ? null : postMediaUrl.value,
        'location': location != null
            ? {'lat': location.latitude, 'long': location.longitude}
            : null,
        'contentType': contentType,  // Add contentType to indicate whether it's a video or an image
      };

      if (postId == null) {
        // Add new post
        await _firestore.collection('posts').add(postData);
      } else {
        // Update existing post
        await _firestore.collection('posts').doc(postId).update(postData);
      }

      // Reset form after posting
      postController.clear();
      postMediaFile.value = null;
      postMediaUrl.value = '';
    } catch (e) {
      print('Error creating/updating post: $e');
    }
  }


  Future<void> uploadPostMedia() async {
    if (postMediaFile.value == null) {
      print("No media selected");
      return;
    }

    try {
      final ref = _storage.ref().child('posts_media/${_auth.currentUser!.uid}/${Timestamp.now().millisecondsSinceEpoch}');
      await ref.putFile(postMediaFile.value!);  // Upload file to Firebase Storage
      postMediaUrl.value = await ref.getDownloadURL();  // Get the download URL and store it

      // Log the URL to see if it's fetched correctly
      print("Media uploaded successfully. URL: ${postMediaUrl.value}");
    } catch (e) {
      print('Error uploading media: $e');
    }
  }




  // Delete a post from Firestore
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  // Show bottom sheet to pick image or video for a post
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


  // Pick an image from the camera
  Future<void> _pickImageFromCamera() async {
    if (await Permission.camera.isGranted) {
      final XFile? imageFile = await _picker.pickImage(source: ImageSource.camera);
      if (imageFile != null) {
        postMediaFile.value = File(imageFile.path);  // Save image file for post
        await uploadPostMedia();  // Upload the selected media
      }
    } else {
      print('Camera permission denied');
    }
  }

  // Pick a video from the camera
  Future<void> _pickVideoFromCamera() async {
    if (await Permission.camera.isGranted) {
      final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.camera);
      if (pickedFile != null) {
        postMediaFile.value = File(pickedFile.path);  // Save video file for post
        await uploadPostMedia();  // Upload the selected media
      }
    } else {
      print('Camera permission denied');
    }
  }

  Future<void> _pickImageOrVideoFromGallery() async {
    // Memastikan izin akses galeri diberikan
    PermissionStatus permission = await Permission.photos.status;

    if (permission != PermissionStatus.granted) {
      // Meminta izin jika belum diberikan
      permission = await Permission.photos.request();
    }

    if (permission.isGranted) {
      // Jika izin diberikan, pilih gambar atau video
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        postMediaFile.value = File(pickedFile.path);
        await uploadPostMedia();  // Upload media
      } else {
        final XFile? videoFile = await _picker.pickVideo(source: ImageSource.gallery);
        if (videoFile != null) {
          postMediaFile.value = File(videoFile.path);
          await uploadPostMedia();  // Upload video
        }
      }
    } else {
      // Tampilkan pesan jika izin ditolak
      print('Gallery permission denied');
    }
  }



  Future<void> uploadProfileImage() async {
    if (profileImage.value == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is not authenticated');
        return;
      }

      String fileName = 'profile_image.jpg';  // Ganti nama file jika perlu
      final ref = _storage.ref().child('profile_images/${user.uid}/$fileName');

      await ref.putFile(profileImage.value!);  // Upload file ke Firebase Storage
      profileImageUrl.value = await ref.getDownloadURL();  // Ambil URL setelah upload selesai

      print('Upload successful: ${profileImageUrl.value}');

      // Pastikan gambar profil di-load setelah upload selesai
      await loadProfileImage(); // Reload gambar profil
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // Remove profile image
  void removeImage() {
    profileImage.value = null;
    profileImageUrl.value = '';
  }

  // Log out the user
  void logout() async {
    await _auth.signOut();
    Get.offAllNamed('/FirstLogORRegister');
  }

  // Change the selected tab in the profile
  void changeTab(int index) {
    selectedTab.value = index;
  }

  // Generate a random suffix for username
  String generateUsername(String baseUsername) {
    final random = Random();
    final randomNumber = random.nextInt(1000000); // Random number
    return '@$baseUsername' + '_$randomNumber'; // Example: @username_123456
  }

  // Store the username in Firebase
  Future<void> storeUsername(String username) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid);
    await userDoc.set({
      'username': username,
    }, SetOptions(merge: true));
  }

}
