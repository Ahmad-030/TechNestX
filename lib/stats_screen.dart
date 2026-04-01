import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:technestx/task_model.dart';
import 'package:technestx/task_provider.dart';
import 'app_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, provider, _) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
      final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
      final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
      final subColor = isDark ? AppTheme.darkSubText : AppTheme.lightSubText;
      final game = provider.game;
      final tasks = provider.tasks;
      final total = tasks.length;
      final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
      final pending = tasks.where((t) => t?.status == TaskStatus.pending).length;
      final rate = total == 0 ? 0.0 : completed / total;
      final weekly = game.getWeeklyStats();
      final monthly = game.getMonthlyStats();

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          title: Text('Statistics', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: textColor)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFFF6B35),
            labelColor: const Color(0xFFFF6B35),
            unselectedLabelColor: subColor,
            labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
            tabs: const [Tab(text: 'Overview'), Tab(text: 'Weekly'), Tab(text: 'Monthly')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Overview
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(child: _SumCard(value: '$total', label: 'Total Tasks', emoji: '📋', color: const Color(0xFF4ECDC4))),
                    const SizedBox(width: 12),
                    Expanded(child: _SumCard(value: '$completed', label: 'Completed', emoji: '✅', color: const Color(0xFF06D6A0))),
                    const SizedBox(width: 12),
                    Expanded(child: _SumCard(value: '$pending', label: 'Pending', emoji: '⏳', color: const Color(0xFFFFD23F))),
                  ],
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 16),

                // Completion rate
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Completion Rate', style: TextStyle(color: textColor, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            width: 80, height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: rate,
                                  backgroundColor: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                                  strokeWidth: 8,
                                ),
                                Text('${(rate * 100).toInt()}%', style: const TextStyle(color: Color(0xFFFF6B35), fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('You\'re doing great!', style: TextStyle(color: textColor, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Keep completing tasks to level up', style: TextStyle(color: subColor, fontFamily: 'Outfit', fontSize: 12)),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                // Streak + points
                Row(
                  children: [
                    Expanded(child: _StatTile(label: 'Current Streak', value: '${game.currentStreak}d 🔥', color: const Color(0xFFFF6B35), cardColor: cardColor, textColor: textColor, subColor: subColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatTile(label: 'Longest Streak', value: '${game.longestStreak}d 🏆', color: const Color(0xFFFFD23F), cardColor: cardColor, textColor: textColor, subColor: subColor)),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: _StatTile(label: 'Total Points', value: '${game.totalPoints}⚡', color: const Color(0xFF4ECDC4), cardColor: cardColor, textColor: textColor, subColor: subColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatTile(label: 'Today\'s Points', value: '+${game.getTodayPoints()}⚡', color: const Color(0xFF06D6A0), cardColor: cardColor, textColor: textColor, subColor: subColor)),
                  ],
                ).animate().fadeIn(delay: 350.ms),

                // Priority breakdown
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('By Priority', style: TextStyle(color: textColor, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      ...Priority.values.map((p) {
                        final pTasks = tasks.where((t) => t.priority == p).length;
                        final pDone = tasks.where((t) => t.priority == p && t.status == TaskStatus.completed).length;
                        final color = AppTheme.priorityColor(p.index);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${['🌿', '⚡', '🔥'][p.index]} ${AppTheme.priorityLabel(p.index)}', style: TextStyle(color: color, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('$pDone/$pTasks', style: TextStyle(color: subColor, fontFamily: 'Outfit', fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: pTasks == 0 ? 0 : pDone / pTasks,
                                  backgroundColor: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                  valueColor: AlwaysStoppedAnimation<Color>(color),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),

            // Weekly chart
            _BarChart(data: weekly, isDark: isDark, textColor: textColor, subColor: subColor, cardColor: cardColor, title: 'Last 7 Days — Points'),

            // Monthly chart
            _BarChart(data: monthly, isDark: isDark, textColor: textColor, subColor: subColor, cardColor: cardColor, title: 'Last 30 Days — Points'),
          ],
        ),
      );
    });
  }
}

class _SumCard extends StatelessWidget {
  final String value, label, emoji;
  final Color color;
  const _SumCard({required this.value, required this.label, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
      Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 10, fontFamily: 'Outfit'), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  );
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color color, cardColor, textColor, subColor;
  const _StatTile({required this.label, required this.value, required this.color, required this.cardColor, required this.textColor, required this.subColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: subColor, fontSize: 12, fontFamily: 'Outfit')),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
    ]),
  );
}

class _BarChart extends StatelessWidget {
  final Map<String, int> data;
  final bool isDark;
  final Color textColor, subColor, cardColor;
  final String title;

  const _BarChart({required this.data, required this.isDark, required this.textColor, required this.subColor, required this.cardColor, required this.title});

  @override
  Widget build(BuildContext context) {
    final values = data.values.toList();
    final maxVal = values.isEmpty ? 1 : (values.reduce((a, b) => a > b ? a : b)).clamp(1, 99999);
    final keys = data.keys.toList();
    final totalPts = values.fold<int>(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(title, style: TextStyle(color: textColor, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16)).animate().fadeIn(),
        const SizedBox(height: 4),
        Text('Total: $totalPts points', style: TextStyle(color: subColor, fontFamily: 'Outfit', fontSize: 13)).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
          child: SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(keys.length, (i) {
                final val = data[keys[i]] ?? 0;
                final ratio = val / maxVal;
                final isToday = i == keys.length - 1;
                final label = keys[i].split('-').last; // day number
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (val > 0) Text('$val', style: TextStyle(color: subColor, fontSize: 7, fontFamily: 'Outfit')),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: (ratio * 140).clamp(2.0, 140.0),
                          decoration: BoxDecoration(
                            color: isToday ? const Color(0xFFFF6B35) : const Color(0xFFFF6B35).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ).animate().scaleY(begin: 0, end: 1, alignment: Alignment.bottomCenter, delay: Duration(milliseconds: i * 30)),
                        const SizedBox(height: 6),
                        Text(label, style: TextStyle(color: subColor, fontSize: 8, fontFamily: 'Outfit')),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}