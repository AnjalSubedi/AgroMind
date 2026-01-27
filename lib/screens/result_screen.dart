import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cropdetect/l10n/app_localizations.dart';
import '../services/disease_detection_service.dart';

class ResultScreen extends StatefulWidget {
  final File? image;
  final DiseaseDetectionResult result;
  final String cropName;

  const ResultScreen({
    super.key,
    this.image,
    required this.result,
    required this.cropName,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    // Fire and forget, or handle errors silently/with log
    await DiseaseDetectionService().saveScanResult(
      cropType: widget.cropName,
      result: widget.result,
      image: widget.image,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use dynamic data from existing result object
    String diseaseName = widget.result.diseaseName;
    String description = widget.result.description;
    List<String> treatment = widget.result.treatment;

    // Determine healthy status based on severity or ID
    // The service sets severity to "Low" for healthy plants
    bool isHealthy =
        widget.result.severity == "Low" ||
        widget.result.diseaseId == 'healthy' ||
        widget.result.diseaseId == 'normal';

    // final resultColor = isHealthy ? Colors.green : Colors.red; // Unused after new UI

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.analysisResult,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.headlineSmall?.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: widget.image != null
                    ? Image.file(
                        widget.image!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.mic_external_on_rounded,
                          size: 80,
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Severity Meter Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    diseaseName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isHealthy ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${l10n.confidence}${(widget.result.confidence * 100).toStringAsFixed(1)}%",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Segmented Gauge Visual (Use l10n)
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final segmentWidth = (width - 20) / 3; // 10px spacing * 2

                      // Determine active level
                      int activeIndex = 0; // 0: Low, 1: Medium, 2: High
                      if (!isHealthy) {
                        if (widget.result.severity == "Medium") activeIndex = 1;
                        if (widget.result.severity == "High") activeIndex = 2;
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSegment(
                            0,
                            l10n.severityLow,
                            Colors.green,
                            activeIndex,
                            segmentWidth,
                            Icons.shield_outlined,
                          ),
                          _buildSegment(
                            1,
                            l10n.severityMedium,
                            Colors.orange,
                            activeIndex,
                            segmentWidth,
                            Icons.warning_amber_rounded,
                          ),
                          _buildSegment(
                            2,
                            l10n.severityHigh,
                            Colors.red,
                            activeIndex,
                            segmentWidth,
                            Icons.gpp_bad_outlined,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Description
            Text(
              l10n.diagnosisTitle,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Text(
                description,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Treatment Cards (Step-by-Step)
            Text(
              isHealthy ? l10n.careTipsTitle : l10n.treatmentTitle,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            ...treatment.asMap().entries.map((entry) {
              int idx = entry.key;
              String step = entry.value;

              // Determine Icon
              IconData stepIcon = Icons.healing_rounded;
              Color iconColor = colorScheme.primary;
              final lowerStep = step.toLowerCase();

              if (lowerStep.contains('spray') ||
                  lowerStep.contains('fungicide') ||
                  lowerStep.contains('chemical')) {
                stepIcon = Icons.sanitizer_rounded;
                iconColor = Colors.orange;
              } else if (lowerStep.contains('water') ||
                  lowerStep.contains('irrigate') ||
                  lowerStep.contains('drain')) {
                stepIcon = Icons.water_drop_rounded;
                iconColor = Colors.blue;
              } else if (lowerStep.contains('prune') ||
                  lowerStep.contains('remove') ||
                  lowerStep.contains('cut') ||
                  lowerStep.contains('destroy')) {
                stepIcon = Icons.content_cut_rounded;
                iconColor = Colors.redAccent;
              } else if (lowerStep.contains('soil') ||
                  lowerStep.contains('fertilizer') ||
                  lowerStep.contains('nutrient')) {
                stepIcon = Icons.grass_rounded;
                iconColor = Colors.brown;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 0,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.grey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: iconColor.withOpacity(0.1),
                              child: Icon(stepIcon, color: iconColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.step(idx + 1),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          step,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // References Section
            if (widget.result.citations.isNotEmpty) ...[
              Text(
                l10n.references,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.headlineSmall?.color,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.result.citations.map((citation) {
                // Split title and URL if possible
                final parts = citation.split(' - ');
                final title = parts[0];
                final url = parts.length > 1
                    ? parts.sublist(1).join(' - ')
                    : '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 20,
                        color: (theme.brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (url.isNotEmpty)
                              Text(
                                url,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.done,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(
    int index,
    String label,
    Color color,
    int activeIndex,
    double width,
    IconData icon,
  ) {
    final isActive = index == activeIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: isActive
            ? color.withOpacity(0.15)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: isActive ? color : Colors.grey, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
