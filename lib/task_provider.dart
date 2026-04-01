import 'package:flutter/material.dart';
import 'package:technestx/storage_service.dart';
import 'package:technestx/task_model.dart';
import 'package:technestx/badge_model.dart';
import 'package:technestx/game_service.dart';
import 'dart:math';

class TaskProvider extends ChangeNotifier {
  late StorageService _storage;
  late GameService _game;
  List<Task> _tasks = [];
  bool _initialized = false;
  String? _selectedTag;
  Priority? _selectedPriority;
  String _themeMode = 'dark';

  List<Task> get tasks => _tasks;
  bool get initialized => _initialized;
  String? get selectedTag => _selectedTag;
  Priority? get selectedPriority => _selectedPriority;
  String get themeMode => _themeMode;
  GameService get game => _game;
  StorageService get storage => _storage;

  Future<void> init() async {
    _storage = await StorageService.getInstance();
    _game = GameService(_storage);
    _tasks = _storage.getTasks();
    _themeMode = _storage.getTheme();
    _initialized = true;
    notifyListeners();
  }

  List<Task> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((t) {
      if (t.dueDate == null) {
        final c = t.createdAt;
        return c.year == today.year && c.month == today.month && c.day == today.day;
      }
      return t.dueDate!.year == today.year &&
          t.dueDate!.month == today.month &&
          t.dueDate!.day == today.day;
    }).toList()
      ..sort((a, b) => a.status.index.compareTo(b.status.index));
  }

  List<Task> get filteredTasks {
    var result = List<Task>.from(_tasks);
    if (_selectedTag != null && _selectedTag!.isNotEmpty) {
      result = result.where((t) => t.tag == _selectedTag).toList();
    }
    if (_selectedPriority != null) {
      result = result.where((t) => t.priority == _selectedPriority).toList();
    }
    result.sort((a, b) {
      if (a.status != b.status) return a.status.index.compareTo(b.status.index);
      return b.priority.index.compareTo(a.priority.index);
    });
    return result;
  }

  List<String> get allTags {
    return _tasks.map((t) => t.tag).where((t) => t.isNotEmpty).toSet().toList();
  }

  void setTagFilter(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  void setPriorityFilter(Priority? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void clearFilters() {
    _selectedTag = null;
    _selectedPriority = null;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
      await _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  // FIX: was Future<List<Badge>> clashing with Flutter's Badge widget.
  // Correctly typed as Future<List<AppBadge>>.
  Future<List<AppBadge>> completeTask(String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return [];
    _tasks[idx] = _tasks[idx].copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
    );
    await _storage.saveTasks(_tasks);
    final newBadges = await _game.completeTask(_tasks[idx]);
    notifyListeners();
    return newBadges;
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _themeMode = theme;
    await _storage.saveTheme(theme);
    notifyListeners();
  }

  Future<void> resetData() async {
    await _storage.resetAll();
    _tasks = [];
    _selectedTag = null;
    _selectedPriority = null;
    notifyListeners();
  }

  String generateId() => '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
}