import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cropdetect/l10n/app_localizations.dart';
import '../models/scan_result_model.dart';
import 'package:intl/intl.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Please log in to view history")),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.scanHistory,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('scans')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No scans yet", // Localize later
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.5,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final scan = ScanResultModel.fromMap(data, docs[index].id);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
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
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: scan.imageUrl.isNotEmpty
                          ? Image.network(
                              scan.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white12
                                    : Colors.grey[200],
                                child: Icon(
                                  Icons.broken_image,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white54
                                      : Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white12
                                  : Colors.grey[200],
                              child: Icon(
                                Icons.image,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white54
                                    : Colors.grey,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scan.diseaseName,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scan.cropName,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMd().format(scan.timestamp),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
