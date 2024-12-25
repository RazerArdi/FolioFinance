import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/CommunityController.dart';
import 'package:FFinance/Models/CommunityModel.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityController communityController = Get.put(CommunityController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  String getInitial(String username) {
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Latest'),
            Tab(text: 'Trending'),
            Tab(text: 'Popular'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildPostList(),
          buildPostList(),
          buildPostList(),
        ],
      ),
      // Test button for creating a post
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewPostDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNewPostDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    String sentiment = 'Neutral';  // Default sentiment

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a New Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Post Content',
                  hintText: 'Enter the content of your post',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: sentiment,
                onChanged: (String? newValue) {
                  setState(() {
                    sentiment = newValue!;
                  });
                },
                items: <String>['Bullish', 'Neutral', 'Bearish']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String content = contentController.text.trim();
                if (content.isNotEmpty) {
                  communityController.uploadPost(content, sentiment);
                  Navigator.of(context).pop();  // Close the dialog after posting
                } else {
                  // Show an error message if content is empty
                  Get.snackbar('Error', 'Please enter content for the post');
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  Widget buildPostList() {
    return GetX<CommunityController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${controller.error.value}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchPosts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("No posts available."),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchPosts(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchPosts(),
          child: ListView.builder(
            itemCount: controller.posts.length,
            itemBuilder: (context, index) {
              final post = controller.posts[index];
              return buildPostCard(post);
            },
          ),
        );
      },
    );
  }
  Widget buildPostCard(CommunityModel post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage: post.photoUrl != null
                        ? NetworkImage(post.photoUrl!)
                        : null,
                    radius: 24,
                    child: post.photoUrl == null
                        ? Text(getInitial(post.username), style: TextStyle(color: Colors.white))
                        : null,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(post.time, style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(post.sentiment, style: TextStyle(color: Colors.white)),
                    backgroundColor: post.sentiment.toLowerCase() == 'bullish' ? Colors.green : Colors.red,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(post.content, style: TextStyle(fontSize: 14)),
              SizedBox(height: 10),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Comment count
                  Row(
                    children: [
                      Icon(Icons.comment, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(post.comments.toString()),
                    ],
                  ),
                  // Like button
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.thumb_up,
                          size: 18,
                          color: post.isLikedByCurrentUser ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () {
                          communityController.likePost(post.id);
                        },
                      ),
                      SizedBox(width: 4),
                      Text(post.likes.toString()),
                    ],
                  ),
                  // Share button
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.share, size: 18, color: Colors.grey),
                        onPressed: () {
                          // Invoke the sharePost method with the necessary parameters
                          communityController.sharePost(post.id, post.content);
                        },
                      ),
                      SizedBox(width: 4),
                      Text(post.shares.toString()),
                    ],
                  ),
                ],
              ),
              // Comments Section
              ListView.builder(
                shrinkWrap: true,
                itemCount: post.commentList.length,
                itemBuilder: (context, index) {
                  final comment = post.commentList[index];
                  return ListTile(
                    title: Text(comment.username),
                    subtitle: Text(comment.content),
                    trailing: Text(comment.time),
                  );
                },
              ),
              // Add comment
              TextField(
                decoration: InputDecoration(hintText: 'Add a comment...'),
                onSubmitted: (value) {
                  communityController.uploadComment(post.id, value);
                  communityController.incrementCommentCount(post.id); // Increment the comment count
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}