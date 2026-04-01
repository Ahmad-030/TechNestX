import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:technestx/task_detail_screen.dart';
import 'package:technestx/task_model.dart';
import 'package:technestx/task_provider.dart';
import 'package:technestx/badge_model.dart';
import 'app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final subColor = isDark ? AppTheme.darkSubText : AppTheme.lightSubText;
    final priorityColor = AppTheme.priorityColor(task.priority.index);
    final isComplete = task.status == TaskStatus.completed;
    final isOverdue =
        !isComplete && task.dueDate != null && task.dueDate!.isBefore(DateTime.now());

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task))),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isComplete
                ? const Color(0xFF06D6A0).withValues(alpha: 0.3)
                : (isOverdue
                ? const Color(0xFFEF476F).withValues(alpha: 0.3)
                : Colors.transparent),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: priorityColor.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Priority indicator bar
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: isComplete ? const Color(0xFF06D6A0) : priorityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Checkbox
            GestureDetector(
              onTap: isComplete ? null : () => _complete(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isComplete ? const Color(0xFF06D6A0) : Colors.transparent,
                  border: Border.all(
                    color: isComplete ? const Color(0xFF06D6A0) : priorityColor,
                    width: 2,
                  ),
                ),
                child: isComplete
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.outfit(
                        color: isComplete ? subColor : textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: isComplete ? TextDecoration.lineThrough : null,
                        decorationColor: subColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        style: GoogleFonts.outfit(color: subColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (task.tag.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#${task.tag}',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF4ECDC4),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (task.dueDate != null)
                          Row(
                            children: [
                              Icon(
                                Icons.event_rounded,
                                size: 12,
                                color: isOverdue
                                    ? const Color(0xFFEF476F)
                                    : subColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                DateFormat('MMM d').format(task.dueDate!),
                                style: GoogleFonts.outfit(
                                  color: isOverdue
                                      ? const Color(0xFFEF476F)
                                      : subColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Points badge
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                children: [
                  Text(
                    '+${task.points}',
                    style: GoogleFonts.outfit(
                      color: isComplete ? const Color(0xFF06D6A0) : priorityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'pts',
                    style: GoogleFonts.outfit(color: subColor, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _complete(BuildContext context) async {
    final provider = context.read<TaskProvider>();
    // FIX: completeTask now returns List<AppBadge>, not Flutter's List<Badge>
    final List<AppBadge> newBadges = await provider.completeTask(task.id);
    if (context.mounted) {
      if (newBadges.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          // FIX: .title is now valid — AppBadge has title field
          content: Text(
            '🏅 Badge unlocked: ${newBadges.first.title}! +${task.points}pts',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: const Color(0xFFFF6B35),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            '✅ Done! +${task.points} points',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: const Color(0xFF06D6A0),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }
}