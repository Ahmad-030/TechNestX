import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
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
      final pending =
          todayTasks.where((t) => t.status == TaskStatus.pending).length;
      final completed =
          todayTasks.where((t) => t.status == TaskStatus.completed).length;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
      final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
      final subColor = isDark ? AppTheme.darkSubText : AppTheme.lightSubText;

      // Show done lottie when all today tasks are completed and at least one exists
      final allDone = todayTasks.isNotEmpty && pending == 0;

      return Scaffold(
        backgroundColor: bgColor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              backgroundColor: bgColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              title: null, // No title here to avoid overlap
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final top = constraints.biggest.height;
                  final expandedHeight = 220 + MediaQuery.of(context).padding.top;
                  final collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
                  final t = ((top - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
                  final isCollapsed = t < 0.3;

                  return FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                    title: isCollapsed
                        ? Text(
                      'TaskNestX 🪺',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textColor,
                      ),
                    )
                        : null,
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
                              // Top row: app title
                              Text(
                                'TaskNestX 🪺',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Level + streak row
                              Row(
                                children: [
                                  Text(
                                    '${level.emoji}',
                                    style: const TextStyle(fontSize: 28),
                                  ).animate().scale(
                                    duration: 500.ms,
                                    curve: Curves.elasticOut,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Good ${_greeting()}!',
                                        style: GoogleFonts.outfit(
                                          color: subColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        level.title,
                                        style: GoogleFonts.outfit(
                                          color: textColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  if (streak > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF6B35).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFFF6B35).withOpacity(0.4),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text('🔥',
                                              style: TextStyle(fontSize: 14)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$streak day${streak != 1 ? 's' : ''}',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFFFF6B35),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).animate().fadeIn(delay: 300.ms),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Progress bar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Level ${level.level}',
                                        style: GoogleFonts.outfit(
                                          color: subColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '$totalPoints pts',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFFFF6B35),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: _levelProgress(level, totalPoints),
                                      backgroundColor: isDark
                                          ? const Color(0xFF2A2A4A)
                                          : const Color(0xFFDDDDEE),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFF6B35),
                                      ),
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
                  );
                },
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                            label: "Today's Points",
                            value: '+$todayPoints',
                            emoji: '⚡',
                            color: const Color(0xFFFFD23F))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                            label: 'Completed',
                            value: '$completed',
                            emoji: '✅',
                            color: const Color(0xFF06D6A0))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                            label: 'Pending',
                            value: '$pending',
                            emoji: '⏳',
                            color: const Color(0xFF4ECDC4))),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(
                    begin: 0.3, end: 0, duration: 400.ms),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Tasks",
                        style: GoogleFonts.outfit(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text('${todayTasks.length} total',
                        style:
                        GoogleFonts.outfit(color: subColor, fontSize: 13)),
                  ],
                ),
              ),
            ),

            // All tasks done — show Lottie celebration
            if (allDone)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 160,
                        child: Lottie.asset(
                          'assets/done.json',
                          repeat: true,
                          errorBuilder: (_, __, ___) =>
                          const Text('🎉', style: TextStyle(fontSize: 60)),
                        ),
                      ).animate().fadeIn(duration: 500.ms).scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1, 1),
                          curve: Curves.elasticOut),
                      const SizedBox(height: 8),
                      Text(
                        'All done for today! 🎊',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFF06D6A0),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ).animate().fadeIn(delay: 200.ms),
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
                      SizedBox(
                        height: 160,
                        child: Lottie.asset(
                          'assets/done.json',
                          repeat: true,
                          errorBuilder: (_, __, ___) =>
                          const Text('🎉', style: TextStyle(fontSize: 60)),
                        ),
                      ).animate().fadeIn(duration: 500.ms).scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1, 1),
                          curve: Curves.elasticOut),
                      const SizedBox(height: 16),
                      Text('No tasks today!\nAdd one to get started.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                              color: subColor, fontSize: 15)),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 5),
                    child: TaskCard(task: todayTasks[i])
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: i * 80))
                        .slideX(begin: 0.2, end: 0, duration: 350.ms),
                  ),
                  childCount: todayTasks.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddTaskScreen())),
          backgroundColor: const Color(0xFFFF6B35),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text('Add Task',
              style: GoogleFonts.outfit(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ).animate().scale(
            delay: 500.ms, duration: 400.ms, curve: Curves.elasticOut),
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

  const _StatCard(
      {required this.label,
        required this.value,
        required this.emoji,
        required this.color});

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
          Text(value,
              style: GoogleFonts.outfit(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: GoogleFonts.outfit(
                color: isDark ? AppTheme.darkSubText : AppTheme.lightSubText,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}