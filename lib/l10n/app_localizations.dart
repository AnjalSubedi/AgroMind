import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Ram Bahadur'**
  String get name;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Chitwan, Nepal'**
  String get location;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @scanHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistory;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @nepali.
  ///
  /// In en, this message translates to:
  /// **'नेपाली'**
  String get nepali;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sajilokheti'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Crop Doctor'**
  String get appSubtitle;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste, Farmer!'**
  String get greeting;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String welcomeUser(String name);

  /// No description provided for @greetingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What crop needs checking today?'**
  String get greetingSubtitle;

  /// No description provided for @selectCrop.
  ///
  /// In en, this message translates to:
  /// **'Select Crop for Diagnosis'**
  String get selectCrop;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// No description provided for @askExpert.
  ///
  /// In en, this message translates to:
  /// **'Ask an Expert'**
  String get askExpert;

  /// No description provided for @rice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get rice;

  /// No description provided for @potato.
  ///
  /// In en, this message translates to:
  /// **'Potato'**
  String get potato;

  /// No description provided for @tomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get tomato;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @diagnoseDisease.
  ///
  /// In en, this message translates to:
  /// **'Diagnose Disease'**
  String get diagnoseDisease;

  /// No description provided for @describeSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Describe Symptoms'**
  String get describeSymptoms;

  /// No description provided for @micPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic and describe what you see on your crop.'**
  String get micPrompt;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording... Tap to stop'**
  String get recording;

  /// No description provided for @analyzingAudio.
  ///
  /// In en, this message translates to:
  /// **'Analyzing audio...'**
  String get analyzingAudio;

  /// No description provided for @tapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap to Record'**
  String get tapToRecord;

  /// No description provided for @detectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Detected Description:'**
  String get detectedDescription;

  /// No description provided for @analyzeDescription.
  ///
  /// In en, this message translates to:
  /// **'Analyze Description'**
  String get analyzeDescription;

  /// No description provided for @audioAnalysisComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Analysis based on audio description coming soon!'**
  String get audioAnalysisComingSoon;

  /// No description provided for @orSelectCrop.
  ///
  /// In en, this message translates to:
  /// **'Or Select a Crop'**
  String get orSelectCrop;

  /// No description provided for @selectMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Method'**
  String get selectMethod;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @cropDisease.
  ///
  /// In en, this message translates to:
  /// **'{cropName} Disease'**
  String cropDisease(String cropName);

  /// No description provided for @uploadImagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Upload an image of the {cropName} leaf to detect diseases.'**
  String uploadImagePrompt(String cropName);

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @analyzeDisease.
  ///
  /// In en, this message translates to:
  /// **'Analyze Disease'**
  String get analyzeDisease;

  /// No description provided for @analysisComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Analysis feature coming soon!'**
  String get analysisComingSoon;

  /// No description provided for @pickImageError.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: '**
  String get pickImageError;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navDiagnose.
  ///
  /// In en, this message translates to:
  /// **'Diagnose'**
  String get navDiagnose;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @highHumidityWarning.
  ///
  /// In en, this message translates to:
  /// **'High humidity - check for fungus'**
  String get highHumidityWarning;

  /// No description provided for @highTempWarning.
  ///
  /// In en, this message translates to:
  /// **'High temperature - ensure irrigation'**
  String get highTempWarning;

  /// No description provided for @lowTempWarning.
  ///
  /// In en, this message translates to:
  /// **'Low temperature - protect from frost'**
  String get lowTempWarning;

  /// No description provided for @goodWeatherMessage.
  ///
  /// In en, this message translates to:
  /// **'Weather is good for crops'**
  String get goodWeatherMessage;

  /// No description provided for @locationPermissionDeny.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDeny;

  /// No description provided for @weatherLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load weather'**
  String get weatherLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @todayWeather.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Weather'**
  String get todayWeather;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @refinedPrompt.
  ///
  /// In en, this message translates to:
  /// **'Refined Prompt (Cohere):'**
  String get refinedPrompt;

  /// No description provided for @analysisError.
  ///
  /// In en, this message translates to:
  /// **'Analysis Error: '**
  String get analysisError;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get error;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed: '**
  String get analysisFailed;

  /// No description provided for @analysisResult.
  ///
  /// In en, this message translates to:
  /// **'Analysis Result'**
  String get analysisResult;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence: '**
  String get confidence;

  /// No description provided for @diagnosisTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosisTitle;

  /// No description provided for @treatmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Treatment'**
  String get treatmentTitle;

  /// No description provided for @careTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Tips'**
  String get careTipsTitle;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @diseaseHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get diseaseHealthy;

  /// No description provided for @diseaseEarlyBlight.
  ///
  /// In en, this message translates to:
  /// **'Early Blight'**
  String get diseaseEarlyBlight;

  /// No description provided for @descHealthy.
  ///
  /// In en, this message translates to:
  /// **'Your crop looks healthy and vibrant. No signs of disease were detected.'**
  String get descHealthy;

  /// No description provided for @descEarlyBlight.
  ///
  /// In en, this message translates to:
  /// **'Fungal infection characterized by dark spots on older leaves. Common in tomatoes and potatoes.'**
  String get descEarlyBlight;

  /// No description provided for @treatHealthy.
  ///
  /// In en, this message translates to:
  /// **'Continue regular watering.\nMonitor for pests.\nEnsure proper sunlight.'**
  String get treatHealthy;

  /// No description provided for @treatEarlyBlight.
  ///
  /// In en, this message translates to:
  /// **'Remove infected leaves immediately.\nImprove air circulation around plants.\nApply copper-based fungicides.\nAvoid overhead watering.'**
  String get treatEarlyBlight;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sajilokheti is an AI-powered app detecting crop diseases in rice, potato, and tomato. It empowers farmers with instant diagnosis and treatment advice.'**
  String get aboutDescription;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed By'**
  String get developedBy;

  /// No description provided for @computerEngineers.
  ///
  /// In en, this message translates to:
  /// **'Computer Engineers'**
  String get computerEngineers;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings feature coming soon!'**
  String get settingsMessage;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportTitle;

  /// No description provided for @helpSupportMessage.
  ///
  /// In en, this message translates to:
  /// **'Contact us at support@sajilokheti.com'**
  String get helpSupportMessage;

  /// No description provided for @newPost.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get newPost;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @postAction.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postAction;

  /// No description provided for @noPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPosts;

  /// No description provided for @beFirstToAsk.
  ///
  /// In en, this message translates to:
  /// **'Be the first to ask a question!'**
  String get beFirstToAsk;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountMsg.
  ///
  /// In en, this message translates to:
  /// **'Account deletion not implemented yet'**
  String get deleteAccountMsg;

  /// No description provided for @severityLevel.
  ///
  /// In en, this message translates to:
  /// **'Severity: {level}'**
  String severityLevel(Object level);

  /// No description provided for @severityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get severityLow;

  /// No description provided for @severityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get severityMedium;

  /// No description provided for @severityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get severityHigh;

  /// No description provided for @references.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get references;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String step(Object number);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
