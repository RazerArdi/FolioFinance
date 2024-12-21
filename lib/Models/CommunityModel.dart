import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityModel {
  final String id;
  final String userId;
  final String username;
  final String content;
  final String time;
  final int likes;
  final int comments;
  final int shares;
  final String sentiment;
  final String? photoUrl;
  late final List<CommentModel> commentList;
  bool isLikedByCurrentUser;  // Added to track if the current user has liked the post

  CommunityModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.time,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.sentiment,
    this.photoUrl,
    this.commentList = const [],
    this.isLikedByCurrentUser = false,  // Default is false
  });

  static Future<CommunityModel> fromFirestore(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    var commentList = <CommentModel>[];
    var commentSnapshot = await doc.reference.collection('comments').get();
    for (var commentDoc in commentSnapshot.docs) {
      commentList.add(CommentModel.fromFirestore(commentDoc));
    }

    // Determine if the current user has liked the post
    bool isLikedByCurrentUser = false;
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var likesSnapshot = await doc.reference.collection('likes').doc(currentUser.uid).get();
      isLikedByCurrentUser = likesSnapshot.exists;
    }

    return CommunityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      content: data['content'] ?? '',
      time: data['time'] ?? DateTime.now().toString(),
      likes: (data['likes'] ?? 0).toInt(),
      comments: (data['comments'] ?? 0).toInt(),
      shares: (data['shares'] ?? 0).toInt(),
      sentiment: data['sentiment'] ?? 'Neutral',
      photoUrl: data['photoUrl'],
      commentList: commentList,
      isLikedByCurrentUser: isLikedByCurrentUser,  // Set isLikedByCurrentUser
    );
  }

  // Make the method async
  static Future<CommunityModel> fromFirestore1(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    // Fetch comments asynchronously as a subcollection
    var commentList = <CommentModel>[];
    var commentSnapshot = await doc.reference.collection('comments').get();
    for (var commentDoc in commentSnapshot.docs) {
      commentList.add(CommentModel.fromFirestore(commentDoc));
    }

    return CommunityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      content: data['content'] ?? '',
      time: data['time'] ?? DateTime.now().toString(),
      likes: (data['likes'] ?? 0).toInt(),
      comments: (data['comments'] ?? 0).toInt(),
      shares: (data['shares'] ?? 0).toInt(),
      sentiment: data['sentiment'] ?? 'Neutral',
      photoUrl: data['photoUrl'],
      commentList: commentList, // Set the commentList after fetching comments
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'content': content,
      'time': time,
      'likes': likes,
      'comments': comments,
      'sentiment': sentiment,
      'photoUrl': photoUrl,
    };
  }
}

class CommentModel {
  final String id;
  final String userId;
  final String username;
  final String content;
  final String time;
  final String? photoUrl;

  CommentModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.time,
    this.photoUrl,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      content: data['content'] ?? '',
      time: data['time'] ?? DateTime.now().toString(),
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'content': content,
      'time': time,
      'photoUrl': photoUrl,
    };
  }
}
