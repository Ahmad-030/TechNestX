import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:technestx/task_provider.dart';
import 'app_theme.dart';
import 'badge_model.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, provider, _) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
      final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
      final subColor = isDark ? AppTheme.darkSubText : AppTheme.lightSubText;
      final game = provider.game;
      final badges = game.badges;
      final level = game.currentLevel;
      final totalPoints = game.totalPoints;
      final earned = badges.where((b) => b.isUnlocked).length;

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          title: Text('Rewards', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: textColor)),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Level card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFFD23F)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Text(level.emoji, style: const TextStyle(fontSize: 52))
                      .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Level ${level.level}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Outfit')),
                        Text(level.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                        const SizedBox(height: 6),
                        Text('$totalPoints total points', style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit')),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

            const SizedBox(height: 16),

            // Level progression
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Journey', style: TextStyle(color: textColor, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  ...UserLevel.levels.map((lvl) {
                    final isActive = level.level == lvl.level;
                    final isDone = level.level > lvl.level;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone || isActive
                                  ? (isActive ? const Color(0xFFFF6B35) : const Color(0xFF06D6A0))
                                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                            ),
                            child: Center(child: Text(lvl.emoji, style: const TextStyle(fontSize: 18))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${lvl.title} (Lv.${lvl.level})', style: TextStyle(
                                color: isActive ? const Color(0xFFFF6B35) : (isDone ? const Color(0xFF06D6A0) : subColor),
                                fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 13,
                              )),
                              Text('${lvl.minPoints}${lvl.maxPoints == 99999 ? '+ pts' : '-${lvl.maxPoints} pts'}',
                                  style: TextStyle(color: subColor, fontSize: 11, fontFamily: 'Outfit')),
                            ]),
                          ),
                          if (isActive) const Icon(Icons.arrow_right_rounded, color: Color(0xFFFF6B35)),
                          if (isDone) const Icon(Icons.check_circle_rounded, color: Color(0xFF06D6A0), size: 20),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 20),

            // Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Badges', style: TextStyle(color: textColor, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 18)),
                Text('$earned/${badges.length}', style: const TextStyle(color: Color(0xFFFF6B35), fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: badges.length,
              itemBuilder: (_, i) => _BadgeCard(badge: badges[i], isDark: isDark, subColor: subColor)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 300 + i * 60))
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), delay: Duration(milliseconds: 300 + i * 60)),
            ),

            const SizedBox(height: 30),
          ],
        ),
      );
    });
  }
}

class _BadgeCard extends StatelessWidget {
  final AppBadge badge;
  final bool isDark;
  final Color subColor;

  const _BadgeCard({required this.badge, required this.isDark, required this.subColor});

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFFF6B35).withOpacity(0.12)
            : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked ? const Color(0xFFFF6B35).withOpacity(0.4) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.emoji,
            style: TextStyle(fontSize: 32, color: unlocked ? null : Colors.white.withOpacity(0.2)),
          ),
          if (!unlocked)
            Positioned(
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                child: Text(badge.emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            badge.title,
            style: TextStyle(
              color: unlocked ? const Color(0xFFFF6B35) : subColor,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            badge.description,
            style: TextStyle(color: subColor, fontFamily: 'Outfit', fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}