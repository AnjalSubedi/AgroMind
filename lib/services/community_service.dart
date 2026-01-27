import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post_model.dart';
import 'package:uuid/uuid.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Get Posts Stream
  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PostModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Create Post
  Future<void> createPost(String content, File? image) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // Fetch user details for name (optional, or use standard auth name)
    String userName = user.displayName ?? "Farmer";
    // Check if we have a user doc (better source of truth)
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      userName = userDoc.data()?['name'] ?? userName;
    }

    String? imageUrl;

    if (image != null) {
      // Upload image
      try {
        final ref = _storage
            .ref()
            .child('post_images')
            .child('${_uuid.v4()}.jpg');

        print("DEBUG: Starting image upload to ${ref.fullPath}");
        final taskSnapshot = await ref.putFile(image);

        if (taskSnapshot.state == TaskState.success) {
          print("DEBUG: Upload success, getting URL...");
          imageUrl = await ref.getDownloadURL();
          print("DEBUG: Got URL: $imageUrl");
        } else {
          print("ERROR: Upload failed with state: ${taskSnapshot.state}");
          throw Exception(
            "Image upload failed with state: ${taskSnapshot.state}",
          );
        }
      } catch (e) {
        print("ERROR: Failed to upload image: $e");
        rethrow; // Re-throw to show snackbar
      }
    }

    final post = PostModel(
      id: '', // Will be set by Firestore doc ID or ignored
      userId: user.uid,
      userName: userName,
      userImage: user.photoURL ?? '',
      content: content,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      likes: [],
      commentsCount: 0,
    );

    await _firestore.collection('posts').add(post.toMap());
  }

  // Toggle Like
  Future<void> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final postRef = _firestore.collection('posts').doc(postId);
    final doc = await postRef.get();

    if (doc.exists) {
      final post = PostModel.fromMap(doc.data()!, doc.id);
      final likes = List<String>.from(post.likes);

      if (likes.contains(user.uid)) {
        likes.remove(user.uid);
      } else {
        likes.add(user.uid);
      }

      await postRef.update({'likes': likes});
    }
  }
}
