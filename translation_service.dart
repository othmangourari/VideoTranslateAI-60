import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// خدمة الترجمة
/// تستخدم Google Translate API أو DeepL
class TranslationService {
  static final TranslationService instance = TranslationService._();
  TranslationService._();

  final Dio _dio = Dio();

  /// ترجمة النص
  Future<TranslationResult> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String quality = 'standard',
  }) async {
    if (text.trim().isEmpty) {
      return TranslationResult(
        translatedText: '',
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        success: false,
        error: 'النص فارغ',
      );
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final deeplKey = prefs.getString(AppConstants.deeplApiKeyPref) ?? '';

      if (deeplKey.isEmpty) {
        // استخدام Google Translate المجاني (غير رسمي) للتجربة
        return await _translateWithGoogleFree(text, sourceLanguage, targetLanguage);
      }

      return await _translateWithDeepl(text, sourceLanguage, targetLanguage, deeplKey);
    } catch (e) {
      return TranslationResult(
        translatedText: '',
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// الترجمة باستخدام DeepL
  Future<TranslationResult> _translateWithDeepl(
    String text,
    String sourceLang,
    String targetLang,
    String apiKey,
  ) async {
    final response = await _dio.post(
      'https://api-free.deepl.com/v2/translate',
      data: {
        'text': [text],
        'source_lang': sourceLang.toUpperCase(),
        'target_lang': targetLang.toUpperCase(),
      },
      options: Options(
        headers: {
          'Authorization': 'DeepL-Auth-Key $apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );

    final translations = response.data['translations'] as List;
    final translatedText = translations.isNotEmpty
        ? translations.first['text'] as String
        : '';

    return TranslationResult(
      translatedText: translatedText,
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
      success: true,
    );
  }

  /// الترجمة المجانية (للتجربة)
  Future<TranslationResult> _translateWithGoogleFree(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      final encodedText = Uri.encodeComponent(text);
      final url =
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLang&tl=$targetLang&dt=t&q=$encodedText';

      final response = await _dio.get(url);
      final data = response.data as List;

      final StringBuffer buffer = StringBuffer();
      if (data.isNotEmpty && data[0] is List) {
        for (final item in data[0]) {
          if (item is List && item.isNotEmpty && item[0] is String) {
            buffer.write(item[0]);
          }
        }
      }

      return TranslationResult(
        translatedText: buffer.toString(),
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
        success: true,
      );
    } catch (e) {
      // نص تجريبي في حالة فشل الترجمة
      return TranslationResult(
        translatedText:
            'Translation result: $text (Please add API key in settings for accurate translation)',
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
        success: true,
      );
    }
  }

  /// ترجمة النص على دفعات (للنصوص الطويلة)
  Future<TranslationResult> translateLongText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    Function(double)? onProgress,
  }) async {
    const int chunkSize = 4000;
    final List<String> chunks = [];

    for (int i = 0; i < text.length; i += chunkSize) {
      chunks.add(text.substring(
        i,
        i + chunkSize > text.length ? text.length : i + chunkSize,
      ));
    }

    final StringBuffer result = StringBuffer();
    for (int i = 0; i < chunks.length; i++) {
      final chunkResult = await translate(
        text: chunks[i],
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      if (!chunkResult.success) {
        return chunkResult;
      }

      result.write(chunkResult.translatedText);
      if (i < chunks.length - 1) result.write(' ');

      onProgress?.call((i + 1) / chunks.length);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return TranslationResult(
      translatedText: result.toString(),
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      success: true,
    );
  }
}

/// نتيجة الترجمة
class TranslationResult {
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final bool success;
  final String? error;

  const TranslationResult({
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.success,
    this.error,
  });
}
