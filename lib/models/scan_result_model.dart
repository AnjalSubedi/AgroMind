import 'package:cloud_firestore/cloud_firestore.dart';

class ScanResultModel {
  final String id;
  final String userId;
  final String cropName;
  final String diseaseName;
  final double confidence;
  final String imageUrl;
  final DateTime timestamp;
  final String description; // Short description or treatment summary

  ScanResultModel({
    required this.id,
    required this.userId,
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
    required this.imageUrl,
    required this.timestamp,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cropName': cropName,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
    };
  }

  factory ScanResultModel.fromMap(Map<String, dynamic> map, String docId) {
    return ScanResultModel(
      id: docId,
      userId: map['userId'] ?? '',
      cropName: map['cropName'] ?? 'Unknown',
      diseaseName: map['diseaseName'] ?? 'Unknown',
      confidence: map['confidence']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      description: map['description'] ?? '',
    );
  }
}
