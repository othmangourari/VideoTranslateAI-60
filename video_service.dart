import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// خدمة معالجة الفيديو
class VideoService {
  static final VideoService instance = VideoService._();
  VideoService._();

  /// استخراج الصوت من الفيديو
  Future<AudioExtractionResult> extractAudio({
    required String videoPath,
    required String quality,
    Function(double)? onProgress,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = path.join(
        tempDir.path,
        'audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );

      final audioQualityArgs = _getAudioQualityArgs(quality);

      // استخراج الصوت باستخدام FFmpeg
      final session = await FFmpegKit.executeAsync(
        '-i "$videoPath" $audioQualityArgs -y "$outputPath"',
        (session) async {
          // اكتمل
        },
        (log) {
          // سجل FFmpeg - يمكن استخدامه لتتبع التقدم
          final message = log.getMessage();
          if (message.contains('time=')) {
            // حساب التقدم من وقت المعالجة
          }
        },
        (statistics) {
          // إحصائيات المعالجة
          if (statistics.getTime() > 0) {
            // تحديث شريط التقدم
          }
        },
      );

      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        onProgress?.call(1.0);
        return AudioExtractionResult(
          audioPath: outputPath,
          success: true,
        );
      } else {
        return AudioExtractionResult(
          audioPath: null,
          success: false,
          error: 'فشل استخراج الصوت',
        );
      }
    } catch (e) {
      return AudioExtractionResult(
        audioPath: null,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// الحصول على معلومات الفيديو
  Future<VideoInfo?> getVideoInfo(String videoPath) async {
    try {
      final session = await FFmpegKit.execute(
        '-i "$videoPath" -v quiet -print_format json -show_streams -show_format',
      );

      final output = await session.getOutput();
      if (output == null) return null;

      // تحليل المخرجات
      // في التطبيق الحقيقي، نستخدم ffprobe لاستخراج المعلومات
      final file = File(videoPath);
      final stat = await file.stat();

      return VideoInfo(
        path: videoPath,
        name: path.basename(videoPath),
        sizeMB: stat.size / (1024 * 1024),
        durationSeconds: _parseDuration(output ?? ''),
      );
    } catch (e) {
      final file = File(videoPath);
      final stat = await file.stat();
      return VideoInfo(
        path: videoPath,
        name: path.basename(videoPath),
        sizeMB: stat.size / (1024 * 1024),
        durationSeconds: 0,
      );
    }
  }

  /// حساب مدة الفيديو من مخرجات FFmpeg
  int _parseDuration(String output) {
    final regex = RegExp(r'Duration: (\d+):(\d+):(\d+)');
    final match = regex.firstMatch(output);
    if (match == null) return 0;

    final hours = int.parse(match.group(1)!);
    final minutes = int.parse(match.group(2)!);
    final seconds = int.parse(match.group(3)!);

    return hours * 3600 + minutes * 60 + seconds;
  }

  /// معلمات جودة الصوت
  String _getAudioQualityArgs(String quality) {
    switch (quality) {
      case 'high':
        return '-vn -acodec libmp3lame -ar 44100 -ab 192k -ac 2';
      case 'medium':
        return '-vn -acodec libmp3lame -ar 44100 -ab 128k -ac 2';
      case 'low':
        return '-vn -acodec libmp3lame -ar 22050 -ab 64k -ac 1';
      default:
        return '-vn -acodec libmp3lame -ar 44100 -ab 128k -ac 2';
    }
  }

  /// حذف الملفات المؤقتة
  Future<void> clearTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      for (final file in files) {
        if (file.path.contains('audio_') || file.path.contains('thumb_')) {
          await file.delete();
        }
      }
    } catch (_) {}
  }
}

/// نتيجة استخراج الصوت
class AudioExtractionResult {
  final String? audioPath;
  final bool success;
  final String? error;

  const AudioExtractionResult({
    required this.audioPath,
    required this.success,
    this.error,
  });
}

/// معلومات الفيديو
class VideoInfo {
  final String path;
  final String name;
  final double sizeMB;
  final int durationSeconds;

  const VideoInfo({
    required this.path,
    required this.name,
    required this.sizeMB,
    required this.durationSeconds,
  });
}
