import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:technestx/task_card.dart';
import 'package:technestx/task_model.dart';
import 'package:technestx/task_provider.dart';

import 'add_task_screen.dart';
import 'app_theme.dart';
import 'badge_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, provider, _) {
      final game = provider.game;
      final level = game.currentLevel;
      final todayPoints = game.getTodayPoints();
      final totalPoints = game.totalPoints;
      final streak = game.currentStreak;
      final todayTasks = provider.todayTasks;
      final pending = todayTasks.where((t) => t.status == TaskStatus.pending).length;
      final completed = todayTasks.where((t) => t.status == TaskStatus.completed).length;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
      final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
      final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
      final subColor = isDark ? AppTheme.darkSubText : AppTheme.lightSubText;

      return Scaffold(
        backgroundColor: bgColor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: bgColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF6B35).withOpacity(0.15),
                        const Color(0xFFFFD23F).withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('${level.emoji}', style: const TextStyle(fontSize: 28))
                                  .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Good ${_greeting()}!',
                                    style: TextStyle(color: subColor, fontSize: 13, fontFamily: 'Outfit'),
                                  ),
                                  Text(
                                    level.title,
                                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (streak > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B35).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('🔥', style: TextStyle(fontSize: 14)),
                                      const SizedBox(width: 4),
                                      Text('$streak day${streak != 1 ? 's' : ''}',
                                          style: const TextStyle(color: Color(0xFFFF6B35), fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: 300.ms),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Level progress bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Level ${level.level}', style: TextStyle(color: subColor, fontSize: 12, fontFamily: 'Outfit')),
                                  Text('$totalPoints pts', style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 12, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _levelProgress(level, totalPoints),
                                  backgroundColor: isDark ? const Color(0xFF2A2A4A) : const Color(0xFFDDDDEE),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              title: const Text('TaskNestX 🪺', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(child: _StatCard(label: 'Today\'s Points', value: '+$todayPoints', emoji: '⚡', color: const Color(0xFFFFD23F))),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Completed', value: '$completed', emoji: '✅', color: const Color(0xFF06D6A0))),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Pending', value: '$pending', emoji: '⏳', color: const Color(0xFF4ECDC4))),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0, duration: 400.ms),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Tasks", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                    Text('${todayTasks.length} total', style: TextStyle(color: subColor, fontSize: 13, fontFamily: 'Outfit')),
                  ],
                ),
              ),
            ),

            if (todayTasks.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Text('🥚', style: TextStyle(fontSize: 60)).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 16),
                      Text('No tasks today!\nAdd one to get started.', textAlign: TextAlign.center, style: TextStyle(color: subColor, fontSize: 15, fontFamily: 'Outfit')),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: TaskCard(task: todayTasks[i]).animate().fadeIn(delay: Duration(milliseconds: i * 80)).slideX(begin: 0.2, end: 0, duration: 350.ms),
                  ),
                  childCount: todayTasks.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen())),
          backgroundColor: const Color(0xFFFF6B35),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Task', style: TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.elasticOut),
      );
    });
  }

  double _levelProgress(UserLevel level, int points) {
    if (level.maxPoints == 99999) return 1.0;
    final range = level.maxPoints - level.minPoints;
    final earned = points - level.minPoints;
    return (earned / range).clamp(0.0, 1.0);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          Text(label, style: TextStyle(color: isDark ? AppTheme.darkSubText : AppTheme.lightSubText, fontSize: 10, fontFamily: 'Outfit'), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}