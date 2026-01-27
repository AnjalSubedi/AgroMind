import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import '../models/scan_result_model.dart';
import 'model_info_service.dart';
import 'api_service.dart';

class DiseaseDetectionService {
  final ModelInfoService _modelInfoService = ModelInfoService();

  Future<DiseaseDetectionResult> analyzeImage(
    File image,
    Locale locale,
    String cropType,
  ) async {
    // Check if the selected crop is Rice (supports English 'Rice' or Nepali 'धान')
    bool isRice =
        cropType.toLowerCase().contains('rice') || cropType.contains('धान');
    bool isTomato =
        cropType.toLowerCase().contains('tomato') ||
        cropType.contains('गोलभेडा');
    bool isPotato =
        cropType.toLowerCase().contains('potato') || cropType.contains('आलु');

    if (isRice) {
      return _analyzeRice(image, locale);
    } else if (isTomato) {
      return _analyzeTomato(image, locale);
    } else if (isPotato) {
      return _analyzePotato(image, locale);
    } else {
      return _simulateOtherCrops(cropType);
    }
  }

  Future<DiseaseDetectionResult> _analyzeRice(File image, Locale locale) async {
    try {
      // Load info for localization
      await _modelInfoService.loadModelInfo();
      // Use API instead of ONNX
      final ApiService apiService = ApiService();
      final result = await apiService.predictRice(image);

      String predictedClass = result.label;

      // Force "normal" to be the healthy state if it exists
      final isHealthy =
          predictedClass == 'normal' || predictedClass == 'healthy';

      final info = _modelInfoService.getDiseaseInfo(
        'rice',
        predictedClass,
        locale,
      );

      return DiseaseDetectionResult(
        diseaseId: predictedClass,
        diseaseName: info.name,
        confidence: result.confidence,
        description: info.description,
        treatment: info.treatment,
        citations: info.citations,
        severity: isHealthy ? "Low" : "High",
      );
    } catch (e) {
      debugPrint("Rice Analysis Error: $e");
      return _createErrorResult(e.toString());
    }
  }

  Future<DiseaseDetectionResult> _analyzeTomato(
    File image,
    Locale locale,
  ) async {
    try {
      await _modelInfoService.loadModelInfo();
      final ApiService apiService = ApiService();
      final result = await apiService.predictTomato(image);

      final isHealthy = result.label.toLowerCase().contains('healthy');

      final info = _modelInfoService.getDiseaseInfo(
        'tomato',
        result.label,
        locale,
      );

      return DiseaseDetectionResult(
        diseaseId: result.label,
        diseaseName: info.name,
        confidence: result.confidence,
        description: info.description,
        treatment: info.treatment,
        citations: info.citations,
        severity: isHealthy ? "Low" : "High",
      );
    } catch (e) {
      debugPrint("Tomato Analysis Error: $e");
      return _createErrorResult(e.toString());
    }
  }

  Future<DiseaseDetectionResult> _analyzePotato(
    File image,
    Locale locale,
  ) async {
    try {
      await _modelInfoService.loadModelInfo();
      final ApiService apiService = ApiService();
      final result = await apiService.predictPotato(image);

      final isHealthy = result.label.toLowerCase().contains('healthy');

      final info = _modelInfoService.getDiseaseInfo(
        'potato',
        result.label,
        locale,
      );

      return DiseaseDetectionResult(
        diseaseId: result.label,
        diseaseName: info.name,
        confidence: result.confidence,
        description: info.description,
        treatment: info.treatment,
        citations: info.citations,
        severity: isHealthy ? "Low" : "High",
      );
    } catch (e) {
      debugPrint("Potato Analysis Error: $e");
      return _createErrorResult(e.toString());
    }
  }

  DiseaseDetectionResult _createErrorResult(String error) {
    return DiseaseDetectionResult(
      diseaseId: 'error',
      diseaseName: "Analysis Failed",
      confidence: 0.0,
      description: "Could not analyze the image. $error",
      treatment: [],
      citations: [],
      severity: "Error",
    );
  }

  Future<DiseaseDetectionResult> _simulateOtherCrops(String cropType) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simple random simulation for other crops
    bool isHealthy = DateTime.now().second % 2 == 0;

    return DiseaseDetectionResult(
      diseaseId: isHealthy ? 'healthy' : 'simulated_disease',
      diseaseName: isHealthy
          ? "Healthy $cropType"
          : "Simulated $cropType Disease",
      confidence: 0.88,
      description: isHealthy
          ? "Your $cropType plant looks healthy."
          : "This is a simulated result for $cropType. Real model coming soon.",
      treatment: isHealthy
          ? ["Keep monitoring.", "Water regularly."]
          : ["Consult an expert.", "Isolate the plant."],
      citations: [],
      severity: isHealthy ? "Low" : "Medium",
    );
  }

  Future<void> saveScanResult({
    required String cropType,
    required DiseaseDetectionResult result,
    File? image,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String imageUrl = '';
      if (image != null) {
        // Firebase Storage is not initialized in the project, skipping upload.
        /*
        try {
          final ref = FirebaseStorage.instance
              .ref()
              .child('scan_images')
              .child(user.uid)
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

          debugPrint("Starting image upload to: ${ref.fullPath}");
          final TaskSnapshot snapshot = await ref.putFile(image);

          if (snapshot.state == TaskState.success) {
            debugPrint("Upload successful, fetching URL...");
            imageUrl = await ref.getDownloadURL();
            debugPrint("Image URL retrieved: $imageUrl");
          } else {
            debugPrint("Upload failed with state: ${snapshot.state}");
          }
        } catch (e) {
          debugPrint("Image upload/URL error: $e");
          // Proceed without image URL
        }
        */
        debugPrint("Skipping image upload (Storage not initialized)");
      }

      final scanResult = ScanResultModel(
        id: '', // Firestore will assign
        userId: user.uid,
        cropName: cropType,
        diseaseName: result.diseaseName,
        confidence: result.confidence,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        description: result.description,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .add(scanResult.toMap());
    } catch (e) {
      debugPrint("Failed to save scan result: $e");
    }
  }

  void dispose() {
    // _onnxService.dispose();
  }
}

class DiseaseDetectionResult {
  final String diseaseId;
  final String diseaseName;
  final double confidence;
  final String description;
  final List<String> treatment;
  final List<String> citations;
  final String severity;

  DiseaseDetectionResult({
    required this.diseaseId,
    required this.diseaseName,
    required this.confidence,
    required this.description,
    required this.treatment,
    this.citations = const [],
    required this.severity,
  });
}
