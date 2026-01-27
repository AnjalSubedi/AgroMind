import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cropdetect/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settings,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Section
            Text(
              l10n.general,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context,
              icon: Icons.language,
              title: l10n.language,
              subtitle:
                  Provider.of<LocaleProvider>(context).locale.languageCode ==
                      'ne'
                  ? 'नेपाली'
                  : 'English',
              onTap: () => _showLanguageDialog(context),
            ),
            _buildSwitchTile(
              context: context,
              title: l10n.notifications,
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return _buildSwitchTile(
                  context: context,
                  title: l10n.darkMode,
                  value: themeProvider.isDarkMode,
                  onChanged: (val) => themeProvider.toggleTheme(val),
                );
              },
            ),

            const SizedBox(height: 32),

            // Account Section
            Text(
              l10n.account,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context,
              icon: Icons.delete_outline,
              title: l10n.deleteAccount,
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.deleteAccountMsg)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? theme.iconTheme.color?.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
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
                  color: theme.textTheme.headlineSmall?.color,
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

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    Locale locale,
  ) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final isSelected = provider.locale.languageCode == locale.languageCode;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : theme.brightness == Brightness.dark
                ? Colors.white12
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
