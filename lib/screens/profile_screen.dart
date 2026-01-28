import 'package:cropdetect/services/auth_service.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cropdetect/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import 'settings_screen.dart';
import 'admin_dashboard_screen.dart';

import 'scan_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _requestUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUserDetails();
    if (mounted) {
      setState(() {
        _requestUser = user;
      });
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
          l10n.profileTitle,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onLongPress: () {
                  if (_requestUser != null) {
                    // Copy UID to clipboard
                    // import 'package:flutter/services.dart'; needed?
                    // Let's use SelectableText logic or just show it?
                    // Better to just copy.
                    Clipboard.setData(ClipboardData(text: _requestUser!.uid));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("UID Copied: ${_requestUser!.uid}"),
                        backgroundColor: Colors.grey[800],
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    _requestUser?.name.isNotEmpty == true
                        ? _requestUser!.name[0].toUpperCase()
                        : "U",
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _requestUser?.name ?? l10n.name,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.headlineSmall?.color,
                  ),
                ),
                if (_requestUser?.isVerified == true) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.verified, color: Colors.blue, size: 24),
                ],
              ],
            ),
            Text(
              _requestUser?.location ?? l10n.location,
              style: GoogleFonts.outfit(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            if (_requestUser?.isAdmin == true)
              _buildProfileOption(
                context,
                Icons.admin_panel_settings_outlined,
                "Admin Panel",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDashboardScreen(),
                    ),
                  );
                },
              ),
            _buildProfileOption(
              context,
              Icons.settings_outlined,
              l10n.settings,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            _buildProfileOption(
              context,
              Icons.language_outlined,
              l10n.language,
              () => _showLanguageDialog(context),
            ),
            _buildProfileOption(
              context,
              Icons.history_outlined,
              l10n.scanHistory,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
                );
              },
            ),
            _buildProfileOption(
              context,
              Icons.help_outline_rounded,
              l10n.helpSupport,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.helpSupportMessage)),
                );
              },
            ),
            _buildProfileOption(
              context,
              Icons.info_outline_rounded,
              l10n.aboutApp,
              () => _showAboutDialog(context),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 16),

            // Expert Verification Button
            if (_requestUser != null && !_requestUser!.isVerified)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _requestUser!.verificationRequested
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.pending_actions,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Verification Pending",
                                style: GoogleFonts.outfit(
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showVerificationDialog(context),
                          icon: const Icon(Icons.verified_user_outlined),
                          label: Text(
                            "Apply for Expert Verification",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
              ),

            TextButton(
              onPressed: () async {
                await _authService.signOut();
              },
              child: Text(
                l10n.signOut,
                style: GoogleFonts.outfit(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>(); // Use local key
    final nameController = TextEditingController(
      text: _requestUser?.name ?? '',
    );
    final addressController = TextEditingController(
      text: _requestUser?.location ?? '',
    );
    final almaMatterController = TextEditingController();
    final rollNoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Expert Verification",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          // Allow scrolling for mobile
          child: Form(
            // Wrap in Form
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (v) => v?.isNotEmpty == true ? null : "Required",
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                  validator: (v) => v?.isNotEmpty == true ? null : "Required",
                ),
                TextFormField(
                  controller: almaMatterController,
                  decoration: const InputDecoration(
                    labelText: "Alma Matter / University",
                  ),
                  validator: (v) => v?.isNotEmpty == true ? null : "Required",
                ),
                TextFormField(
                  controller: rollNoController,
                  decoration: const InputDecoration(
                    labelText: "Verification Key (e.g. Roll No)",
                  ),
                  validator: (v) => v?.isNotEmpty == true ? null : "Required",
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Validate
                Navigator.pop(
                  context,
                ); // Close dialog first to avoid multiple clicks
                // Show loading? Ideally yes, but sticking to simple flow for now.

                await _authService.requestVerification({
                  'name': nameController.text.trim(),
                  'address': addressController.text.trim(),
                  'almaMatter': almaMatterController.text.trim(),
                  'verificationKey': rollNoController.text.trim(),
                });

                await _loadUserData(); // Refresh UI
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Application Sent! We will review shortly.",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? colorScheme.surface
                : Colors.grey[50], // Or use a surface container color
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectLanguage,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(context, l10n.english, const Locale('en')),
              const SizedBox(height: 12),
              _buildLanguageOption(context, l10n.nepali, const Locale('ne')),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: const Color(0xFF1B5E20)),
            const SizedBox(width: 10),
            Text(
              l10n.aboutApp,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.aboutDescription,
              style: GoogleFonts.outfit(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.developedBy,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Aananda Bastola\nAnjal Subedi\nAbhiujan Baral",
              style: GoogleFonts.outfit(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.computerEngineers,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.done,
              style: GoogleFonts.outfit(
                color: const Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    Locale locale,
  ) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final isSelected = provider.locale.languageCode == locale.languageCode;

    return InkWell(
      onTap: () {
        provider.setLocale(locale);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1B5E20).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B5E20) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF1B5E20) : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF1B5E20)),
          ],
        ),
      ),
    );
  }
}
