import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technestx/task_model.dart';
import 'badge_model.dart';

class StorageService {
  static const _tasksKey = 'tasks';
  static const _pointsKey = 'total_points';
  static const _badgesKey = 'badges';
  static const _streakKey = 'streak_data';
  static const _themeKey = 'theme_mode';
  static const _statsKey = 'daily_stats';

  static StorageService? _instance;
  static late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _prefs = await SharedPreferences.getInstance();
      _instance = StorageService._();
    }
    return _instance!;
  }

  // Tasks
  List<Task> getTasks() {
    final raw = _prefs.getString(_tasksKey);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => Task.fromJson(e)).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(_tasksKey, raw);
  }

  // Points
  int getTotalPoints() => _prefs.getInt(_pointsKey) ?? 0;

  Future<void> savePoints(int points) async {
    await _prefs.setInt(_pointsKey, points);
  }

  // Badges — uses AppBadge to avoid conflict with Flutter's Badge widget
  List<AppBadge> getBadges() {
    final raw = _prefs.getString(_badgesKey);
    final defaults = AppBadge.defaultBadges();
    if (raw == null) return defaults;
    final List<dynamic> list = jsonDecode(raw);
    final savedMap = {for (var e in list) e['id']: e};
    for (final badge in defaults) {
      if (savedMap.containsKey(badge.id)) {
        badge.isUnlocked = savedMap[badge.id]['isUnlocked'] ?? false;
        final at = savedMap[badge.id]['unlockedAt'];
        badge.unlockedAt = at != null ? DateTime.parse(at) : null;
      }
    }
    return defaults;
  }

  Future<void> saveBadges(List<AppBadge> badges) async {
    final raw = jsonEncode(badges.map((b) => b.toJson()).toList());
    await _prefs.setString(_badgesKey, raw);
  }

  // Streak
  Map<String, dynamic> getStreakData() {
    final raw = _prefs.getString(_streakKey);
    if (raw == null) {
      return {'currentStreak': 0, 'lastActiveDate': null, 'longestStreak': 0};
    }
    return jsonDecode(raw);
  }

  Future<void> saveStreakData(Map<String, dynamic> data) async {
    await _prefs.setString(_streakKey, jsonEncode(data));
  }

  // Theme
  String getTheme() => _prefs.getString(_themeKey) ?? 'dark';
  Future<void> saveTheme(String theme) async =>
      await _prefs.setString(_themeKey, theme);

  // Daily stats
  Map<String, dynamic> getDailyStats() {
    final raw = _prefs.getString(_statsKey);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  Future<void> saveDailyStats(Map<String, dynamic> stats) async {
    await _prefs.setString(_statsKey, jsonEncode(stats));
  }

  Future<void> resetAll() async {
    await _prefs.remove(_tasksKey);
    await _prefs.remove(_pointsKey);
    await _prefs.remove(_badgesKey);
    await _prefs.remove(_streakKey);
    await _prefs.remove(_statsKey);
  }
}