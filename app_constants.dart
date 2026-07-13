/// ثوابت التطبيق
class AppConstants {
  AppConstants._();

  // معلومات التطبيق
  static const String appName = 'VideoTranslate AI';
  static const String appVersion = '1.0.0';

  // حدود الملفات
  static const int maxVideoDurationMinutes = 300; // 5 ساعات
  static const int maxFileSizeMB = 4096; // 4 جيجابايت

  // API Keys (يجب تعيينها من الإعدادات)
  static const String openAiApiKeyPref = 'openai_api_key';
  static const String deeplApiKeyPref = 'deepl_api_key';

  // مفاتيح SharedPreferences
  static const String themeModePref = 'theme_mode';
  static const String languagePref = 'language';
  static const String audioQualityPref = 'audio_quality';
  static const String translationQualityPref = 'translation_quality';
  static const String apiProviderPref = 'api_provider';

  // جودة الصوت
  static const List<String> audioQualities = ['low', 'medium', 'high'];

  // جودة الترجمة
  static const List<String> translationQualities = ['standard', 'premium'];

  // امتدادات الفيديو المدعومة
  static const List<String> supportedVideoExtensions = [
    'mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm', '3gp', 'mpeg'
  ];

  // اللغات المدعومة (أكثر من 100 لغة)
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'ar', 'name': 'العربية', 'nameEn': 'Arabic', 'flag': '🇸🇦'},
    {'code': 'en', 'name': 'الإنجليزية', 'nameEn': 'English', 'flag': '🇺🇸'},
    {'code': 'fr', 'name': 'الفرنسية', 'nameEn': 'French', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'الألمانية', 'nameEn': 'German', 'flag': '🇩🇪'},
    {'code': 'es', 'name': 'الإسبانية', 'nameEn': 'Spanish', 'flag': '🇪🇸'},
    {'code': 'it', 'name': 'الإيطالية', 'nameEn': 'Italian', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'البرتغالية', 'nameEn': 'Portuguese', 'flag': '🇧🇷'},
    {'code': 'ru', 'name': 'الروسية', 'nameEn': 'Russian', 'flag': '🇷🇺'},
    {'code': 'zh', 'name': 'الصينية', 'nameEn': 'Chinese', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': 'اليابانية', 'nameEn': 'Japanese', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': 'الكورية', 'nameEn': 'Korean', 'flag': '🇰🇷'},
    {'code': 'tr', 'name': 'التركية', 'nameEn': 'Turkish', 'flag': '🇹🇷'},
    {'code': 'fa', 'name': 'الفارسية', 'nameEn': 'Persian', 'flag': '🇮🇷'},
    {'code': 'ur', 'name': 'الأردية', 'nameEn': 'Urdu', 'flag': '🇵🇰'},
    {'code': 'hi', 'name': 'الهندية', 'nameEn': 'Hindi', 'flag': '🇮🇳'},
    {'code': 'bn', 'name': 'البنغالية', 'nameEn': 'Bengali', 'flag': '🇧🇩'},
    {'code': 'vi', 'name': 'الفيتنامية', 'nameEn': 'Vietnamese', 'flag': '🇻🇳'},
    {'code': 'th', 'name': 'التايلاندية', 'nameEn': 'Thai', 'flag': '🇹🇭'},
    {'code': 'id', 'name': 'الإندونيسية', 'nameEn': 'Indonesian', 'flag': '🇮🇩'},
    {'code': 'ms', 'name': 'الملايو', 'nameEn': 'Malay', 'flag': '🇲🇾'},
    {'code': 'nl', 'name': 'الهولندية', 'nameEn': 'Dutch', 'flag': '🇳🇱'},
    {'code': 'pl', 'name': 'البولندية', 'nameEn': 'Polish', 'flag': '🇵🇱'},
    {'code': 'sv', 'name': 'السويدية', 'nameEn': 'Swedish', 'flag': '🇸🇪'},
    {'code': 'da', 'name': 'الدنماركية', 'nameEn': 'Danish', 'flag': '🇩🇰'},
    {'code': 'no', 'name': 'النرويجية', 'nameEn': 'Norwegian', 'flag': '🇳🇴'},
    {'code': 'fi', 'name': 'الفنلندية', 'nameEn': 'Finnish', 'flag': '🇫🇮'},
    {'code': 'el', 'name': 'اليونانية', 'nameEn': 'Greek', 'flag': '🇬🇷'},
    {'code': 'cs', 'name': 'التشيكية', 'nameEn': 'Czech', 'flag': '🇨🇿'},
    {'code': 'ro', 'name': 'الرومانية', 'nameEn': 'Romanian', 'flag': '🇷🇴'},
    {'code': 'hu', 'name': 'الهنغارية', 'nameEn': 'Hungarian', 'flag': '🇭🇺'},
    {'code': 'sk', 'name': 'السلوفاكية', 'nameEn': 'Slovak', 'flag': '🇸🇰'},
    {'code': 'bg', 'name': 'البلغارية', 'nameEn': 'Bulgarian', 'flag': '🇧🇬'},
    {'code': 'hr', 'name': 'الكرواتية', 'nameEn': 'Croatian', 'flag': '🇭🇷'},
    {'code': 'sr', 'name': 'الصربية', 'nameEn': 'Serbian', 'flag': '🇷🇸'},
    {'code': 'uk', 'name': 'الأوكرانية', 'nameEn': 'Ukrainian', 'flag': '🇺🇦'},
    {'code': 'ca', 'name': 'الكتالونية', 'nameEn': 'Catalan', 'flag': '🇪🇸'},
    {'code': 'he', 'name': 'العبرية', 'nameEn': 'Hebrew', 'flag': '🇮🇱'},
    {'code': 'sw', 'name': 'السواحيلية', 'nameEn': 'Swahili', 'flag': '🇹🇿'},
    {'code': 'af', 'name': 'الأفريقانية', 'nameEn': 'Afrikaans', 'flag': '🇿🇦'},
    {'code': 'sq', 'name': 'الألبانية', 'nameEn': 'Albanian', 'flag': '🇦🇱'},
    {'code': 'hy', 'name': 'الأرمنية', 'nameEn': 'Armenian', 'flag': '🇦🇲'},
    {'code': 'az', 'name': 'الأذربيجانية', 'nameEn': 'Azerbaijani', 'flag': '🇦🇿'},
    {'code': 'eu', 'name': 'الباسكية', 'nameEn': 'Basque', 'flag': '🏳'},
    {'code': 'be', 'name': 'البيلاروسية', 'nameEn': 'Belarusian', 'flag': '🇧🇾'},
    {'code': 'bs', 'name': 'البوسنية', 'nameEn': 'Bosnian', 'flag': '🇧🇦'},
    {'code': 'my', 'name': 'البورمية', 'nameEn': 'Burmese', 'flag': '🇲🇲'},
    {'code': 'zh-TW', 'name': 'الصينية التقليدية', 'nameEn': 'Chinese (Traditional)', 'flag': '🇹🇼'},
    {'code': 'et', 'name': 'الإستونية', 'nameEn': 'Estonian', 'flag': '🇪🇪'},
    {'code': 'gl', 'name': 'الغاليسية', 'nameEn': 'Galician', 'flag': '🏳'},
    {'code': 'ka', 'name': 'الجورجية', 'nameEn': 'Georgian', 'flag': '🇬🇪'},
    {'code': 'gu', 'name': 'الغوجاراتية', 'nameEn': 'Gujarati', 'flag': '🇮🇳'},
    {'code': 'ht', 'name': 'الكريولية الهايتية', 'nameEn': 'Haitian Creole', 'flag': '🇭🇹'},
    {'code': 'ha', 'name': 'الهوسا', 'nameEn': 'Hausa', 'flag': '🇳🇬'},
    {'code': 'iw', 'name': 'العبرية', 'nameEn': 'Hebrew', 'flag': '🇮🇱'},
    {'code': 'ig', 'name': 'الإيغبو', 'nameEn': 'Igbo', 'flag': '🇳🇬'},
    {'code': 'is', 'name': 'الأيسلندية', 'nameEn': 'Icelandic', 'flag': '🇮🇸'},
    {'code': 'kn', 'name': 'الكانادا', 'nameEn': 'Kannada', 'flag': '🇮🇳'},
    {'code': 'kk', 'name': 'الكازاخية', 'nameEn': 'Kazakh', 'flag': '🇰🇿'},
    {'code': 'km', 'name': 'الخميرية', 'nameEn': 'Khmer', 'flag': '🇰🇭'},
    {'code': 'ky', 'name': 'القيرغيزية', 'nameEn': 'Kyrgyz', 'flag': '🇰🇬'},
    {'code': 'lo', 'name': 'اللاوية', 'nameEn': 'Lao', 'flag': '🇱🇦'},
    {'code': 'lv', 'name': 'اللاتفية', 'nameEn': 'Latvian', 'flag': '🇱🇻'},
    {'code': 'lt', 'name': 'الليتوانية', 'nameEn': 'Lithuanian', 'flag': '🇱🇹'},
    {'code': 'lb', 'name': 'اللوكسمبورغية', 'nameEn': 'Luxembourgish', 'flag': '🇱🇺'},
    {'code': 'mk', 'name': 'المقدونية', 'nameEn': 'Macedonian', 'flag': '🇲🇰'},
    {'code': 'mg', 'name': 'الملغاشية', 'nameEn': 'Malagasy', 'flag': '🇲🇬'},
    {'code': 'ml', 'name': 'المالايالامية', 'nameEn': 'Malayalam', 'flag': '🇮🇳'},
    {'code': 'mt', 'name': 'المالطية', 'nameEn': 'Maltese', 'flag': '🇲🇹'},
    {'code': 'mr', 'name': 'الماراثية', 'nameEn': 'Marathi', 'flag': '🇮🇳'},
    {'code': 'mn', 'name': 'المنغولية', 'nameEn': 'Mongolian', 'flag': '🇲🇳'},
    {'code': 'ne', 'name': 'النيبالية', 'nameEn': 'Nepali', 'flag': '🇳🇵'},
    {'code': 'ps', 'name': 'البشتونية', 'nameEn': 'Pashto', 'flag': '🇦🇫'},
    {'code': 'pa', 'name': 'البنجابية', 'nameEn': 'Punjabi', 'flag': '🇮🇳'},
    {'code': 'si', 'name': 'السنهالية', 'nameEn': 'Sinhala', 'flag': '🇱🇰'},
    {'code': 'sl', 'name': 'السلوفينية', 'nameEn': 'Slovenian', 'flag': '🇸🇮'},
    {'code': 'so', 'name': 'الصومالية', 'nameEn': 'Somali', 'flag': '🇸🇴'},
    {'code': 'su', 'name': 'السوندانية', 'nameEn': 'Sundanese', 'flag': '🇮🇩'},
    {'code': 'tl', 'name': 'الفلبينية', 'nameEn': 'Filipino', 'flag': '🇵🇭'},
    {'code': 'tg', 'name': 'الطاجيكية', 'nameEn': 'Tajik', 'flag': '🇹🇯'},
    {'code': 'ta', 'name': 'التاميلية', 'nameEn': 'Tamil', 'flag': '🇮🇳'},
    {'code': 'te', 'name': 'التيلوغو', 'nameEn': 'Telugu', 'flag': '🇮🇳'},
    {'code': 'tk', 'name': 'التركمانية', 'nameEn': 'Turkmen', 'flag': '🇹🇲'},
    {'code': 'uz', 'name': 'الأوزبكية', 'nameEn': 'Uzbek', 'flag': '🇺🇿'},
    {'code': 'cy', 'name': 'الويلزية', 'nameEn': 'Welsh', 'flag': '🏴󠁧󠁢󠁷󠁬󠁳󠁿'},
    {'code': 'xh', 'name': 'الخوسا', 'nameEn': 'Xhosa', 'flag': '🇿🇦'},
    {'code': 'yi', 'name': 'اليديشية', 'nameEn': 'Yiddish', 'flag': '🏳'},
    {'code': 'yo', 'name': 'اليوروبا', 'nameEn': 'Yoruba', 'flag': '🇳🇬'},
    {'code': 'zu', 'name': 'الزولو', 'nameEn': 'Zulu', 'flag': '🇿🇦'},
  ];
}
