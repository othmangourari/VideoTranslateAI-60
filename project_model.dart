/// نموذج بيانات المشروع
class ProjectModel {
  final String id;
  final String name;
  final String videoPath;
  final String videoName;
  final double videoSizeMB;
  final int videoDurationSeconds;
  final String status; // pending, processing, completed, failed, paused
  final String sourceLanguage;
  final String targetLanguage;
  final String originalText;
  final String translatedText;
  final double progressPercent;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? thumbnailPath;
  final String? audioPath;
  final bool isStarred;
  final Map<String, dynamic>? metadata;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.videoPath,
    required this.videoName,
    required this.videoSizeMB,
    required this.videoDurationSeconds,
    required this.status,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.originalText,
    required this.translatedText,
    required this.progressPercent,
    required this.createdAt,
    this.updatedAt,
    this.thumbnailPath,
    this.audioPath,
    this.isStarred = false,
    this.metadata,
  });

  /// الحالة بالعربية
  String get statusAr {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'processing':
        return 'جاري المعالجة';
      case 'completed':
        return 'مكتمل';
      case 'failed':
        return 'فشل';
      case 'paused':
        return 'متوقف مؤقتاً';
      default:
        return status;
    }
  }

  /// مدة الفيديو كنص
  String get durationText {
    final hours = videoDurationSeconds ~/ 3600;
    final minutes = (videoDurationSeconds % 3600) ~/ 60;
    final seconds = videoDurationSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// حجم الفيديو كنص
  String get sizeText {
    if (videoSizeMB >= 1024) {
      return '${(videoSizeMB / 1024).toStringAsFixed(1)} GB';
    }
    return '${videoSizeMB.toStringAsFixed(1)} MB';
  }

  /// نسخ الكائن مع تعديلات
  ProjectModel copyWith({
    String? id,
    String? name,
    String? videoPath,
    String? videoName,
    double? videoSizeMB,
    int? videoDurationSeconds,
    String? status,
    String? sourceLanguage,
    String? targetLanguage,
    String? originalText,
    String? translatedText,
    double? progressPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnailPath,
    String? audioPath,
    bool? isStarred,
    Map<String, dynamic>? metadata,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      videoPath: videoPath ?? this.videoPath,
      videoName: videoName ?? this.videoName,
      videoSizeMB: videoSizeMB ?? this.videoSizeMB,
      videoDurationSeconds: videoDurationSeconds ?? this.videoDurationSeconds,
      status: status ?? this.status,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      progressPercent: progressPercent ?? this.progressPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      audioPath: audioPath ?? this.audioPath,
      isStarred: isStarred ?? this.isStarred,
      metadata: metadata ?? this.metadata,
    );
  }

  /// تحويل إلى Map لقاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'video_path': videoPath,
      'video_name': videoName,
      'video_size_mb': videoSizeMB,
      'video_duration_seconds': videoDurationSeconds,
      'status': status,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'original_text': originalText,
      'translated_text': translatedText,
      'progress_percent': progressPercent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'thumbnail_path': thumbnailPath,
      'audio_path': audioPath,
      'is_starred': isStarred ? 1 : 0,
    };
  }

  /// إنشاء من Map
  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      name: map['name'] as String,
      videoPath: map['video_path'] as String,
      videoName: map['video_name'] as String,
      videoSizeMB: (map['video_size_mb'] as num).toDouble(),
      videoDurationSeconds: map['video_duration_seconds'] as int,
      status: map['status'] as String,
      sourceLanguage: map['source_language'] as String,
      targetLanguage: map['target_language'] as String,
      originalText: map['original_text'] as String? ?? '',
      translatedText: map['translated_text'] as String? ?? '',
      progressPercent: (map['progress_percent'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      thumbnailPath: map['thumbnail_path'] as String?,
      audioPath: map['audio_path'] as String?,
      isStarred: (map['is_starred'] as int) == 1,
    );
  }
}

/// حالات المشروع
class ProjectStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String failed = 'failed';
  static const String paused = 'paused';
}
