import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/project_model.dart';
import '../providers/language_provider.dart';

/// بطاقة عرض المشروع
class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onLongPress,
  });

  Color get _statusColor {
    switch (project.status) {
      case ProjectStatus.completed:
        return AppColors.success;
      case ProjectStatus.processing:
        return AppColors.warning;
      case ProjectStatus.failed:
        return AppColors.error;
      case ProjectStatus.paused:
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (project.status) {
      case ProjectStatus.completed:
        return Icons.check_circle_rounded;
      case ProjectStatus.processing:
        return Icons.sync_rounded;
      case ProjectStatus.failed:
        return Icons.error_rounded;
      case ProjectStatus.paused:
        return Icons.pause_circle_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // أيقونة الفيديو
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.video_file_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            fontFamily: 'Cairo',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (project.isStarred)
                        const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Text(
                        project.durationText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.storage_rounded, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Text(
                        project.sizeText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${project.sourceLanguage.toUpperCase()} → ${project.targetLanguage.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.primary,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (project.status == ProjectStatus.processing)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: LinearProgressIndicator(
                        value: project.progressPercent / 100,
                        backgroundColor: _statusColor.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // الحالة
            Column(
              children: [
                Icon(_statusIcon, color: _statusColor, size: 20),
                const SizedBox(height: 4),
                Text(
                  project.statusAr,
                  style: TextStyle(
                    fontSize: 10,
                    color: _statusColor,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
