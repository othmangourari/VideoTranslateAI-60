import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project_model.dart';
import '../../providers/projects_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/video_service.dart';
import '../../widgets/project_card.dart';
import '../../widgets/language_selector_bottom_sheet.dart';
import '../../router/app_router.dart';

/// الشاشة الرئيسية
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final permission = await Permission.storage.request();
    if (!permission.isGranted && !permission.isLimited) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LanguageProvider>().isArabic
                ? 'يرجى منح إذن الوصول إلى الملفات'
                : 'Please grant file access permission',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.path != null) {
        await _processSelectedVideo(file.path!);
      }
    }
  }

  Future<void> _recordVideo() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى منح إذن الكاميرا'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(hours: 5),
    );

    if (video != null) {
      await _processSelectedVideo(video.path);
    }
  }

  Future<void> _processSelectedVideo(String videoPath) async {
    if (!mounted) return;
    final isArabic = context.read<LanguageProvider>().isArabic;

    // عرض نافذة اختيار اللغة
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LanguageSelectorBottomSheet(),
    );

    if (result == null || !mounted) return;

    // الحصول على معلومات الفيديو
    final videoInfo = await VideoService.instance.getVideoInfo(videoPath);
    if (!mounted) return;

    final project = ProjectModel(
      id: const Uuid().v4(),
      name: videoInfo?.name.replaceAll(RegExp(r'\.[^.]+$'), '') ??
          'مشروع ${DateTime.now().millisecondsSinceEpoch}',
      videoPath: videoPath,
      videoName: videoInfo?.name ?? 'video.mp4',
      videoSizeMB: videoInfo?.sizeMB ?? 0,
      videoDurationSeconds: videoInfo?.durationSeconds ?? 0,
      status: ProjectStatus.pending,
      sourceLanguage: result['source'] ?? 'ar',
      targetLanguage: result['target'] ?? 'en',
      originalText: '',
      translatedText: '',
      progressPercent: 0,
      createdAt: DateTime.now(),
    );

    await context.read<ProjectsProvider>().addProject(project);

    if (!mounted) return;
    context.push(AppRoutes.processing(project.id), extra: {
      'videoPath': videoPath,
      'sourceLanguage': result['source'],
      'targetLanguage': result['target'],
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final themeProvider = context.watch<ThemeProvider>();
    final projectsProvider = context.watch<ProjectsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar مخصص
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.translate_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'VideoTranslate AI',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isArabic
                                          ? 'ترجم مقاطعك بالذكاء الاصطناعي'
                                          : 'Translate videos with AI',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 13,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // زر تغيير اللغة
                                    IconButton(
                                      onPressed: () => context
                                          .read<LanguageProvider>()
                                          .toggleLanguage(),
                                      icon: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          isArabic ? 'EN' : 'AR',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      tooltip:
                                          isArabic ? 'English' : 'العربية',
                                    ),
                                    // زر الثيم
                                    IconButton(
                                      onPressed: () => context
                                          .read<ThemeProvider>()
                                          .toggleTheme(),
                                      icon: Icon(
                                        themeProvider.isDark
                                            ? Icons.light_mode_rounded
                                            : Icons.dark_mode_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // المحتوى
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // أزرار الإجراءات الرئيسية
                    _buildActionButtons(context, isArabic, colorScheme),

                    const SizedBox(height: 28),

                    // آخر المشاريع
                    _buildRecentProjects(
                        context, isArabic, projectsProvider, isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, bool isArabic, ColorScheme colorScheme) {
    return Column(
      children: [
        // زر اختيار فيديو
        _ActionButton(
          icon: Icons.video_library_rounded,
          title: isArabic ? 'اختيار فيديو' : 'Pick Video',
          subtitle: isArabic
              ? 'من معرض الصور والفيديوهات'
              : 'From gallery',
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          onTap: _pickVideo,
        ),

        const SizedBox(height: 12),

        // زر تسجيل فيديو
        _ActionButton(
          icon: Icons.videocam_rounded,
          title: isArabic ? 'تسجيل فيديو' : 'Record Video',
          subtitle: isArabic
              ? 'تسجيل مباشر من الكاميرا'
              : 'Record with camera',
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.secondary, Color(0xFF00A09C)],
          ),
          onTap: _recordVideo,
        ),
      ],
    );
  }

  Widget _buildRecentProjects(
    BuildContext context,
    bool isArabic,
    ProjectsProvider provider,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isArabic ? 'آخر المشاريع' : 'Recent Projects',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                  ),
            ),
            if (provider.allProjects.isNotEmpty)
              TextButton(
                onPressed: () => context.go('/projects'),
                child: Text(
                  isArabic ? 'عرض الكل' : 'See All',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (provider.recentProjects.isEmpty)
          _buildEmptyState(isArabic, isDark)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.recentProjects.length,
            itemBuilder: (context, index) {
              final project = provider.recentProjects[index];
              return ProjectCard(
                project: project,
                onTap: () {
                  if (project.status == ProjectStatus.completed) {
                    context.push(AppRoutes.projectDetail(project.id));
                  } else if (project.status == ProjectStatus.processing ||
                      project.status == ProjectStatus.paused) {
                    context.push(AppRoutes.processing(project.id));
                  } else {
                    context.push(AppRoutes.projectDetail(project.id));
                  }
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(bool isArabic, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark
            : AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 60,
            color: AppColors.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لا توجد مشاريع بعد' : 'No projects yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'ابدأ بتحديد فيديو أو تسجيل واحد جديد'
                : 'Start by picking a video or recording a new one',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

// ويدجت زر الإجراء
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
