import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:technestx/task_card.dart';
import 'package:technestx/task_model.dart';
import 'package:technestx/task_provider.dart';

import 'add_task_screen.dart';
import 'app_theme.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, provider, _) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
      final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
      final subColor = isDark ? AppTheme.darkSubText : AppTheme.lightSubText;
      final tasks = provider.filteredTasks;
      final tags = provider.allTags;

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          title: Text('All Tasks', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: textColor)),
          elevation: 0,
          actions: [
            if (provider.selectedTag != null || provider.selectedPriority != null)
              TextButton(
                onPressed: provider.clearFilters,
                child: const Text('Clear', style: TextStyle(color: Color(0xFFFF6B35), fontFamily: 'Outfit')),
              ),
          ],
        ),
        body: Column(
          children: [
            // Filter bar
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: provider.selectedPriority == null && provider.selectedTag == null,
                    onTap: provider.clearFilters,
                  ),
                  const SizedBox(width: 8),
                  ...Priority.values.map((p) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: AppTheme.priorityLabel(p.index),
                      color: AppTheme.priorityColor(p.index),
                      selected: provider.selectedPriority == p,
                      onTap: () => provider.setPriorityFilter(provider.selectedPriority == p ? null : p),
                    ),
                  )),
                  ...tags.map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: '#$t',
                      selected: provider.selectedTag == t,
                      onTap: () => provider.setTagFilter(provider.selectedTag == t ? null : t),
                    ),
                  )),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 8),

            Expanded(
              child: tasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📭', style: TextStyle(fontSize: 60)).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    Text('No tasks found', style: TextStyle(color: textColor, fontSize: 18, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Try different filters or add a new task', style: TextStyle(color: subColor, fontSize: 14, fontFamily: 'Outfit')),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: tasks.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskCard(task: tasks[i])
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: i * 60))
                      .slideX(begin: 0.1, end: 0, duration: 300.ms),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen())),
          backgroundColor: const Color(0xFFFF6B35),
          child: const Icon(Icons.add, color: Colors.white),
        ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = color ?? const Color(0xFFFF6B35);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.2) : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? activeColor : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? activeColor : (isDark ? AppTheme.darkSubText : AppTheme.lightSubText),
          fontFamily: 'Outfit',
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        )),
      ),
    );
  }
}