import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionResult {
  final String label;
  final double confidence;
  final Map<String, double>? probabilities;

  PredictionResult({
    required this.label,
    required this.confidence,
    this.probabilities,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    // Handle cases where 'class' might be missing or different types
    final label =
        json['class'] as String? ?? json['label'] as String? ?? 'Unknown';
    final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.0;

    Map<String, double>? probabilities;
    if (json['probabilities'] != null) {
      probabilities = {};
      (json['probabilities'] as Map<String, dynamic>).forEach((key, value) {
        probabilities![key] = (value as num).toDouble();
      });
    }

    return PredictionResult(
      label: label,
      confidence: confidence,
      probabilities: probabilities,
    );
  }
}

class ApiService {
  final String baseUrl;

  // Default to local machine IP for physical device testing
  // Use 10.0.2.2 for Android Emulator, or your LAN IP for physical device
  // Production Server (Render)
  // ApiService({this.baseUrl = 'https://twelve-kings-smile.loca.lt'});
  ApiService({this.baseUrl = 'https://testing-woqr.onrender.com'});

  Future<PredictionResult> predictTomato(File imageFile) async {
    return _predict('/predict/tomato', imageFile);
  }

  Future<PredictionResult> predictPotato(File imageFile) async {
    return _predict('/predict/potato', imageFile);
  }

  Future<PredictionResult> predictRice(File imageFile) async {
    return _predict('/predict/rice', imageFile);
  }

  Future<Map<String, dynamic>> diagnoseText(String text) async {
    final uri = Uri.parse('$baseUrl/diagnose-text');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to diagnose text: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  Future<Map<String, dynamic>> diagnoseAudio(String filePath) async {
    final uri = Uri.parse('$baseUrl/diagnose-audio');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to diagnose audio: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  Future<PredictionResult> _predict(String endpoint, File imageFile) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return PredictionResult.fromJson(jsonResponse);
      } else {
        throw Exception(
          'Failed to predict: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
