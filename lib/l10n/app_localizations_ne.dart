// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get profileTitle => 'प्रोफाइल';

  @override
  String get name => 'राम बहादुर';

  @override
  String get location => 'चितवन, नेपाल';

  @override
  String get settings => 'सेटिङहरू';

  @override
  String get language => 'भाषा';

  @override
  String get scanHistory => 'स्क्यान इतिहास';

  @override
  String get helpSupport => 'सहयोग र समर्थन';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get selectLanguage => 'भाषा छान्नुहोस्';

  @override
  String get english => 'English';

  @override
  String get nepali => 'नेपाली';

  @override
  String get appTitle => 'सजिलोखेती';

  @override
  String get appSubtitle => 'तपाईंको बाली चिकित्सक';

  @override
  String get greeting => 'नमस्ते, किसान!';

  @override
  String welcomeUser(String name) {
    return 'नमस्ते, $name!';
  }

  @override
  String get greetingSubtitle => 'आज कुन बाली जाँच गर्नुपर्छ?';

  @override
  String get selectCrop => 'रोग निदानको लागि बाली छान्नुहोस्';

  @override
  String get seeAll => 'सबै हेर्नुहोस्';

  @override
  String get quickActions => 'द्रुत कार्यहरू';

  @override
  String get takePhoto => 'फोटो खिच्नुहोस्';

  @override
  String get askExpert => 'विशेषज्ञलाई सोध्नुहोस्';

  @override
  String get rice => 'धान';

  @override
  String get potato => 'आलु';

  @override
  String get tomato => 'गोलभेडा';

  @override
  String get community => 'समुदाय';

  @override
  String get farmer => 'किसान';

  @override
  String get diagnoseDisease => 'रोग निदान';

  @override
  String get describeSymptoms => 'लक्षणहरू वर्णन गर्नुहोस्';

  @override
  String get micPrompt =>
      'माइक ट्याप गर्नुहोस् र तपाइँको बालीमा के देख्नुहुन्छ वर्णन गर्नुहोस्।';

  @override
  String get recording => 'रेकर्ड गर्दै... रोक्न ट्याप गर्नुहोस्';

  @override
  String get analyzingAudio => 'अडियो विश्लेषण गर्दै...';

  @override
  String get tapToRecord => 'रेकर्ड गर्न ट्याप गर्नुहोस्';

  @override
  String get detectedDescription => 'पत्ता लागेको विवरण:';

  @override
  String get analyzeDescription => 'विवरण विश्लेषण गर्नुहोस्';

  @override
  String get audioAnalysisComingSoon => 'विवरण विश्लेषण सुविधा चाँडै आउँदैछ!';

  @override
  String get orSelectCrop => 'वा बाली छान्नुहोस्';

  @override
  String get selectMethod => 'विधि छान्नुहोस्';

  @override
  String get camera => 'क्यामेरा';

  @override
  String get gallery => 'ग्यालरी';

  @override
  String cropDisease(String cropName) {
    return '$cropName रोग';
  }

  @override
  String uploadImagePrompt(String cropName) {
    return '$cropName को पातको फोटो अपलोड गर्नुहोस् रोग पत्ता लगाउन।';
  }

  @override
  String get tapToAddPhoto => 'फोटो थप्न ट्याप गर्नुहोस्';

  @override
  String get changePhoto => 'फोटो परिवर्तन गर्नुहोस्';

  @override
  String get selectImage => 'फोटो छान्नुहोस्';

  @override
  String get analyzeDisease => 'रोग विश्लेषण गर्नुहोस्';

  @override
  String get analysisComingSoon => 'विश्लेषण सुविधा चाँडै आउँदैछ!';

  @override
  String get pickImageError => 'फोटो छान्न असफल: ';

  @override
  String get navHome => 'गृहपृष्ठ';

  @override
  String get navDiagnose => 'निदान';

  @override
  String get navCommunity => 'समुदाय';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get highHumidityWarning => 'उच्च आर्द्रता - ढुसीको जाँच गर्नुहोस्';

  @override
  String get highTempWarning => 'उच्च तापक्रम - सिचाई सुनिश्चित गर्नुहोस्';

  @override
  String get lowTempWarning => 'कम तापक्रम - तुषारोबाट बचाउनुहोस्';

  @override
  String get goodWeatherMessage => 'बालीका लागि मौसम राम्रो छ';

  @override
  String get locationPermissionDeny => 'स्थान अनुमति अस्वीकार गरियो';

  @override
  String get weatherLoadError => 'मौसम लोड गर्न असफल';

  @override
  String get retry => 'पुनः प्रयास गर्नुहोस्';

  @override
  String get todayWeather => 'आजको मौसम';

  @override
  String get humidity => 'आर्द्रता';

  @override
  String get refinedPrompt => 'परिष्कृत प्रम्प्ट (कोहियर):';

  @override
  String get analysisError => 'विश्लेषण त्रुटि: ';

  @override
  String get error => 'त्रुटि: ';

  @override
  String get analysisFailed => 'विश्लेषण असफल: ';

  @override
  String get analysisResult => 'विश्लेषण नतिजा';

  @override
  String get confidence => 'आत्मविश्वास: ';

  @override
  String get diagnosisTitle => 'निदान';

  @override
  String get treatmentTitle => 'सुझाव गरिएको उपचार';

  @override
  String get careTipsTitle => 'हेरचाह सुझावहरू';

  @override
  String get done => 'सम्पन्न भयो';

  @override
  String get diseaseHealthy => 'स्वस्थ';

  @override
  String get diseaseEarlyBlight => 'अगाडिको डढुवा (अर्ली ब्लाइट)';

  @override
  String get descHealthy =>
      'तपाईंको बाली स्वस्थ र जीवन्त देखिन्छ। कुनै रोगको लक्षण फेला परेन।';

  @override
  String get descEarlyBlight =>
      'पुरानो पातहरूमा कालो दागहरू देखिने फंगल संक्रमण। गोलभेडा र आलुमा सामान्य।';

  @override
  String get treatHealthy =>
      'नियमित सिचाई जारी राख्नुहोस्।\nकीराहरूको निगरानी गर्नुहोस्।\nउचित घाम सुनिश्चित गर्नुहोस्।';

  @override
  String get treatEarlyBlight =>
      'संक्रमित पातहरू तुरुन्तै हटाउनुहोस्।\nबिरुवाहरू वरिपरि हावाको आवागमन सुधार गर्नुहोस्।\nकपर-आधारित फङ्गिसाइड प्रयोग गर्नुहोस्।\nमाथिबाट पानी हाल्न बच्नुहोस्।';

  @override
  String get aboutApp => 'एपको बारेमा';

  @override
  String get aboutDescription =>
      'सजिलोखेती धान, आलु र गोलभेडामा रोग पत्ता लगाउने एआई-संचालित एप हो। यसले किसानहरूलाई तत्काल निदान र उपचार सल्लाह प्रदान गर्दछ।';

  @override
  String get developedBy => 'विकासकर्ताहरू';

  @override
  String get computerEngineers => 'कम्प्युटर इन्जिनियरहरू';

  @override
  String get settingsTitle => 'सेटिङहरू';

  @override
  String get settingsMessage => 'सेटिङ सुबिधा चाँडै आउँदैछ!';

  @override
  String get helpSupportTitle => 'सहयोग र समर्थन';

  @override
  String get helpSupportMessage => 'हाम्रो सम्पर्क: support@sajilokheti.com';

  @override
  String get newPost => 'नयाँ पोस्ट';

  @override
  String get whatsOnYourMind => 'तपाईंको दिमागमा के छ?';

  @override
  String get postAction => 'पोस्ट गर्नुहोस्';

  @override
  String get noPosts => 'अहिलेसम्म कुनै पोस्ट छैन';

  @override
  String get beFirstToAsk => 'प्रश्न सोध्ने पहिलो व्यक्ति बन्नुहोस्!';

  @override
  String get justNow => 'भर्खरै';

  @override
  String daysAgo(int count) {
    return '$count दिन अगाडि';
  }

  @override
  String hoursAgo(int count) {
    return '$count घण्टा अगाडि';
  }

  @override
  String minutesAgo(int count) {
    return '$count मिनेट अगाडि';
  }

  @override
  String get general => 'सामान्य';

  @override
  String get notifications => 'सूचनाहरू';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get account => 'खाता';

  @override
  String get deleteAccount => 'खाता हटाउनुहोस्';

  @override
  String get deleteAccountMsg => 'खाता हटाउने सुविधा अहिले उपलब्ध छैन';

  @override
  String severityLevel(Object level) {
    return 'गम्भीरता: $level';
  }

  @override
  String get severityLow => 'कम';

  @override
  String get severityMedium => 'मध्यम';

  @override
  String get severityHigh => 'उच्च';

  @override
  String get references => 'सन्दर्भ सामग्रीहरू';

  @override
  String step(Object number) {
    return 'चरण $number';
  }
}
