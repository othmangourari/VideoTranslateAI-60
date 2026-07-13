import 'package:flutter/material.dart';

/// ألوان التطبيق الرئيسية
class AppColors {
  AppColors._();

  // اللون الرئيسي - بنفسجي راقٍ
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF9B8FFF);
  static const Color primaryDark = Color(0xFF4A3DB5);

  // اللون الثانوي - فيروزي
  static const Color secondary = Color(0xFF00CEC9);
  static const Color secondaryLight = Color(0xFF55EFC4);

  // ألوان التمييز
  static const Color accent = Color(0xFFFF7675);
  static const Color accentGold = Color(0xFFFDCB6E);

  // ألوان الخلفية - الوضع الفاتح
  static const Color backgroundLight = Color(0xFFF8F7FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // ألوان الخلفية - الوضع الداكن
  static const Color backgroundDark = Color(0xFF0F0E17);
  static const Color surfaceDark = Color(0xFF1A1929);
  static const Color cardDark = Color(0xFF252438);

  // ألوان النص - الوضع الفاتح
  static const Color textPrimaryLight = Color(0xFF2D3436);
  static const Color textSecondaryLight = Color(0xFF636E72);
  static const Color textHintLight = Color(0xFFB2BEC3);

  // ألوان النص - الوضع الداكن
  static const Color textPrimaryDark = Color(0xFFF8F7FF);
  static const Color textSecondaryDark = Color(0xFFAEA9C3);
  static const Color textHintDark = Color(0xFF6C6895);

  // ألوان الحالات
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFFF7675);
  static const Color info = Color(0xFF74B9FF);

  // تدرجات لونية
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6C5CE7), Color(0xFF4A3DB5)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF252438), Color(0xFF1A1929)],
  );
}
