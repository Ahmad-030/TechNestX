import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:technestx/task_model.dart';
import 'package:technestx/task_provider.dart';
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
    final newBadges = await provider.completeTask(widget.task.id);

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
      content: Text('🎉 Task complete! +$pts points', style: const TextStyle(fontFamily: 'Outfit')),
      backgroundColor: const Color(0xFF06D6A0),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  void _showBadgeDialog(List<Badge> badges) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎊', style: TextStyle(fontSize: 60)).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            const Text('Badge Unlocked!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            const SizedBox(height: 20),
            ...badges.map((b) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFF6B35).withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Text(b.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.title, style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                      Text(b.description, style: const TextStyle(color: Color(0xFF8888AA), fontFamily: 'Outfit', fontSize: 12)),
                    ],
                  )),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Text('+${widget.task.points} pts earned', style: const TextStyle(color: Color(0xFFFF6B35), fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // detail
            },
            child: const Text('Awesome! 🚀', style: TextStyle(color: Color(0xFFFF6B35), fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, provider, _) {
      // Get latest task state
      final task = provider.tasks.firstWhere((t) => t.id == widget.task.id, orElse: () => widget.task);
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
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textColor), onPressed: () => Navigator.pop(context)),
          actions: [
            if (!isComplete)
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Color(0xFFFF6B35)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTaskScreen(editTask: task))),
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
              // Status banner
              if (isComplete)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF06D6A0).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('✅ Completed!', style: TextStyle(color: Color(0xFF06D6A0), fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 15))),
                ).animate().fadeIn(),

              if (isComplete) const SizedBox(height: 20),

              // Priority + tag row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: priorityColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text('${['🌿', '⚡', '🔥'][task.priority.index]} ${AppTheme.priorityLabel(task.priority.index)}',
                        style: TextStyle(color: priorityColor, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  if (task.tag.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF4ECDC4).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text('#${task.tag}', style: const TextStyle(color: Color(0xFF4ECDC4), fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFF6B35).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text('+${task.points} pts', style: const TextStyle(color: Color(0xFFFF6B35), fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 20),

              Text(task.title, style: TextStyle(color: textColor, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Outfit'))
                  .animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),

              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(task.description, style: TextStyle(color: subColor, fontSize: 15, fontFamily: 'Outfit', height: 1.6))
                    .animate().fadeIn(delay: 200.ms),
              ],

              const SizedBox(height: 24),

              // Dates
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _DateRow(icon: Icons.calendar_today_rounded, label: 'Created', value: DateFormat('EEE, MMM d, y • h:mm a').format(task.createdAt), color: subColor),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 12),
                      _DateRow(
                        icon: Icons.event_rounded,
                        label: 'Due',
                        value: DateFormat('EEE, MMM d, y').format(task.dueDate!),
                        color: task.dueDate!.isBefore(DateTime.now()) && !isComplete ? const Color(0xFFEF476F) : subColor,
                      ),
                    ],
                    if (task.completedAt != null) ...[
                      const SizedBox(height: 12),
                      _DateRow(icon: Icons.check_circle_rounded, label: 'Completed', value: DateFormat('EEE, MMM d, y • h:mm a').format(task.completedAt!), color: const Color(0xFF06D6A0)),
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
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                    label: Text(_completing ? 'Completing...' : 'Mark as Complete 🎉',
                        style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06D6A0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
            ],
          ),
        ),
      );
    });
  }

  void _confirmDelete(BuildContext context, TaskProvider provider, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task', style: TextStyle(fontFamily: 'Outfit')),
        content: const Text('Are you sure you want to delete this task?', style: TextStyle(fontFamily: 'Outfit')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await provider.deleteTask(id);
              if (context.mounted) {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // detail
              }
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF476F))),
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

  const _DateRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11, fontFamily: 'Outfit')),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.w500)),
        ],
      ),
    ],
  );
}