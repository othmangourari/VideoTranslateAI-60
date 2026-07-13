import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';

/// فئة الترجمة للتطبيق
/// يتم إنشاء هذا الملف تلقائياً من ملفات .arb
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  bool get isArabic => locale.languageCode == 'ar';

  String get appTitle => isArabic ? 'VideoTranslate AI' : 'VideoTranslate AI';
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get projects => isArabic ? 'مشاريعي' : 'Projects';
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get pickVideo => isArabic ? 'اختيار فيديو' : 'Pick Video';
  String get recordVideo => isArabic ? 'تسجيل فيديو' : 'Record Video';
  String get recentProjects => isArabic ? 'آخر المشاريع' : 'Recent Projects';
  String get seeAll => isArabic ? 'عرض الكل' : 'See All';
  String get noProjects => isArabic ? 'لا توجد مشاريع بعد' : 'No projects yet';
  String get processing => isArabic ? 'معالجة الفيديو' : 'Processing Video';
  String get completed => isArabic ? 'مكتمل' : 'Completed';
  String get failed => isArabic ? 'فشل' : 'Failed';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get pause => isArabic ? 'إيقاف مؤقت' : 'Pause';
  String get resume => isArabic ? 'استكمال' : 'Resume';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get originalText => isArabic ? 'النص الأصلي' : 'Original Text';
  String get translatedText => isArabic ? 'الترجمة' : 'Translation';
  String get export => isArabic ? 'تصدير ومشاركة' : 'Export & Share';
  String get saved => isArabic ? 'تم الحفظ' : 'Saved';
  String get copied => isArabic ? 'تم النسخ' : 'Copied';
  String get selectLanguages => isArabic ? 'اختر اللغات' : 'Select Languages';
  String get startProcessing => isArabic ? 'بدء المعالجة' : 'Start Processing';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
