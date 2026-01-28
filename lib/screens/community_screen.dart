import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cropdetect/l10n/app_localizations.dart';
import '../services/community_service.dart';
import '../services/cohere_service.dart';
import '../models/post_model.dart';
import 'create_post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final CommunityService communityService = CommunityService();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.community,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: communityService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noPosts,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.5,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    l10n.beFirstToAsk,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _PostCard(post: post, communityService: communityService);
            },
          );
        },
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final PostModel post;
  final CommunityService communityService;

  const _PostCard({required this.post, required this.communityService});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _isTranslating = false;
  String? _translatedContent;
  final CohereService _cohereService = CohereService();

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.minutesAgo(difference.inMinutes);
    } else {
      return l10n.justNow;
    }
  }

  Future<void> _translatePost() async {
    if (_translatedContent != null) {
      // Toggle back if already translated? Or just keep it?
      // Let's implement toggle: if showing translation, revert.
      setState(() {
        _translatedContent = null;
      });
      return;
    }

    setState(() => _isTranslating = true);
    try {
      // Determine target language based on current locale
      final currentLocale = Localizations.localeOf(context).languageCode;
      final targetLang = currentLocale == 'ne' ? 'Nepali' : 'English';

      final translated = await _cohereService.translateText(
        widget.post.content,
        targetLang,
      );

      if (mounted) {
        setState(() {
          _translatedContent = translated;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTranslating = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Translation failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final isLiked = user != null && widget.post.likes.contains(user.uid);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayContent = _translatedContent ?? widget.post.content;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white10
              : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primary,
                backgroundImage: widget.post.userImage.isNotEmpty
                    ? NetworkImage(widget.post.userImage)
                    : null,
                child: widget.post.userImage.isEmpty
                    ? Text(
                        widget.post.userName.isNotEmpty
                            ? widget.post.userName[0].toUpperCase()
                            : "?",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.post.userName,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (widget.post.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    _formatTimestamp(context, widget.post.timestamp),
                    style: GoogleFonts.outfit(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.6,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Translate Button
              InkWell(
                onTap: _isTranslating ? null : _translatePost,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _isTranslating
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.translate_rounded,
                          size: 20,
                          color: _translatedContent != null
                              ? colorScheme.primary
                              : theme.textTheme.bodyMedium?.color?.withOpacity(
                                  0.4,
                                ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayContent,
            style: GoogleFonts.outfit(
              color: theme.textTheme.bodyMedium?.color, // Adaptive text color
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (_translatedContent != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "(Translated by AI)",
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (widget.post.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.post.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () => widget.communityService.toggleLike(widget.post.id),
                child: Row(
                  children: [
                    Icon(
                      isLiked
                          ? Icons.thumb_up_alt_rounded
                          : Icons.thumb_up_alt_outlined,
                      size: 20,
                      color: isLiked
                          ? colorScheme.primary
                          : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${widget.post.likes.length}",
                      style: GoogleFonts.outfit(
                        color: isLiked
                            ? colorScheme.primary
                            : theme.textTheme.bodyMedium?.color?.withOpacity(
                                0.6,
                              ),
                        fontWeight: isLiked
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Icon(
                Icons.comment_outlined,
                size: 20,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                "${widget.post.commentsCount}",
                style: GoogleFonts.outfit(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
