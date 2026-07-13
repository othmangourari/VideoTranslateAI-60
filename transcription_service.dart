import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// خدمة تحويل الكلام إلى نص
/// تستخدم OpenAI Whisper API
class TranscriptionService {
  static final TranscriptionService instance = TranscriptionService._();
  TranscriptionService._();

  final Dio _dio = Dio();
  bool _isCancelled = false;

  /// تحويل الصوت إلى نص
  Future<TranscriptionResult> transcribeAudio({
    required String audioPath,
    required String language,
    required String quality,
    Function(double)? onProgress,
  }) async {
    _isCancelled = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString(AppConstants.openAiApiKeyPref) ?? '';

      if (apiKey.isEmpty) {
        // وضع المحاكاة للتجربة بدون API Key
        return await _simulateTranscription(audioPath, onProgress);
      }

      final audioFile = File(audioPath);
      if (!audioFile.existsSync()) {
        throw Exception('ملف الصوت غير موجود');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioPath,
          filename: 'audio.mp3',
        ),
        'model': _getModel(quality),
        'language': language,
        'response_format': 'json',
        'temperature': 0,
      });

      if (_isCancelled) {
        throw Exception('تم إلغاء العملية');
      }

      final response = await _dio.post(
        'https://api.openai.com/v1/audio/transcriptions',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress?.call(sent / total * 0.5);
          }
        },
      );

      if (_isCancelled) {
        throw Exception('تم إلغاء العملية');
      }

      onProgress?.call(1.0);

      final text = response.data['text'] as String? ?? '';
      return TranscriptionResult(
        text: text,
        language: language,
        success: true,
      );
    } catch (e) {
      if (e.toString().contains('إلغاء')) {
        return TranscriptionResult(
          text: '',
          language: language,
          success: false,
          error: 'تم إلغاء العملية',
        );
      }
      return TranscriptionResult(
        text: '',
        language: language,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// محاكاة التحويل للتجربة
  Future<TranscriptionResult> _simulateTranscription(
    String audioPath,
    Function(double)? onProgress,
  ) async {
    for (int i = 0; i <= 100; i += 5) {
      if (_isCancelled) {
        throw Exception('تم إلغاء العملية');
      }
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress?.call(i / 100);
    }

    return TranscriptionResult(
      text:
          'هذا نص تجريبي تم استخراجه من الفيديو. في التطبيق الحقيقي، يتم استخدام OpenAI Whisper API لتحويل الكلام إلى نص بدقة عالية. يرجى إضافة مفتاح API من إعدادات التطبيق للحصول على النتائج الحقيقية.',
      language: 'ar',
      success: true,
    );
  }

  String _getModel(String quality) {
    switch (quality) {
      case 'high':
        return 'whisper-1';
      default:
        return 'whisper-1';
    }
  }

  void cancel() {
    _isCancelled = true;
  }
}

/// نتيجة التحويل
class TranscriptionResult {
  final String text;
  final String language;
  final bool success;
  final String? error;

  const TranscriptionResult({
    required this.text,
    required this.language,
    required this.success,
    this.error,
  });
}
