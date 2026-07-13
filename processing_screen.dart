import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project_model.dart';
import '../../providers/projects_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/video_service.dart';
import '../../services/transcription_service.dart';
import '../../services/translation_service.dart';
import '../../router/app_router.dart';

/// شاشة معالجة الفيديو
class ProcessingScreen extends StatefulWidget {
  final String projectId;
  final Map<String, dynamic>? extra;

  const ProcessingScreen({
    super.key,
    required this.projectId,
    this.extra,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  double _overallProgress = 0;
  String _currentStep = '';
  String _stepDetail = '';
  bool _isProcessing = false;
  bool _isPaused = false;
  bool _isCompleted = false;
  bool _isFailed = false;
  String? _errorMessage;

  final List<ProcessingStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSteps();
      _startProcessing();
    });
  }

  void _initSteps() {
    final isArabic = context.read<LanguageProvider>().isArabic;
    setState(() {
      _steps.addAll([
        ProcessingStep(
          id: 'extract',
          title: isArabic ? 'استخراج الصوت' : 'Extract Audio',
          icon: Icons.audio_file_rounded,
          progress: 0,
          status: StepStatus.pending,
        ),
        ProcessingStep(
          id: 'transcribe',
          title: isArabic ? 'تحويل الكلام إلى نص' : 'Speech to Text',
          icon: Icons.text_fields_rounded,
          progress: 0,
          status: StepStatus.pending,
        ),
        ProcessingStep(
          id: 'translate',
          title: isArabic ? 'الترجمة' : 'Translate',
          icon: Icons.translate_rounded,
          progress: 0,
          status: StepStatus.pending,
        ),
        ProcessingStep(
          id: 'save',
          title: isArabic ? 'حفظ النتائج' : 'Save Results',
          icon: Icons.save_rounded,
          progress: 0,
          status: StepStatus.pending,
        ),
      ]);
    });
  }

  Future<void> _startProcessing() async {
    if (_isProcessing) return;

    final project =
        context.read<ProjectsProvider>().getProjectById(widget.projectId);
    if (project == null) return;

    setState(() {
      _isProcessing = true;
      _isFailed = false;
      _errorMessage = null;
    });

    try {
      // الخطوة 1: استخراج الصوت
      await _runStep(0, () async {
        final result = await VideoService.instance.extractAudio(
          videoPath: project.videoPath,
          quality: 'medium',
          onProgress: (p) {
            if (!_isPaused) _updateStepProgress(0, p);
          },
        );

        if (!result.success) {
          throw Exception(result.error ?? 'فشل استخراج الصوت');
        }

        // تحديث المشروع بمسار الصوت
        await _updateProject(project.copyWith(
          audioPath: result.audioPath,
          status: ProjectStatus.processing,
          progressPercent: 25,
        ));

        return result.audioPath;
      });

      if (_isPaused) return;
      final updatedProject =
          context.read<ProjectsProvider>().getProjectById(widget.projectId)!;

      // الخطوة 2: تحويل الكلام إلى نص
      String transcribedText = '';
      await _runStep(1, () async {
        final result = await TranscriptionService.instance.transcribeAudio(
          audioPath: updatedProject.audioPath ?? project.videoPath,
          language: project.sourceLanguage,
          quality: 'medium',
          onProgress: (p) {
            if (!_isPaused) _updateStepProgress(1, p);
          },
        );

        if (!result.success) {
          throw Exception(result.error ?? 'فشل التحويل إلى نص');
        }

        transcribedText = result.text;
        await _updateProject(updatedProject.copyWith(
          originalText: transcribedText,
          progressPercent: 50,
        ));

        return transcribedText;
      });

      if (_isPaused) return;

      // الخطوة 3: الترجمة
      String translatedText = '';
      await _runStep(2, () async {
        final result = await TranslationService.instance.translateLongText(
          text: transcribedText,
          sourceLanguage: project.sourceLanguage,
          targetLanguage: project.targetLanguage,
          onProgress: (p) {
            if (!_isPaused) _updateStepProgress(2, p);
          },
        );

        if (!result.success) {
          throw Exception(result.error ?? 'فشل الترجمة');
        }

        translatedText = result.translatedText;
        await _updateProject(updatedProject.copyWith(
          translatedText: translatedText,
          progressPercent: 85,
        ));

        return translatedText;
      });

      if (_isPaused) return;

      // الخطوة 4: الحفظ
      await _runStep(3, () async {
        _updateStepProgress(3, 0.5);
        await Future.delayed(const Duration(milliseconds: 500));

        final finalProject = context
            .read<ProjectsProvider>()
            .getProjectById(widget.projectId)!;
        await _updateProject(finalProject.copyWith(
          status: ProjectStatus.completed,
          progressPercent: 100,
          updatedAt: DateTime.now(),
        ));

        _updateStepProgress(3, 1.0);
        return true;
      });

      setState(() {
        _isCompleted = true;
        _isProcessing = false;
        _overallProgress = 1.0;
      });

      // الانتقال إلى شاشة الترجمة
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.replace(AppRoutes.translation(widget.projectId));
      }
    } catch (e) {
      if (!_isPaused) {
        setState(() {
          _isFailed = true;
          _isProcessing = false;
          _errorMessage = e.toString();
        });

        await _updateProject(project.copyWith(
          status: ProjectStatus.failed,
        ));
      }
    }
  }

  Future<dynamic> _runStep(int stepIndex, Future<dynamic> Function() action) async {
    if (_isPaused) return null;

    setState(() {
      if (stepIndex < _steps.length) {
        _steps[stepIndex].status = StepStatus.running;
        _currentStep = _steps[stepIndex].title;
      }
    });

    final result = await action();

    setState(() {
      if (stepIndex < _steps.length) {
        _steps[stepIndex].status = StepStatus.completed;
        _steps[stepIndex].progress = 1.0;
      }
      _overallProgress = (stepIndex + 1) / _steps.length;
    });

    return result;
  }

  void _updateStepProgress(int stepIndex, double progress) {
    if (!mounted || stepIndex >= _steps.length) return;
    setState(() {
      _steps[stepIndex].progress = progress;
      _overallProgress = (stepIndex / _steps.length) + (progress / _steps.length);
    });
  }

  Future<void> _updateProject(ProjectModel project) async {
    await context.read<ProjectsProvider>().updateProject(project);
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (!_isPaused) {
      _startProcessing();
    } else {
      TranscriptionService.instance.cancel();
    }
  }

  void _cancel() {
    TranscriptionService.instance.cancel();
    context.pop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final project =
        context.watch<ProjectsProvider>().getProjectById(widget.projectId);

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'معالجة الفيديو' : 'Processing Video'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cancel,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // معلومات الفيديو
            if (project != null) _buildVideoInfo(project, isDark),

            const SizedBox(height: 24),

            // المؤشر الدائري الكبير
            _buildCircularProgress(colorScheme),

            const SizedBox(height: 32),

            // خطوات المعالجة
            _buildStepsList(isDark),

            const SizedBox(height: 32),

            // أزرار التحكم
            _buildControls(isArabic, colorScheme),

            if (_isFailed) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(isArabic),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo(ProjectModel project, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.video_file_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      project.sizeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      project.durationText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(ColorScheme colorScheme) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) {
            return Transform.scale(
              scale: _isProcessing && !_isPaused && !_isCompleted
                  ? _pulseAnim.value
                  : 1.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: _overallProgress,
                      strokeWidth: 8,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isCompleted)
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 48)
                      else if (_isFailed)
                        Icon(Icons.error_rounded,
                            color: AppColors.error, size: 48)
                      else if (_isPaused)
                        Icon(Icons.pause_circle_rounded,
                            color: colorScheme.primary, size: 48)
                      else
                        Icon(Icons.translate_rounded,
                            color: colorScheme.primary, size: 40),
                      const SizedBox(height: 4),
                      Text(
                        '${(_overallProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          _isCompleted
              ? 'تمت المعالجة بنجاح! ✓'
              : _isFailed
                  ? 'حدث خطأ أثناء المعالجة'
                  : _isPaused
                      ? 'تم الإيقاف المؤقت'
                      : _currentStep.isNotEmpty
                          ? _currentStep
                          : 'جاري الاستعداد...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _isCompleted
                ? AppColors.success
                : _isFailed
                    ? AppColors.error
                    : null,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildStepsList(bool isDark) {
    return Column(
      children: _steps.asMap().entries.map((entry) {
        final step = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _StepItem(step: step, isDark: isDark),
        );
      }).toList(),
    );
  }

  Widget _buildControls(bool isArabic, ColorScheme colorScheme) {
    if (_isCompleted) {
      return ElevatedButton.icon(
        onPressed: () =>
            context.replace(AppRoutes.translation(widget.projectId)),
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(isArabic ? 'عرض النتائج' : 'View Results'),
      );
    }

    if (_isFailed) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _cancel,
              icon: const Icon(Icons.close_rounded),
              label: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _startProcessing,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _cancel,
            icon: const Icon(Icons.close_rounded),
            label: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _togglePause,
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
            label: Text(_isPaused
                ? (isArabic ? 'استكمال' : 'Resume')
                : (isArabic ? 'إيقاف مؤقت' : 'Pause')),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? (isArabic ? 'حدث خطأ غير معروف' : 'Unknown error occurred'),
              style: const TextStyle(
                color: AppColors.error,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final ProcessingStep step;
  final bool isDark;

  const _StepItem({required this.step, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Widget statusWidget;

    switch (step.status) {
      case StepStatus.completed:
        statusColor = AppColors.success;
        statusWidget = const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 22);
        break;
      case StepStatus.running:
        statusColor = AppColors.primary;
        statusWidget = SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            value: step.progress > 0 ? step.progress : null,
            strokeWidth: 2.5,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
        break;
      case StepStatus.failed:
        statusColor = AppColors.error;
        statusWidget =
            const Icon(Icons.cancel_rounded, color: AppColors.error, size: 22);
        break;
      default:
        statusColor = Colors.grey;
        statusWidget =
            Icon(Icons.radio_button_unchecked, color: Colors.grey[400], size: 22);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark
            : statusColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: step.status == StepStatus.running
              ? statusColor.withOpacity(0.3)
              : statusColor.withOpacity(0.1),
          width: step.status == StepStatus.running ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(step.icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: step.status == StepStatus.pending
                        ? Colors.grey
                        : null,
                    fontFamily: 'Cairo',
                    fontSize: 14,
                  ),
                ),
                if (step.status == StepStatus.running && step.progress > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LinearProgressIndicator(
                      value: step.progress,
                      backgroundColor: statusColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          statusWidget,
        ],
      ),
    );
  }
}

enum StepStatus { pending, running, completed, failed }

class ProcessingStep {
  final String id;
  final String title;
  final IconData icon;
  double progress;
  StepStatus status;

  ProcessingStep({
    required this.id,
    required this.title,
    required this.icon,
    required this.progress,
    required this.status,
  });
}
