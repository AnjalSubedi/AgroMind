// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profileTitle => 'Profile';

  @override
  String get name => 'Ram Bahadur';

  @override
  String get location => 'Chitwan, Nepal';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get signOut => 'Sign Out';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get nepali => 'नेपाली';

  @override
  String get appTitle => 'Sajilokheti';

  @override
  String get appSubtitle => 'Your Crop Doctor';

  @override
  String get greeting => 'Namaste, Farmer!';

  @override
  String welcomeUser(String name) {
    return 'Hello, $name!';
  }

  @override
  String get greetingSubtitle => 'What crop needs checking today?';

  @override
  String get selectCrop => 'Select Crop for Diagnosis';

  @override
  String get seeAll => 'See All';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get takePhoto => 'Take a Photo';

  @override
  String get askExpert => 'Ask an Expert';

  @override
  String get rice => 'Rice';

  @override
  String get potato => 'Potato';

  @override
  String get tomato => 'Tomato';

  @override
  String get community => 'Community';

  @override
  String get farmer => 'Farmer';

  @override
  String get diagnoseDisease => 'Diagnose Disease';

  @override
  String get describeSymptoms => 'Describe Symptoms';

  @override
  String get micPrompt => 'Tap the mic and describe what you see on your crop.';

  @override
  String get recording => 'Recording... Tap to stop';

  @override
  String get analyzingAudio => 'Analyzing audio...';

  @override
  String get tapToRecord => 'Tap to Record';

  @override
  String get detectedDescription => 'Detected Description:';

  @override
  String get analyzeDescription => 'Analyze Description';

  @override
  String get audioAnalysisComingSoon =>
      'Analysis based on audio description coming soon!';

  @override
  String get orSelectCrop => 'Or Select a Crop';

  @override
  String get selectMethod => 'Select Method';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String cropDisease(String cropName) {
    return '$cropName Disease';
  }

  @override
  String uploadImagePrompt(String cropName) {
    return 'Upload an image of the $cropName leaf to detect diseases.';
  }

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get selectImage => 'Select Image';

  @override
  String get analyzeDisease => 'Analyze Disease';

  @override
  String get analysisComingSoon => 'Analysis feature coming soon!';

  @override
  String get pickImageError => 'Failed to pick image: ';

  @override
  String get navHome => 'Home';

  @override
  String get navDiagnose => 'Diagnose';

  @override
  String get navCommunity => 'Community';

  @override
  String get navProfile => 'Profile';

  @override
  String get highHumidityWarning => 'High humidity - check for fungus';

  @override
  String get highTempWarning => 'High temperature - ensure irrigation';

  @override
  String get lowTempWarning => 'Low temperature - protect from frost';

  @override
  String get goodWeatherMessage => 'Weather is good for crops';

  @override
  String get locationPermissionDeny => 'Location permission denied';

  @override
  String get weatherLoadError => 'Failed to load weather';

  @override
  String get retry => 'Retry';

  @override
  String get todayWeather => 'Today\'s Weather';

  @override
  String get humidity => 'Humidity';

  @override
  String get refinedPrompt => 'Refined Prompt (Cohere):';

  @override
  String get analysisError => 'Analysis Error: ';

  @override
  String get error => 'Error: ';

  @override
  String get analysisFailed => 'Analysis failed: ';

  @override
  String get analysisResult => 'Analysis Result';

  @override
  String get confidence => 'Confidence: ';

  @override
  String get diagnosisTitle => 'Diagnosis';

  @override
  String get treatmentTitle => 'Recommended Treatment';

  @override
  String get careTipsTitle => 'Care Tips';

  @override
  String get done => 'Done';

  @override
  String get diseaseHealthy => 'Healthy';

  @override
  String get diseaseEarlyBlight => 'Early Blight';

  @override
  String get descHealthy =>
      'Your crop looks healthy and vibrant. No signs of disease were detected.';

  @override
  String get descEarlyBlight =>
      'Fungal infection characterized by dark spots on older leaves. Common in tomatoes and potatoes.';

  @override
  String get treatHealthy =>
      'Continue regular watering.\nMonitor for pests.\nEnsure proper sunlight.';

  @override
  String get treatEarlyBlight =>
      'Remove infected leaves immediately.\nImprove air circulation around plants.\nApply copper-based fungicides.\nAvoid overhead watering.';

  @override
  String get aboutApp => 'About App';

  @override
  String get aboutDescription =>
      'Sajilokheti is an AI-powered app detecting crop diseases in rice, potato, and tomato. It empowers farmers with instant diagnosis and treatment advice.';

  @override
  String get developedBy => 'Developed By';

  @override
  String get computerEngineers => 'Computer Engineers';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsMessage => 'Settings feature coming soon!';

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get helpSupportMessage => 'Contact us at support@sajilokheti.com';

  @override
  String get newPost => 'New Post';

  @override
  String get whatsOnYourMind => 'What\'s on your mind?';

  @override
  String get postAction => 'Post';

  @override
  String get noPosts => 'No posts yet';

  @override
  String get beFirstToAsk => 'Be the first to ask a question!';

  @override
  String get justNow => 'Just now';

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String get general => 'General';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get account => 'Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountMsg => 'Account deletion not implemented yet';

  @override
  String severityLevel(Object level) {
    return 'Severity: $level';
  }

  @override
  String get severityLow => 'Low';

  @override
  String get severityMedium => 'Medium';

  @override
  String get severityHigh => 'High';

  @override
  String get references => 'References';

  @override
  String step(Object number) {
    return 'Step $number';
  }
}
