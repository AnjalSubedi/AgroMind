import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final List<String> likes;
  final int commentsCount;
  final bool isVerified;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage = '',
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.likes = const [],
    this.commentsCount = 0,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'commentsCount': commentsCount,
      'isVerified': isVerified,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map, String docId) {
    return PostModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userImage: map['userImage'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(map['likes'] ?? []),
      commentsCount: map['commentsCount'] ?? 0,
      isVerified: map['isVerified'] ?? false,
    );
  }
}
