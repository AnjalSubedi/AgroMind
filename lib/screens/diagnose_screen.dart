import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cropdetect/l10n/app_localizations.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:cropdetect/services/api_service.dart';
import 'package:cropdetect/services/disease_detection_service.dart';
import 'crop_screen.dart';
import 'result_screen.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DiagnoseScreen extends StatefulWidget {
  const DiagnoseScreen({super.key});

  @override
  State<DiagnoseScreen> createState() => _DiagnoseScreenState();
}

class _DiagnoseScreenState extends State<DiagnoseScreen> {
  late AudioRecorder _audioRecorder;
  bool _isRecording = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    // _textController removed
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isAnalyzing) return;

    try {
      if (_isRecording) {
        // Stop recording
        final path = await _audioRecorder.stop();
        setState(() => _isRecording = false);

        if (path != null) {
          _analyzeAudio(path);
        }
      } else {
        // Start recording
        // Check permission explicitly first
        var status = await Permission.microphone.status;
        if (!status.isGranted) {
          status = await Permission.microphone.request();
          if (!status.isGranted) {
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Microphone permission required')),
              );
            return;
          }
        }

        if (await _audioRecorder.hasPermission()) {
          final directory = await getTemporaryDirectory();
          final path =
              '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

          const config = RecordConfig(encoder: AudioEncoder.wav);
          await _audioRecorder.start(config, path: path);

          setState(() {
            _isRecording = true;
            // _text reset removed
          });
        }
      }
    } catch (e) {
      debugPrint("Recording error: $e");
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Recording error: $e')));
      setState(() => _isRecording = false);
    }
  }

  Future<void> _analyzeAudio(String filePath) async {
    setState(() => _isAnalyzing = true);
    try {
      final api = ApiService();
      final String lang = Localizations.localeOf(context).languageCode;
      final response = await api.diagnoseAudio(filePath, languageCode: lang);

      if (response['success'] == true) {
        final transcribed = response['transcribed_text'];
        _processDiagnosisResponse(response, transcribed);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  // _analyzeText removed

  void _processDiagnosisResponse(
    Map<String, dynamic> response,
    String originalText,
  ) {
    if (response['success'] == true && response['predictions'] != null) {
      // Update text field with what was understood
      // Text update removed

      final predictions = response['predictions'] as List;
      if (predictions.isNotEmpty) {
        final bestPred = predictions[0];

        final result = DiseaseDetectionResult(
          diseaseId: bestPred['label'] ?? 'unknown',
          diseaseName: bestPred['disease'] ?? bestPred['label'],
          confidence: (bestPred['confidence'] ?? 0) / 100.0,
          description:
              "Based on symptoms: \"$originalText\"\n\n${bestPred['symptoms'] ?? ''}",
          treatment: (bestPred['actions'] as String? ?? '')
              .split(';')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          severity: (bestPred['label'] == 'normal') ? 'Low' : 'High',
          citations: [],
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                image: null,
                result: result,
                cropName: 'Voice Diagnosis',
              ),
            ),
          );
        }
      }
    } else {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No diagnosis found.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.diagnoseDisease,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Voice Assistant / Text Input Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.secondary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _isRecording
                          ? "Listening..."
                          : (_isAnalyzing
                                ? "Analyzing..."
                                : "Describe Symptoms"),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording
                              ? Colors.redAccent
                              : colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_isRecording
                                          ? Colors.redAccent
                                          : colorScheme.primary)
                                      .withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          size: 32,
                          color: _isRecording
                              ? Colors.white
                              : colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    // TextField and Button removed as per request to disable typing symptoms
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                l10n.orSelectCrop,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.headlineSmall?.color,
                ),
              ),
              const SizedBox(height: 24),
              _buildCropButton(context, l10n.rice, Icons.grass),
              const SizedBox(height: 16),
              _buildCropButton(context, l10n.potato, Icons.spa),
              const SizedBox(height: 16),
              _buildCropButton(context, l10n.tomato, Icons.local_florist),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropButton(BuildContext context, String crop, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CropScreen(cropName: crop)),
          );
        },
        icon: Icon(icon),
        label: Text(
          crop,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
