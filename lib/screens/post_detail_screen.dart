import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/community_service.dart';
import 'package:cropdetect/l10n/app_localizations.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;
  final CommunityService communityService;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.communityService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Post Details",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original Post Content (Simplified View)
                  _PostHeader(post: post),
                  const SizedBox(height: 16),
                  Text(
                    post.content,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    "Comments",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Comments Stream
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: communityService.getComments(post.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text("Error loading comments");
                      }

                      final commentsData = snapshot.data ?? [];
                      if (commentsData.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "No comments yet. Be the first!",
                              style: GoogleFonts.outfit(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: commentsData.length,
                        itemBuilder: (context, index) {
                          final data = commentsData[index];
                          final comment = CommentModel.fromMap(
                            data,
                            data['id'],
                          );
                          return _CommentCard(comment: comment);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _CommentInput(postId: post.id, communityService: communityService),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final PostModel post;

  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: colorScheme.primary,
          backgroundImage: post.userImage.isNotEmpty
              ? NetworkImage(post.userImage)
              : null,
          child: post.userImage.isEmpty
              ? Text(
                  post.userName[0].toUpperCase(),
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
                  post.userName,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (post.isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, size: 16, color: Colors.blue),
                ],
              ],
            ),
            Text(
              "Original Poster",
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  final CommentModel comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white10
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.userName,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (comment.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 14, color: Colors.blue),
              ],
              const Spacer(),
              Text(
                "${comment.timestamp.hour}:${comment.timestamp.minute}", // Simple time
                style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content, style: GoogleFonts.outfit(fontSize: 14)),
        ],
      ),
    );
  }
}

class _CommentInput extends StatefulWidget {
  final String postId;
  final CommunityService communityService;

  const _CommentInput({required this.postId, required this.communityService});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _sendComment() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    try {
      await widget.communityService.addComment(
        widget.postId,
        _controller.text.trim(),
      );
      _controller.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send: $e")));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Write a comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white12
                    : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isSending ? null : _sendComment,
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
