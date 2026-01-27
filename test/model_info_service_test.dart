import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cropdetect/services/model_info_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ModelInfoService Tests', () {
    late ModelInfoService service;

    setUp(() {
      service = ModelInfoService();
    });

    test('Returns correct info for known disease', () {
      final info = service.getDiseaseInfo('rice', 'blast', const Locale('en'));
      expect(info.name, 'Rice Blast');
    });

    // Note: To test actual JSON loading, we'd need to mock rootBundle or run as an integration test.
    // However, we can test the fallback logic immediately.

    test('Returns fallback for unknown disease', () {
      // Assuming JSON not loaded
      final info = service.getDiseaseInfo(
        'unknown_crop',
        'unknown_disease',
        const Locale('en'),
      );
      expect(info.name, 'unknown_disease');
    });
  });
}
