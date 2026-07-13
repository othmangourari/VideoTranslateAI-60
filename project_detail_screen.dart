import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project_model.dart';
import '../../providers/projects_provider.dart';
import '../../providers/language_provider.dart';
import '../../router/app_router.dart';

/// شاشة تفاصيل المشروع
class ProjectDetailScreen extends StatelessWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final project = context.watch<ProjectsProvider>().getProjectById(projectId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(isArabic ? 'المشروع غير موجود' : 'Project not found')),
      );
    }

    Color statusColor;
    switch (project.status) {
      case ProjectStatus.completed:
        statusColor = AppColors.success;
        break;
      case ProjectStatus.processing:
        statusColor = AppColors.warning;
        break;
      case ProjectStatus.failed:
        statusColor = AppColors.error;
        break;
      case ProjectStatus.paused:
        statusColor = AppColors.info;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.video_file_rounded, color: Colors.white, size: 44),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        project.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الحالة
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        project.statusAr,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // معلومات الفيديو
                  _buildInfoCard(
                    context,
                    isArabic ? 'معلومات الفيديو' : 'Video Info',
                    Icons.video_file_rounded,
                    [
                      _InfoRow(
                        label: isArabic ? 'اسم الملف' : 'File Name',
                        value: project.videoName,
                      ),
                      _InfoRow(
                        label: isArabic ? 'المدة' : 'Duration',
                        value: project.durationText,
                      ),
                      _InfoRow(
                        label: isArabic ? 'الحجم' : 'Size',
                        value: project.sizeText,
                      ),
                      _InfoRow(
                        label: isArabic ? 'تاريخ الإنشاء' : 'Created',
                        value: _formatDate(project.createdAt),
                      ),
                    ],
                    isDark,
                    colorScheme,
                  ),

                  const SizedBox(height: 16),

                  // إعدادات الترجمة
                  _buildInfoCard(
                    context,
                    isArabic ? 'إعدادات الترجمة' : 'Translation Settings',
                    Icons.translate_rounded,
                    [
                      _InfoRow(
                        label: isArabic ? 'اللغة الأصلية' : 'Source Language',
                        value: project.sourceLanguage.toUpperCase(),
                      ),
                      _InfoRow(
                        label: isArabic ? 'لغة الترجمة' : 'Target Language',
                        value: project.targetLanguage.toUpperCase(),
                      ),
                      _InfoRow(
                        label: isArabic ? 'نسبة الإنجاز' : 'Progress',
                        value: '${project.progressPercent.toInt()}%',
                      ),
                    ],
                    isDark,
                    colorScheme,
                  ),

                  if (project.originalText.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildTextPreview(
                      context,
                      isArabic ? 'معاينة النص' : 'Text Preview',
                      project.originalText,
                      isDark,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // أزرار الإجراء
                  _buildActionButtons(context, project, isArabic, colorScheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    List<_InfoRow> rows,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      row.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTextPreview(
      BuildContext context, String title, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text.length > 200 ? '${text.substring(0, 200)}...' : text,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[700],
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ProjectModel project,
    bool isArabic,
    ColorScheme colorScheme,
  ) {
    if (project.status == ProjectStatus.completed) {
      return ElevatedButton.icon(
        onPressed: () => context.push(AppRoutes.translation(project.id)),
        icon: const Icon(Icons.translate_rounded),
        label: Text(isArabic ? 'عرض النتائج والترجمة' : 'View Results & Translation'),
      );
    }

    if (project.status == ProjectStatus.failed || project.status == ProjectStatus.paused) {
      return ElevatedButton.icon(
        onPressed: () => context.push(AppRoutes.processing(project.id)),
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(isArabic ? 'استكمال المعالجة' : 'Continue Processing'),
      );
    }

    if (project.status == ProjectStatus.processing) {
      return ElevatedButton.icon(
        onPressed: () => context.push(AppRoutes.processing(project.id)),
        icon: const Icon(Icons.sync_rounded),
        label: Text(isArabic ? 'عرض التقدم' : 'View Progress'),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
}
