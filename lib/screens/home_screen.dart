import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cropdetect/l10n/app_localizations.dart';
import '../widgets/weather_widget.dart';
import '../widgets/crop_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/quick_action_button.dart';
import 'crop_screen.dart';
import 'diagnose_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeContent(),
    const DiagnoseScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final AuthService _authService = AuthService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUserDetails();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  void _navigateToCrop(BuildContext context, String cropName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CropScreen(cropName: cropName)),
    );
  }

  void _navigateToDiagnose(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DiagnoseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        children: [
          // Custom App Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.agriculture_rounded,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      l10n.appSubtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.6,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      _user?.name.isNotEmpty == true
                          ? _user!.name[0].toUpperCase()
                          : "U",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                          const Color(
                            0xFF43A047,
                          ), // Accents can remain fixed or adapt if needed
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user != null
                              ? l10n.welcomeUser(_user!.name.split(' ')[0])
                              : l10n.greeting,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.greetingSubtitle,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Weather Widget
                  const WeatherWidget(),

                  const SizedBox(height: 24),

                  // Crop Selection Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.selectCrop,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.headlineSmall?.color,
                          ),
                        ),
                        Text(
                          l10n.seeAll,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horizontal Crop List
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 24, right: 8),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        CropCard(
                          title: l10n.rice,
                          localizedTitle: "",
                          imageUrl:
                              "https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=1974&auto=format&fit=crop",
                          onTap: () => _navigateToCrop(context, l10n.rice),
                        ),
                        CropCard(
                          title: l10n.potato,
                          localizedTitle: "",
                          imageUrl:
                              "https://images.unsplash.com/photo-1518977676601-b53f82aba655?q=80&w=2070&auto=format&fit=crop",
                          onTap: () => _navigateToCrop(context, l10n.potato),
                        ),
                        CropCard(
                          title: l10n.tomato,
                          localizedTitle: "",
                          imageUrl:
                              "https://images.unsplash.com/photo-1592841200221-a6898f307baa?q=80&w=1974&auto=format&fit=crop",
                          onTap: () => _navigateToCrop(context, l10n.tomato),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quick Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      l10n.quickActions,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineSmall?.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        QuickActionButton(
                          label: l10n.takePhoto,
                          icon: Icons.camera_alt_outlined,
                          onTap: () => _navigateToDiagnose(context),
                        ),
                        QuickActionButton(
                          label: l10n.askExpert,
                          icon: Icons.chat_bubble_outline_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CommunityScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
