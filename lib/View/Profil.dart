import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:FFinance/Controllers/ProfileController.dart';
import 'package:FFinance/widget/speech_service.dart';
import 'package:FFinance/Controllers/ConnectivityController.dart';
import 'package:FFinance/widget/VideoPlayerWidget.dart';
import 'AsynchronousComputingHome/AsynchronousComputingHome.dart';

class Profil extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SpeechService _speechService = SpeechService();
  final ConnectivityController connectivityController = Get.put(ConnectivityController());

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (!connectivityController.isConnected.value) {
      return AsynchronousComputingHome();
    }

    if (currentUser == null) {
      return const Center(child: Text('User not authenticated'));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 10.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue[400]!, Colors.blue[600]!],
                    ),
                  ),
                ),
                title: Text(
                  '@${currentUser.displayName ?? currentUser.email}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _showLogoutConfirmationDialog(context),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: GestureDetector(
                      onTap: () => controller.pickImageOrVideo(context),
                      child: Obx(() {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: controller.profileImage.value != null
                                ? FileImage(controller.profileImage.value!)
                                : null,
                            backgroundColor: Colors.white,
                            child: controller.profileImage.value == null
                                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                  Text(
                    currentUser.displayName ?? 'Anonymous',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@${currentUser.displayName ?? currentUser.email}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TabBar(
                      onTap: controller.changeTab,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.blue,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'Posts'),
                        Tab(text: 'Replies'),
                        Tab(text: 'Liked'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  _buildPostsList(),
                  _buildRepliesList(),
                  _buildLikedPostsList(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showPostDialog(context),
          label: const Text('New Post'),
          icon: const Icon(Icons.edit),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                // Perform logout actions
                controller.logout();
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Methods for building lists of posts, replies, and liked posts...
  Widget _buildPostsList() {
    return Obx(() {
      if (controller.posts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No posts yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 80),
        itemCount: controller.posts.length,
        itemBuilder: (context, index) => _buildPostCard(controller.posts[index], index),
      );
    });
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    final timestamp = post['timestamp'] as Timestamp;
    final dateTime = timestamp.toDate();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: controller.profileImage.value != null
                          ? FileImage(controller.profileImage.value!)
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: controller.profileImage.value == null
                          ? const Icon(Icons.person, size: 20, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              Navigator.pop(context);
                              _showEditPostDialog(context, index, post['content']);
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: const Icon(Icons.delete, color: Colors.red),
                            title: const Text('Delete', style: TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              Navigator.pop(context);
                              _showDeleteConfirmationDialog(context, index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post['content'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          if (post['mediaUrl'] != null && post['mediaUrl'].isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: post['contentType'] == 'video'
                  ? VideoPlayerWidget(videoUrl: post['mediaUrl'])
                  : Image.file(
                File(post['mediaUrl']),
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  void _showPostDialog(BuildContext context) {
    controller.postController.clear();
    controller.postMediaFile.value = null;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller.postController,
                  decoration: const InputDecoration(hintText: 'What\'s on your mind?'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    _speechService.speechToText();
                  },
                  icon: const Icon(Icons.mic),
                  label: const Text('Speech to Text'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await controller.pickImageOrVideo(context);
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Add Image/Video'),
                ),
                Obx(() {
                  if (controller.postMediaFile.value != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: controller.isVideo.value
                          ? VideoPlayerWidget(videoUrl: controller.postMediaFile.value!.path)
                          : GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Image.file(
                                  controller.postMediaFile.value!,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          );
                        },
                        child: Image.file(
                          controller.postMediaFile.value!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.postController.text.isNotEmpty ||
                    controller.postMediaFile.value != null) {
                  controller.addPost(controller.postController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int postIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                controller.deletePost(postIndex);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPostDialog(BuildContext context, int postIndex, String currentContent) {
    final TextEditingController editController = TextEditingController(text: currentContent);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: 'Edit your post'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newContent = editController.text.trim();
                if (newContent.isNotEmpty) {
                  controller.editPost(postIndex, newContent);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  // Fungsi untuk menampilkan replies (Anda perlu mengimplementasikannya)
  Widget _buildRepliesList() {
    return const Center(
      child: Text(
        'No replies yet',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  // Fungsi untuk menampilkan liked posts (Anda perlu mengimplementasikannya)
  Widget _buildLikedPostsList() {
    return const Center(
      child: Text(
        'No liked posts yet',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
