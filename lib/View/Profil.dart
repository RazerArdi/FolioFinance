  import 'package:FFinance/widget/VideoPlayerWidget.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
  import 'dart:io';

  import 'package:FFinance/Controllers/ProfileController.dart';
  import 'package:FFinance/widget/speech_service.dart';

  class Profil extends StatelessWidget {
    final ProfileController controller = Get.put(ProfileController());
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final SpeechService _speechService = SpeechService();

    @override
    Widget build(BuildContext context) {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        return const Center(child: Text('User not authenticated'));
      }

      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: Text('@${currentUser.displayName ?? currentUser.email}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: controller.logout,
              ),
            ],
            bottom: TabBar(
              onTap: controller.changeTab,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Posts'),
                Tab(text: 'Posts & Replies'),
                Tab(text: 'Liked'),
              ],
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  controller.pickImageOrVideo(context);
                },
                child: Obx(() {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: controller.profileImage.value != null
                            ? FileImage(controller.profileImage.value!)
                            : null,
                        backgroundColor: Colors.grey[200],
                        child: controller.profileImage.value == null
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                      if (controller.profileImage.value != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.red[400]),
                            onPressed: controller.removeImage,
                          ),
                        ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(
                currentUser.displayName ?? 'Anonymous',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '@${currentUser.displayName ?? currentUser.email}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  switch (controller.selectedTab.value) {
                    case 0:
                      return _buildPostsList();
                    case 1:
                      return _buildRepliesList(); // Ganti dengan fungsi untuk menampilkan replies
                    case 2:
                      return _buildLikedPostsList(); // Ganti dengan fungsi untuk menampilkan liked posts
                    default:
                      return Container();
                  }
                }),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showPostDialog(context);
            },
            heroTag: 'uniqueTagForFAB',
            child: const Icon(Icons.edit),
          ),
        ),
      );
    }

    Widget _buildPostsList() {
      return Obx(() {
        if (controller.posts.isEmpty) {
          return const Center(
            child: Text(
              'No posts yet',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            final timestamp = post['timestamp'] as Timestamp;
            final dateTime = timestamp.toDate();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      post['content'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${post['username']} - ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditPostDialog(context, index, post['content']);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, index);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (post['mediaUrl'] != null && post['mediaUrl'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: post['contentType'] == 'video'
                          ? VideoPlayerWidget(videoUrl: post['mediaUrl'])
                          : Image.file(File(post['mediaUrl'])),
                    ),
                ],
              ),
            );
          },
        );
      });
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
  }