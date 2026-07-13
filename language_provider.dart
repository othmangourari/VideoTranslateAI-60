import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// مزود اللغة - يتحكم في لغة التطبيق
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(AppConstants.languagePref) ?? 'ar';
    _locale = Locale(savedLang);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languagePref, languageCode);
  }

  Future<void> toggleLanguage() async {
    if (isArabic) {
      await setLanguage('en');
    } else {
      await setLanguage('ar');
    }
  }
}
