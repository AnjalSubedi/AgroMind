import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cropdetect/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';

import 'package:firebase_core/firebase_core.dart';

bool _firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("DotEnv not found, using defaults: $e");
  }
  try {
    // If you have generated firebase_options.dart, import it and use:
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
    _firebaseInitialized = true;
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    // On Web, this often happens if options are not provided.
    // Proceeding without Firebase for UI testing purposes.
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      builder: (context, child) {
        final localeProvider = Provider.of<LocaleProvider>(context);
        final themeProvider = Provider.of<ThemeProvider>(context);

        return MaterialApp(
          title: 'Sajilokheti',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ne')],
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
              primary: const Color(0xFF1B5E20),
              secondary: const Color(0xFF4CAF50),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
              primary: const Color(0xFF81C784), // Lighter green for dark mode
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            useMaterial3: true,
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Bypass for Web testing if Firebase didn't init
    if (!_firebaseInitialized && kIsWeb) {
      return const HomeScreen();
    }

    if (!_firebaseInitialized) {
      return const Scaffold(body: Center(child: Text("Firebase Init Failed")));
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const AuthScreen();
      },
    );
  }
}
