import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_keys.dart';

class CohereService {
  final String _baseUrl = 'https://api.cohere.ai/v1/chat';

  Future<String> refineText(String input) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${ApiKeys.cohereApiKey}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "message":
              "Refine this agricultural symptom description into a clear, concise query for a disease diagnosis system: \"$input\"",
          "model": "command-r-08-2024",
          "temperature": 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? "Could not refine text.";
      } else {
        throw Exception(
          "Cohere API Error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Failed to connect to Cohere: $e");
    }
  }

  Future<String> translateText(String input, String targetLanguage) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${ApiKeys.cohereApiKey}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "message":
              "Translate the following text to $targetLanguage. Only return the translated text, nothing else: \"$input\"",
          "model": "command-r-08-2024",
          "temperature": 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? "Could not translate text.";
      } else {
        throw Exception(
          "Cohere API Error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Failed to connect to Cohere: $e");
    }
  }

  Future<String> generateDailyTip(
    String weatherDescription,
    String cropName,
    String language,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${ApiKeys.cohereApiKey}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "message":
              "Generate a short, practical farming tip for a farmer growing $cropName in weather: $weatherDescription. Language: $language. Keep it under 20 words.",
          "model": "command-r-08-2024",
          "temperature": 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? "Could not generate tip.";
      } else {
        throw Exception(
          "Cohere API Error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Failed to connect to Cohere: $e");
    }
  }
}
