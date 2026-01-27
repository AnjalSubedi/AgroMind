import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cropdetect/l10n/app_localizations.dart';
import 'package:cropdetect/screens/profile_screen.dart';
import 'package:cropdetect/providers/locale_provider.dart';

void main() {
  testWidgets('Localization test: Switch from English to Nepali', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => LocaleProvider(),
        builder: (context, child) {
          final provider = Provider.of<LocaleProvider>(context);
          return MaterialApp(
            locale: provider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ne')],
            home: const ProfileScreen(),
          );
        },
      ),
    );

    // Verify that we start in English
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);

    // Tap the Language option to open the bottom sheet
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    // Verify bottom sheet content
    expect(find.text('Select Language'), findsOneWidget);
    expect(find.text('Nepali'), findsOneWidget);

    // Tap Nepali
    await tester.tap(find.text('Nepali'));
    await tester.pumpAndSettle();

    // Verify text changed to Nepali
    expect(find.text('प्रोफाइल'), findsOneWidget); // Profile in Nepali
    expect(find.text('भाषा'), findsOneWidget); // Language in Nepali
  });
}
