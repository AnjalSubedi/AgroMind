import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/community_service.dart';
import 'package:cropdetect/l10n/app_localizations.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final CommunityService _communityService = CommunityService();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      await _communityService.createPost(
        _contentController.text.trim(),
        _image,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.newPost,
          style: GoogleFonts.outfit(
            color: theme.textTheme.headlineSmall?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 0,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      l10n.postAction,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: l10n.whatsOnYourMind,
                hintStyle: GoogleFonts.outfit(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
                border: InputBorder.none,
              ),
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            if (_image != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _image!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _image = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Divider(color: Colors.grey[200]),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.photo_library_outlined,
                color: colorScheme.primary,
              ),
              title: Text(
                l10n.gallery,
                style: GoogleFonts.outfit(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.camera_alt_outlined,
                color: colorScheme.primary,
              ),
              title: Text(
                l10n.camera,
                style: GoogleFonts.outfit(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}
