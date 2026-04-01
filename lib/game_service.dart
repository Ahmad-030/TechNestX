import 'package:technestx/task_model.dart';


import 'badge_model.dart';
import 'storage_service.dart';

class GameService {
  final StorageService _storage;

  GameService(this._storage);

  int get totalPoints => _storage.getTotalPoints();
  List<Badge> get badges => _storage.getBadges();

  UserLevel get currentLevel => UserLevel.fromPoints(totalPoints);

  int get currentStreak {
    final data = _storage.getStreakData();
    return data['currentStreak'] ?? 0;
  }

  int get longestStreak {
    final data = _storage.getStreakData();
    return data['longestStreak'] ?? 0;
  }

  Future<List<Badge>> completeTask(Task task) async {
    // Add points
    final newPoints = totalPoints + task.points;
    await _storage.savePoints(newPoints);

    // Update daily stats
    final today = _todayKey();
    final stats = _storage.getDailyStats();
    stats[today] = (stats[today] ?? 0) + task.points;
    await _storage.saveDailyStats(stats);

    // Update streak
    await _updateStreak();

    // Check badges
    final newlyUnlocked = await _checkBadges(newPoints, task);
    return newlyUnlocked;
  }

  Future<void> _updateStreak() async {
    final data = _storage.getStreakData();
    final today = DateTime.now();
    final todayStr = _dateKey(today);
    final lastStr = data['lastActiveDate'] as String?;

    int currentStreak = data['currentStreak'] ?? 0;
    int longestStreak = data['longestStreak'] ?? 0;

    if (lastStr == null) {
      currentStreak = 1;
    } else {
      final last = DateTime.parse(lastStr);
      final diff = today.difference(last).inDays;
      if (diff == 0) {
        // Same day, no change
      } else if (diff == 1) {
        currentStreak += 1;
      } else {
        currentStreak = 1;
      }
    }

    if (currentStreak > longestStreak) longestStreak = currentStreak;

    await _storage.saveStreakData({
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': todayStr,
    });
  }

  Future<List<Badge>> _checkBadges(int points, Task completedTask) async {
    final badges = _storage.getBadges();
    final tasks = _storage.getTasks();
    final newlyUnlocked = <Badge>[];

    final completedTasks = tasks.where((t) => t?.status == TaskStatus.completed).toList();
    final highPrioCompleted = completedTasks.where((t) => t.priority == Priority.high).length;

    for (final badge in badges) {
      if (badge.isUnlocked) continue;

      bool unlock = false;
      switch (badge.id) {
        case 'first_task':
          unlock = completedTasks.isNotEmpty;
          break;
        case 'starter':
          unlock = points >= 50;
          break;
        case 'achiever':
          unlock = points >= 150;
          break;
        case 'warrior':
          unlock = points >= 300;
          break;
        case 'champion':
          unlock = points >= 500;
          break;
        case 'legend':
          unlock = points >= 1000;
          break;
        case 'streak3':
          unlock = currentStreak >= 3;
          break;
        case 'streak7':
          unlock = currentStreak >= 7;
          break;
        case 'highprio':
          unlock = highPrioCompleted >= 5;
          break;
        case 'tenner':
          unlock = completedTasks.length >= 10;
          break;
      }

      if (unlock) {
        badge.isUnlocked = true;
        badge.unlockedAt = DateTime.now();
        newlyUnlocked.add(badge);
      }
    }

    await _storage.saveBadges(badges);
    return newlyUnlocked;
  }

  int getTodayPoints() {
    final stats = _storage.getDailyStats();
    return stats[_todayKey()] ?? 0;
  }

  Map<String, int> getWeeklyStats() {
    final stats = _storage.getDailyStats();
    final result = <String, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final key = _dateKey(day);
      result[key] = stats[key] ?? 0;
    }
    return result;
  }

  Map<String, int> getMonthlyStats() {
    final stats = _storage.getDailyStats();
    final result = <String, int>{};
    for (int i = 29; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final key = _dateKey(day);
      result[key] = stats[key] ?? 0;
    }
    return result;
  }

  String _todayKey() => _dateKey(DateTime.now());
  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}