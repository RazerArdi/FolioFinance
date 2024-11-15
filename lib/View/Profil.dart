import 'package:FFinance/Controllers/ProfileController.dart';
import 'package:FFinance/widget/VideoPlayerWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting user details

class Profil extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  // Retrieve the current user's info from FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Get the current user's UID
    final currentUser = _auth.currentUser;

    // Ensure we have a valid user
    if (currentUser == null) {
      return const Center(child: Text('User not authenticated'));
    }

    // Fetch the username or any other user details from Firestore (if needed)
    final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

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
                controller.pickImageOrVideo(context); // Allow picking both image and video
              },
              child: Obx(() {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: controller.profileImageUrl.value.isNotEmpty
                          ? NetworkImage(controller.profileImageUrl.value)
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: controller.profileImageUrl.value.isEmpty
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
            // Fetch the user's name dynamically
            FutureBuilder<DocumentSnapshot>(
              future: userRef.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Error fetching user data');
                }

                // Safe access to Firestore data and handling null case
                final userData = snapshot.data!.data();
                if (userData == null || userData is! Map<String, dynamic>) {
                  return const Text('User data not available');
                }

                final username = userData['username'] ?? currentUser.displayName ?? 'Anonymous';

                return Column(
                  children: [
                    Text(
                      username,
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
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                switch (controller.selectedTab.value) {
                  case 0:
                    return _buildPostsList();
                  case 1:
                    return Center(child: Text('No replies yet'));
                  case 2:
                    return Center(child: Text('No liked posts'));
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
    return StreamBuilder<QuerySnapshot>(
      stream: controller.userPostsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No posts'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final content = doc['content'] ?? '';
            final timestamp = (doc['timestamp'] as Timestamp).toDate();
            final postId = doc.id;  // Get the post ID
            final data = doc.data() as Map<String, dynamic>?;
            final username = data != null && data.containsKey('username') ? data['username'] : 'Anonymous';
            final mediaUrl = data != null && data.containsKey('mediaUrl') ? data['mediaUrl'] : '';
            final contentType = data != null && data.containsKey('contentType') ? data['contentType'] : 'image'; // Default to 'image'

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(content),
                    subtitle: Text('$username - ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditPostDialog(context, postId, content);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, postId);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (mediaUrl != null && mediaUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: contentType == 'video'
                          ? VideoPlayerWidget(videoUrl: mediaUrl)  // Use VideoPlayerWidget for video
                          : Image.network(mediaUrl, fit: BoxFit.cover),  // Display image otherwise
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPostDialog(BuildContext context) {
    controller.postMediaFile.value = null; // Reset the selected media file
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TextField for content input
                TextField(
                  controller: controller.postController,
                  decoration: const InputDecoration(
                      hintText: 'What\'s on your mind?'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Correctly call the method to pick image/video
                    await controller.pickImageOrVideo(
                        context); // Show bottom sheet to pick media
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Add Image/Video'),
                ),
                // Using Obx to listen to changes in post media file/url
                Obx(() {
                  if (controller.postMediaFile.value != null) {
                    // Display either video or image based on selected media
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: controller.postMediaUrl.value.endsWith('.mp4')
                          ? VideoPlayerWidget(
                          videoUrl: controller.postMediaUrl.value) // Display video
                          : GestureDetector(
                        onTap: () {
                          // On tap, show full-screen image in new screen
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Image.file(
                                  controller.postMediaFile.value!,
                                  fit: BoxFit.contain, // Make sure image fits the screen
                                ),
                              );
                            },
                          );
                        },
                        child: Image.file(
                          controller.postMediaFile.value!,
                          width: 200, // Display a smaller version of the image
                          height: 200, // Control the size of the image
                          fit: BoxFit.cover, // Adjust the image's aspect ratio
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // If no media selected, show nothing
                }),
              ],
            ),
          ),
          actions: [
            // Cancel button to close the dialog
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            // Post button to submit the post
            TextButton(
              onPressed: () {
                // Only post if there's content or media
                if (controller.postController.text.isNotEmpty ||
                    controller.postMediaUrl.value.isNotEmpty) {
                  controller.addPost(controller.postController.text); // Add the post
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String postId) {
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
                await controller.deletePost(postId); // Delete the post
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPostDialog(BuildContext context, String postId, String currentContent) {
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
                  await controller.addPost(newContent, postId); // Update the post
                  Navigator.of(context).pop(); // Close the dialog
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