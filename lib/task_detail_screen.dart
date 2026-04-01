import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:technestx/task_model.dart';
import 'package:technestx/task_provider.dart';
import 'package:technestx/badge_model.dart';
import 'add_task_screen.dart';
import 'app_theme.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _completing = false;

  Future<void> _complete() async {
    if (_completing) return;
    setState(() => _completing = true);
    final provider = context.read<TaskProvider>();
    // FIX: completeTask returns List<AppBadge> — no more Badge getter errors
    final List<AppBadge> newBadges =
    await provider.completeTask(widget.task.id);

    if (mounted) {
      if (newBadges.isNotEmpty) {
        _showBadgeDialog(newBadges);
      } else {
        _showPointsSnack(widget.task.points);
        Navigator.pop(context);
      }
    }
  }

  void _showPointsSnack(int pts) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('🎉 Task complete! +$pts points',
          style: GoogleFonts.outfit()),
      backgroundColor: const Color(0xFF06D6A0),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  // FIX: parameter type is now List<AppBadge>; .emoji / .title / .description
  // all exist on AppBadge — no more "getter not defined for type Badge" errors.
  void _showBadgeDialog(List<AppBadge> badges) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie celebration animation
            SizedBox(
              height: 120,
              child: Lottie.asset(
                'assets/lottie/celebration.json',
                repeat: false,
                errorBuilder: (_, __, ___) =>
                const Text('🎊', style: TextStyle(fontSize: 60)),
              ),
            ).animate().scale(
                duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text(
              'Badge Unlocked!',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...badges.map((b) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // FIX: b.emoji — now valid on AppBadge
                  Text(b.emoji,
                      style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FIX: b.title — now valid on AppBadge
                        Text(b.title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                        // FIX: b.description — now valid on AppBadge
                        Text(b.description,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF8888AA),
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Text(
              '+${widget.task.points} pts earned',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFF6B35),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // detail
            },
            child: Text(
              'Awesome! 🚀',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFF6B35),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, provider, _) {
      final task = provider.tasks.firstWhere(
            (t) => t.id == widget.task.id,
        orElse: () => widget.task,
      );
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
      final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
      final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
      final subColor = isDark ? AppTheme.darkSubText : AppTheme.lightSubText;
      final priorityColor = AppTheme.priorityColor(task.priority.index);
      final isComplete = task.status == TaskStatus.completed;

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (!isComplete)
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Color(0xFFFF6B35)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddTaskScreen(editTask: task)),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Color(0xFFEF476F)),
              onPressed: () => _confirmDelete(context, provider, task.id),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion status banner with Lottie
              if (isComplete)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06D6A0).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: Lottie.asset(
                          'assets/lottie/checkmark.json',
                          repeat: false,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.check_circle,
                            color: Color(0xFF06D6A0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Completed!',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF06D6A0),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

              if (isComplete) const SizedBox(height: 20),

              // Priority + tag row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${['🌿', '⚡', '🔥'][task.priority.index]} ${AppTheme.priorityLabel(task.priority.index)}',
                      style: GoogleFonts.outfit(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (task.tag.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#${task.tag}',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF4ECDC4),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+${task.points} pts',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFF6B35),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 20),

              Text(
                task.title,
                style: GoogleFonts.outfit(
                  color: textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),

              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  task.description,
                  style: GoogleFonts.outfit(
                    color: subColor,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ],

              const SizedBox(height: 24),

              // Dates card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _DateRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Created',
                      value: DateFormat('EEE, MMM d, y • h:mm a')
                          .format(task.createdAt),
                      color: subColor,
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 12),
                      _DateRow(
                        icon: Icons.event_rounded,
                        label: 'Due',
                        value: DateFormat('EEE, MMM d, y')
                            .format(task.dueDate!),
                        color: task.dueDate!.isBefore(DateTime.now()) &&
                            !isComplete
                            ? const Color(0xFFEF476F)
                            : subColor,
                      ),
                    ],
                    if (task.completedAt != null) ...[
                      const SizedBox(height: 12),
                      _DateRow(
                        icon: Icons.check_circle_rounded,
                        label: 'Completed',
                        value: DateFormat('EEE, MMM d, y • h:mm a')
                            .format(task.completedAt!),
                        color: const Color(0xFF06D6A0),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 40),

              if (!isComplete)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _completing ? null : _complete,
                    icon: _completing
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : const Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white),
                    label: Text(
                      _completing ? 'Completing...' : 'Mark as Complete 🎉',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06D6A0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1)),
            ],
          ),
        ),
      );
    });
  }

  void _confirmDelete(
      BuildContext context, TaskProvider provider, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Task',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this task?',
            style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteTask(id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFEF476F))),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DateRow(
      {required this.icon,
        required this.label,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.outfit(
                  color: color, fontSize: 11)),
          Text(value,
              style: GoogleFonts.outfit(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    ],
  );
}