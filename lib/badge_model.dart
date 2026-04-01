class Badge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requiredPoints;
  bool isUnlocked;
  DateTime? unlockedAt;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredPoints,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  static List<Badge> defaultBadges() => [
    Badge(id: 'first_task', title: 'First Step', description: 'Complete your first task', emoji: '🐣', requiredPoints: 10),
    Badge(id: 'starter', title: 'Starter', description: 'Earn 50 points', emoji: '⭐', requiredPoints: 50),
    Badge(id: 'achiever', title: 'Achiever', description: 'Earn 150 points', emoji: '🔥', requiredPoints: 150),
    Badge(id: 'warrior', title: 'Task Warrior', description: 'Earn 300 points', emoji: '⚔️', requiredPoints: 300),
    Badge(id: 'champion', title: 'Champion', description: 'Earn 500 points', emoji: '🏆', requiredPoints: 500),
    Badge(id: 'legend', title: 'Legend', description: 'Earn 1000 points', emoji: '👑', requiredPoints: 1000),
    Badge(id: 'streak3', title: '3-Day Streak', description: '3 days in a row', emoji: '🌟', requiredPoints: 0),
    Badge(id: 'streak7', title: 'Week Warrior', description: '7 days in a row', emoji: '💎', requiredPoints: 0),
    Badge(id: 'highprio', title: 'Prioritizer', description: 'Complete 5 high-priority tasks', emoji: '🎯', requiredPoints: 0),
    Badge(id: 'tenner', title: 'Tenner', description: 'Complete 10 tasks total', emoji: '🌈', requiredPoints: 0),
  ];
}

class UserLevel {
  final int level;
  final String title;
  final int minPoints;
  final int maxPoints;
  final String emoji;

  const UserLevel({
    required this.level,
    required this.title,
    required this.minPoints,
    required this.maxPoints,
    required this.emoji,
  });

  static UserLevel fromPoints(int points) {
    for (final lvl in levels.reversed) {
      if (points >= lvl.minPoints) return lvl;
    }
    return levels.first;
  }

  static const List<UserLevel> levels = [
    UserLevel(level: 1, title: 'Hatchling', minPoints: 0, maxPoints: 99, emoji: '🐣'),
    UserLevel(level: 2, title: 'Nestling', minPoints: 100, maxPoints: 249, emoji: '🐥'),
    UserLevel(level: 3, title: 'Fledgling', minPoints: 250, maxPoints: 499, emoji: '🐦'),
    UserLevel(level: 4, title: 'Soarer', minPoints: 500, maxPoints: 999, emoji: '🦅'),
    UserLevel(level: 5, title: 'Eagle', minPoints: 1000, maxPoints: 1999, emoji: '🦁'),
    UserLevel(level: 6, title: 'Phoenix', minPoints: 2000, maxPoints: 99999, emoji: '🔥'),
  ];
}