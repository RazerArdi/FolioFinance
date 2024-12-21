import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:FFinance/Models/CommunityModel.dart';

class CommunityController extends GetxController {
  var posts = <CommunityModel>[].obs; // Reactive list of posts
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = true.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts(); // Fetch posts when the controller is initialized
  }

  // Fetch posts from Firestore
  Future<void> fetchPosts() async {
    try {
      isLoading(true);
      error(''); // Clear previous error message
      var snapshot = await _firestore.collection('posts').orderBy('time', descending: true).get();
      var postsList = <CommunityModel>[];

      for (var doc in snapshot.docs) {
        // Fetch each post and await the comments asynchronously
        var post = await CommunityModel.fromFirestore1(doc);
        postsList.add(post);
      }

      posts.assignAll(postsList); // Update the reactive posts list
    } catch (e) {
      error('Failed to fetch posts: $e');
    } finally {
      isLoading(false); // Set loading to false after the fetch is complete
    }
  }

  // Fetch comments for a specific post
  Future<void> fetchComments(String postId) async {
    try {
      var snapshot = await _firestore.collection('posts').doc(postId).collection('comments').get();
      var commentList = snapshot.docs.map((doc) {
        return CommentModel.fromFirestore(doc);
      }).toList();

      // Find the post and update its comment list
      var postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        posts[postIndex].commentList = commentList; // Update the comment list of the post
        posts.refresh(); // Refresh the list to notify UI about the update
      }
    } catch (e) {
      error('Failed to fetch comments: $e');
    }
  }

  // Upload a new comment
  Future<void> uploadComment(String postId, String content) async {
    try {
      var user = _auth.currentUser;
      if (user != null) {
        final commentData = {
          'userId': user.uid,
          'username': user.displayName ?? 'Anonymous',
          'content': content,
          'time': DateTime.now().toString(),
          'photoUrl': user.photoURL,
        };

        // Add the comment to the specific post's subcollection
        await _firestore.collection('posts').doc(postId).collection('comments').add(commentData);

        // Refresh comments after uploading
        await fetchComments(postId);
      }
    } catch (e) {
      error('Failed to upload comment: $e');
    }
  }

  // Upload a new post
  Future<void> uploadPost(String content, String sentiment) async {
    try {
      var user = _auth.currentUser;
      if (user != null) {
        final postData = {
          'userId': user.uid,
          'username': user.displayName ?? 'Anonymous',
          'content': content,
          'time': DateTime.now().toString(),
          'likes': 0,
          'comments': 0,
          'shares': 0,
          'sentiment': sentiment,
          'photoUrl': user.photoURL,
        };

        // Add the post to the 'posts' collection
        var docRef = await _firestore.collection('posts').add(postData);

        // Refresh posts after uploading
        await fetchPosts();
      }
    } catch (e) {
      error('Error uploading post: $e');
    }
  }

  Future<void> likePost(String postId) async {
    try {
      var user = _auth.currentUser;
      if (user != null) {
        var postDoc = _firestore.collection('posts').doc(postId);

        // Check if the post is already liked by the current user
        var likeDoc = await postDoc.collection('likes').doc(user.uid).get();

        if (likeDoc.exists) {
          // User has already liked the post, so we "unlike" it
          await postDoc.update({
            'likes': FieldValue.increment(-1),
          });

          // Remove the like entry for this user
          await postDoc.collection('likes').doc(user.uid).delete();
        } else {
          // User hasn't liked the post, so we "like" it
          await postDoc.update({
            'likes': FieldValue.increment(1),
          });

          // Add a like entry for this user
          await postDoc.collection('likes').doc(user.uid).set({
            'userId': user.uid,
          });
        }

        // Refresh the post list to update UI
        await fetchPosts();
      }
    } catch (e) {
      error('Failed to like post: $e');
    }
  }


// Increment the comment count for a specific post
  Future<void> incrementCommentCount(String postId) async {
    try {
      var postDoc = _firestore.collection('posts').doc(postId);
      await postDoc.update({
        'comments': FieldValue.increment(1), // Increment comments by 1
      });
    } catch (e) {
      error('Failed to increment comment count: $e');
    }
  }

// Increment the share count for a specific post
  Future<void> sharePost(String postId) async {
    try {
      var postDoc = _firestore.collection('posts').doc(postId);
      await postDoc.update({
        'shares': FieldValue.increment(1), // Increment shares by 1
      });

      // Fetch updated post to refresh UI
      await fetchPosts();
    } catch (e) {
      error('Failed to share post: $e');
    }
  }
}
