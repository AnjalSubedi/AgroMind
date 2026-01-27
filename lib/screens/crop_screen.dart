import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cropdetect/l10n/app_localizations.dart';
import '../services/disease_detection_service.dart';
import 'result_screen.dart';

class CropScreen extends StatefulWidget {
  final String cropName;

  const CropScreen({super.key, required this.cropName});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;
  final DiseaseDetectionService _service = DiseaseDetectionService();

  Future<void> _analyzeImage() async {
    if (_image == null) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isAnalyzing = true);

    try {
      final result = await _service.analyzeImage(
        _image!,
        Localizations.localeOf(context),
        widget.cropName,
      );
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            image: _image!,
            result: result,
            cropName: widget.cropName,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${l10n.analysisFailed}$e")));
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${l10n.pickImageError}$e")));
    }
  }

  void _showPickerOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectMethod,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.headlineSmall?.color,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(
                    icon: Icons.camera_alt_rounded,
                    label: l10n.camera,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildOption(
                    icon: Icons.photo_library_rounded,
                    label: l10n.gallery,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.cropDisease(widget.cropName),
          style: GoogleFonts.outfit(
            color: theme.textTheme.headlineSmall?.color,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.uploadImagePrompt(widget.cropName),
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),

              if (_image == null)
                GestureDetector(
                  onTap: () => _showPickerOptions(context),
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? colorScheme.surface
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white10
                            : Colors.grey[200]!,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white12
                                : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            size: 48,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white54
                                : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.tapToAddPhoto,
                          style: GoogleFonts.outfit(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Container(
                      height: 320,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => _showPickerOptions(context),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(
                        l10n.changePhoto,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 48),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (_image == null || _isAnalyzing)
                      ? (_isAnalyzing
                            ? null
                            : () => _showPickerOptions(context))
                      : _analyzeImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.4),
                  ),
                  child: _isAnalyzing
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Text(
                          _image == null
                              ? l10n.selectImage
                              : l10n.analyzeDisease,
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
      ),
    );
  }
}
