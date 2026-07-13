import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project_model.dart';
import '../../providers/projects_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/export_service.dart';
import '../../services/translation_service.dart';

/// شاشة الترجمة وعرض النتائج
class TranslationScreen extends StatefulWidget {
  final String projectId;
  const TranslationScreen({super.key, required this.projectId});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _originalController;
  late TextEditingController _translatedController;
  bool _isEditing = false;
  bool _isRetranslating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final project = context.read<ProjectsProvider>().getProjectById(widget.projectId);
    _originalController = TextEditingController(text: project?.originalText ?? '');
    _translatedController = TextEditingController(text: project?.translatedText ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _originalController.dispose();
    _translatedController.dispose();
    super.dispose();
  }

  Future<void> _retranslate() async {
    final project = context.read<ProjectsProvider>().getProjectById(widget.projectId);
    if (project == null) return;

    setState(() => _isRetranslating = true);

    final result = await TranslationService.instance.translateLongText(
      text: _originalController.text,
      sourceLanguage: project.sourceLanguage,
      targetLanguage: project.targetLanguage,
    );

    if (result.success) {
      _translatedController.text = result.translatedText;
      await _saveChanges();
    }

    setState(() => _isRetranslating = false);
  }

  Future<void> _saveChanges() async {
    final provider = context.read<ProjectsProvider>();
    final project = provider.getProjectById(widget.projectId);
    if (project == null) return;

    await provider.updateProject(project.copyWith(
      originalText: _originalController.text,
      translatedText: _translatedController.text,
      updatedAt: DateTime.now(),
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                context.read<LanguageProvider>().isArabic
                    ? 'تم الحفظ'
                    : 'Saved',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<LanguageProvider>().isArabic ? 'تم النسخ' : 'Copied',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showExportSheet(BuildContext context, ProjectModel project) {
    final isArabic = context.read<LanguageProvider>().isArabic;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExportSheet(project: project, isArabic: isArabic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final project = context.watch<ProjectsProvider>().getProjectById(widget.projectId);

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: Text(isArabic ? 'الترجمة' : 'Translation')),
        body: const Center(child: Text('المشروع غير موجود')),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              project.name,
              style: const TextStyle(fontSize: 16, fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
            Text(
              '${project.sourceLanguage.toUpperCase()} → ${project.targetLanguage.toUpperCase()}',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.primary,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        actions: [
          // زر التعديل
          IconButton(
            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded),
            onPressed: () {
              if (_isEditing) _saveChanges();
              setState(() => _isEditing = !_isEditing);
            },
            tooltip: isArabic ? 'تعديل' : 'Edit',
          ),
          // زر التصدير
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _showExportSheet(context, project),
            tooltip: isArabic ? 'تصدير' : 'Export',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: isArabic ? 'النص الأصلي' : 'Original'),
            Tab(text: isArabic ? 'الترجمة' : 'Translation'),
          ],
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
      body: Column(
        children: [
          // شريط المعلومات
          _buildInfoBar(project, isArabic, isDark),

          // محتوى الـ Tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // النص الأصلي
                _buildTextView(
                  controller: _originalController,
                  isEditing: _isEditing,
                  isDark: isDark,
                  isArabic: isArabic,
                  language: project.sourceLanguage,
                  isOriginal: true,
                ),
                // الترجمة
                _buildTextView(
                  controller: _translatedController,
                  isEditing: _isEditing,
                  isDark: isDark,
                  isArabic: isArabic,
                  language: project.targetLanguage,
                  isOriginal: false,
                ),
              ],
            ),
          ),

          // أزرار الإجراءات السريعة
          _buildQuickActions(project, isArabic, colorScheme),
        ],
      ),
    );
  }

  Widget _buildInfoBar(ProjectModel project, bool isArabic, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark ? AppColors.cardDark : AppColors.primary.withOpacity(0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoChip(
            icon: Icons.video_file_rounded,
            label: project.durationText,
          ),
          _InfoChip(
            icon: Icons.storage_rounded,
            label: project.sizeText,
          ),
          _InfoChip(
            icon: Icons.check_circle_rounded,
            label: isArabic ? 'مكتمل' : 'Complete',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildTextView({
    required TextEditingController controller,
    required bool isEditing,
    required bool isDark,
    required bool isArabic,
    required String language,
    required bool isOriginal,
  }) {
    final isRtl = language == 'ar' || language == 'fa' || language == 'ur' || language == 'he';

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.primary.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEditing
                      ? AppColors.primary.withOpacity(0.4)
                      : AppColors.primary.withOpacity(0.1),
                  width: isEditing ? 1.5 : 1,
                ),
              ),
              child: Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: TextField(
                  controller: controller,
                  readOnly: !isEditing,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    fontFamily: isRtl ? 'Cairo' : 'Inter',
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintText: isArabic ? 'لا يوجد نص...' : 'No text...',
                    filled: false,
                  ),
                ),
              ),
            ),
          ),
        ),
        // عداد الكلمات
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${controller.text.split(' ').where((w) => w.isNotEmpty).length} ${isArabic ? 'كلمة' : 'words'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                '${controller.text.length} ${isArabic ? 'حرف' : 'chars'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
      ProjectModel project, bool isArabic, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // نسخ النص الأصلي
          _QuickAction(
            icon: Icons.copy_rounded,
            label: isArabic ? 'نسخ الأصل' : 'Copy Original',
            onTap: () => _copyText(_originalController.text),
          ),
          const SizedBox(width: 10),
          // نسخ الترجمة
          _QuickAction(
            icon: Icons.copy_all_rounded,
            label: isArabic ? 'نسخ الترجمة' : 'Copy Translation',
            onTap: () => _copyText(_translatedController.text),
          ),
          const SizedBox(width: 10),
          // إعادة الترجمة
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isRetranslating ? null : _retranslate,
              icon: _isRetranslating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                isArabic ? 'إعادة الترجمة' : 'Re-translate',
                style: const TextStyle(fontSize: 13, fontFamily: 'Cairo'),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 46),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: c,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 11, fontFamily: 'Cairo'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
}

class _ExportSheet extends StatelessWidget {
  final ProjectModel project;
  final bool isArabic;

  const _ExportSheet({required this.project, required this.isArabic});

  Future<void> _export(BuildContext context, String type) async {
    Navigator.pop(context);
    ExportResult result;

    switch (type) {
      case 'pdf':
        result = await ExportService.instance.exportToPdf(project);
        break;
      case 'txt':
        result = await ExportService.instance.exportToTxt(project);
        break;
      case 'share_original':
        await ExportService.instance.shareText(
          project.originalText,
          project.name,
        );
        return;
      case 'share_translated':
        await ExportService.instance.shareText(
          project.translatedText,
          project.name,
        );
        return;
      default:
        return;
    }

    if (!context.mounted) return;

    if (result.success && result.filePath != null) {
      await ExportService.instance.shareFile(result.filePath!, project.name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isArabic ? 'تصدير ومشاركة' : 'Export & Share',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          _ExportOption(
            icon: Icons.picture_as_pdf_rounded,
            color: AppColors.error,
            title: 'PDF',
            subtitle: isArabic ? 'تصدير كملف PDF' : 'Export as PDF',
            onTap: () => _export(context, 'pdf'),
          ),
          _ExportOption(
            icon: Icons.text_snippet_rounded,
            color: AppColors.info,
            title: 'TXT',
            subtitle: isArabic ? 'تصدير كملف نصي' : 'Export as text file',
            onTap: () => _export(context, 'txt'),
          ),
          _ExportOption(
            icon: Icons.share_rounded,
            color: AppColors.primary,
            title: isArabic ? 'مشاركة النص الأصلي' : 'Share Original Text',
            subtitle: isArabic ? 'مشاركة النص المستخرج' : 'Share extracted text',
            onTap: () => _export(context, 'share_original'),
          ),
          _ExportOption(
            icon: Icons.share_outlined,
            color: AppColors.secondary,
            title: isArabic ? 'مشاركة الترجمة' : 'Share Translation',
            subtitle: isArabic ? 'مشاركة النص المترجم' : 'Share translated text',
            onTap: () => _export(context, 'share_translated'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontFamily: 'Cairo',
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
    );
  }
}
