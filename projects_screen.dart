import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project_model.dart';
import '../../providers/projects_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/project_card.dart';
import '../../router/app_router.dart';

/// شاشة إدارة المشاريع
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext ctx, ProjectModel project, bool isArabic) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(isArabic ? 'حذف المشروع' : 'Delete Project'),
        content: Text(
          isArabic
              ? 'هل تريد حذف "${project.name}"؟ لا يمكن التراجع عن هذه العملية.'
              : 'Delete "${project.name}"? This cannot be undone.',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              context.read<ProjectsProvider>().deleteProject(project.id);
              Navigator.pop(ctx);
            },
            child: Text(isArabic ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext ctx, ProjectModel project, bool isArabic) {
    final controller = TextEditingController(text: project.name);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(isArabic ? 'إعادة تسمية' : 'Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: isArabic ? 'اسم المشروع' : 'Project name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ProjectsProvider>().renameProject(
                      project.id,
                      controller.text.trim(),
                    );
                Navigator.pop(ctx);
              }
            },
            child: Text(isArabic ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  List<ProjectModel> _getFilteredProjects(ProjectsProvider provider) {
    List<ProjectModel> projects = provider.projects;

    if (_filterStatus != 'all') {
      projects = projects.where((p) => p.status == _filterStatus).toList();
    }

    return projects;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageProvider>().isArabic;
    final provider = context.watch<ProjectsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final filteredProjects = _getFilteredProjects(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'مشاريعي' : 'My Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: isArabic ? 'ترتيب' : 'Sort',
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: isArabic
                    ? 'بحث في المشاريع...'
                    : 'Search projects...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // فلاتر الحالة
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: isArabic ? 'الكل' : 'All',
                  isSelected: _filterStatus == 'all',
                  onTap: () => setState(() => _filterStatus = 'all'),
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: isArabic ? 'مكتمل' : 'Completed',
                  isSelected: _filterStatus == ProjectStatus.completed,
                  onTap: () => setState(() => _filterStatus = ProjectStatus.completed),
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: isArabic ? 'جاري' : 'Processing',
                  isSelected: _filterStatus == ProjectStatus.processing,
                  onTap: () => setState(() => _filterStatus = ProjectStatus.processing),
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: isArabic ? 'متوقف' : 'Paused',
                  isSelected: _filterStatus == ProjectStatus.paused,
                  onTap: () => setState(() => _filterStatus = ProjectStatus.paused),
                  color: AppColors.info,
                ),
              ],
            ),
          ),

          // عداد النتائج
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filteredProjects.length} ${isArabic ? 'مشروع' : 'projects'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),

          // قائمة المشاريع
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProjects.isEmpty
                    ? _buildEmptyState(isArabic, isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project = filteredProjects[index];
                          return ProjectCard(
                            project: project,
                            onTap: () {
                              if (project.status == ProjectStatus.completed) {
                                context.push(AppRoutes.translation(project.id));
                              } else {
                                context.push(AppRoutes.projectDetail(project.id));
                              }
                            },
                            onLongPress: () {
                              _showProjectOptions(context, project, isArabic);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showProjectOptions(
      BuildContext context, ProjectModel project, bool isArabic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
              title: Text(isArabic ? 'إعادة تسمية' : 'Rename',
                  style: const TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, project, isArabic);
              },
            ),
            ListTile(
              leading: Icon(
                project.isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppColors.warning,
              ),
              title: Text(
                project.isStarred
                    ? (isArabic ? 'إلغاء التمييز' : 'Unstar')
                    : (isArabic ? 'تمييز' : 'Star'),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () {
                context.read<ProjectsProvider>().toggleStar(project.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: AppColors.error),
              title: Text(isArabic ? 'حذف' : 'Delete',
                  style: const TextStyle(color: AppColors.error, fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, project, isArabic);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 80,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لا توجد مشاريع' : 'No projects found',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'ابدأ بتحديد فيديو من الشاشة الرئيسية'
                : 'Start by picking a video from home screen',
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
