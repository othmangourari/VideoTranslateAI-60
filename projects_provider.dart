import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/database_service.dart';

/// مزود المشاريع - يدير قائمة المشاريع
class ProjectsProvider extends ChangeNotifier {
  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<ProjectModel> get projects => _filteredProjects;
  List<ProjectModel> get allProjects => _projects;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<ProjectModel> get _filteredProjects {
    if (_searchQuery.isEmpty) return _projects;
    final query = _searchQuery.toLowerCase();
    return _projects.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.videoName.toLowerCase().contains(query) ||
          p.originalText.toLowerCase().contains(query) ||
          p.translatedText.toLowerCase().contains(query);
    }).toList();
  }

  List<ProjectModel> get completedProjects =>
      _projects.where((p) => p.status == ProjectStatus.completed).toList();

  List<ProjectModel> get recentProjects {
    final sorted = [..._projects];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  ProjectsProvider() {
    loadProjects();
  }

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      _projects = await DatabaseService.instance.getAllProjects();
      _projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProject(ProjectModel project) async {
    await DatabaseService.instance.insertProject(project);
    _projects.insert(0, project);
    notifyListeners();
  }

  Future<void> updateProject(ProjectModel project) async {
    await DatabaseService.instance.updateProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    await DatabaseService.instance.deleteProject(projectId);
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }

  Future<void> renameProject(String projectId, String newName) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final updated = _projects[index].copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      await updateProject(updated);
    }
  }

  Future<void> toggleStar(String projectId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final updated = _projects[index].copyWith(
        isStarred: !_projects[index].isStarred,
        updatedAt: DateTime.now(),
      );
      await updateProject(updated);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  ProjectModel? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
