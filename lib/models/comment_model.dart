import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;
  final bool isVerified;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isVerified': isVerified,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map, String docId) {
    return CommentModel(
      id: docId,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isVerified: map['isVerified'] ?? false,
    );
  }
}
