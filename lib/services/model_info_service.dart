import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiseaseInfo {
  final String name;
  final String description;
  final List<String> treatment;
  final List<String> citations;

  DiseaseInfo({
    required this.name,
    required this.description,
    required this.treatment,
    this.citations = const [],
  });
}

class ModelInfoService {
  Map<String, dynamic>? _diseaseData;

  Future<void> loadModelInfo() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/models/disease_data.json',
      );
      _diseaseData = json.decode(response);
    } catch (e) {
      debugPrint("Error loading model info: $e");
    }
  }

  DiseaseInfo getDiseaseInfo(String cropType, String className, Locale locale) {
    // Default fallback
    String name = className;
    String description =
        "Disease detected. Please consult an expert for verification.";
    List<String> treatment = [
      "Isolate the plant.",
      "Check for similar symptoms in nearby plants.",
    ];
    List<String> citations = [];

    if (_diseaseData != null) {
      // Normalize crop type key (tomato, potato, rice)
      String cropKey = cropType.toLowerCase();
      if (cropKey.contains('rice') || cropKey.contains('धान'))
        cropKey = 'rice';
      else if (cropKey.contains('tomato') || cropKey.contains('गोलभेडा'))
        cropKey = 'tomato';
      else if (cropKey.contains('potato') || cropKey.contains('आलु'))
        cropKey = 'potato';

      final cropInfo = _diseaseData![cropKey] as Map<String, dynamic>?;

      Map<String, dynamic>? info;

      // 1. Try Specific Crop Lookup
      if (cropInfo != null && cropInfo.containsKey(className)) {
        info = cropInfo[className];
      }
      // 2. Global Lookup (smart matching)
      else {
        // Normalize the class name we are looking for (remove space, underscore, lowercase)
        String cleanClass = className
            .toLowerCase()
            .replaceAll(' ', '')
            .replaceAll('_', '');

        for (var key in _diseaseData!.keys) {
          final subMap = _diseaseData![key] as Map<String, dynamic>;

          // Iterate all disease keys in this crop
          for (var diseaseKey in subMap.keys) {
            String cleanKey = diseaseKey
                .toLowerCase()
                .replaceAll(' ', '')
                .replaceAll('_', '');

            // Check for match (ignoring spaces/underscores/case)
            // Also check specific potato mapping (Potato___Early_blight vs Early Blight)
            // Use contains to catch "Potato___Early_blight" containing "earlyblight"
            if (cleanKey == cleanClass ||
                cleanKey.contains(cleanClass) ||
                cleanClass.contains(cleanKey)) {
              info = subMap[diseaseKey];
              break;
            }
          }
          if (info != null) break;
        }
      }

      if (info != null) {
        bool isNepali = locale.languageCode == 'ne';

        // Fetch name
        if (isNepali && info['name_ne'] != null) {
          name = info['name_ne'];
        } else {
          name = info['name'] ?? className;
        }

        // Fetch description
        if (isNepali && info['description_ne'] != null) {
          description = info['description_ne'];
        } else {
          description = info['description'] ?? description;
          // Ensure we don't use the fallback default if description is in JSON
          if (description ==
              "Disease detected. Please consult an expert for verification.") {
            // If JSON description was missing, we might still want to avoid generic if possible
            // but usually JSON has it.
          }
        }

        // Fetch treatment
        List<dynamic>? rawTreatment;
        if (isNepali && info['treatment_ne'] != null) {
          rawTreatment = info['treatment_ne'];
        } else {
          rawTreatment = info['treatment'];
        }

        if (rawTreatment != null) {
          treatment = List<String>.from(rawTreatment);
        }

        // Fetch citations
        if (info['citations'] != null) {
          citations = List<String>.from(info['citations']);
        }
      }
    }

    return DiseaseInfo(
      name: name,
      description: description,
      treatment: treatment,
      citations: citations,
    );
  }
}
