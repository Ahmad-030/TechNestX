import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:technestx/task_model.dart';
import 'package:technestx/task_provider.dart';

import 'package:intl/intl.dart';

import 'app_theme.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? editTask;
  const AddTaskScreen({super.key, this.editTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _tagCtrl;
  Priority _priority = Priority.medium;
  DateTime? _dueDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.editTask;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _tagCtrl = TextEditingController(text: t?.tag ?? '');
    _priority = t?.priority ?? Priority.medium;
    _dueDate = t?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<TaskProvider>();
    if (widget.editTask != null) {
      final updated = widget.editTask!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _priority,
        tag: _tagCtrl.text.trim(),
        dueDate: _dueDate,
      );
      await provider.updateTask(updated);
    } else {
      final task = Task(
        id: provider.generateId(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _priority,
        tag: _tagCtrl.text.trim(),
        dueDate: _dueDate,
        createdAt: DateTime.now(),
      );
      await provider.addTask(task);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final subColor = isDark ? AppTheme.darkSubText : AppTheme.lightSubText;
    final isEditing = widget.editTask != null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(isEditing ? 'Edit Task' : 'New Task', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: textColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textColor), onPressed: () => Navigator.pop(context)),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title
            _SectionLabel(text: 'Task Title', color: subColor),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              style: TextStyle(color: textColor, fontFamily: 'Outfit'),
              decoration: const InputDecoration(hintText: 'What needs to be done?', prefixIcon: Icon(Icons.title_rounded, color: Color(0xFFFF6B35))),
              validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 20),

            // Description
            _SectionLabel(text: 'Description (optional)', color: subColor),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              style: TextStyle(color: textColor, fontFamily: 'Outfit'),
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Add more details...', prefixIcon: Icon(Icons.notes_rounded, color: Color(0xFFFF6B35))),
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 20),

            // Priority
            _SectionLabel(text: 'Priority', color: subColor),
            const SizedBox(height: 8),
            Row(
              children: Priority.values.map((p) {
                final selected = _priority == p;
                final color = AppTheme.priorityColor(p.index);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? color.withOpacity(0.2) : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? color : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder), width: selected ? 2 : 1),
                      ),
                      child: Column(
                        children: [
                          Text(['🌿', '⚡', '🔥'][p.index], style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(AppTheme.priorityLabel(p.index),
                              style: TextStyle(color: selected ? color : subColor, fontFamily: 'Outfit', fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 20),

            // Tag
            _SectionLabel(text: 'Tag', color: subColor),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tagCtrl,
              style: TextStyle(color: textColor, fontFamily: 'Outfit'),
              decoration: const InputDecoration(hintText: 'e.g. Work, Study, Health', prefixIcon: Icon(Icons.label_rounded, color: Color(0xFFFF6B35))),
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 20),

            // Due Date
            _SectionLabel(text: 'Due Date (optional)', color: subColor),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Color(0xFFFF6B35), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _dueDate == null ? 'Select due date' : DateFormat('EEE, MMM d, y').format(_dueDate!),
                      style: TextStyle(color: _dueDate == null ? subColor : textColor, fontFamily: 'Outfit'),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: Icon(Icons.clear_rounded, color: subColor, size: 20),
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 40),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEditing ? 'Update Task' : 'Add Task 🪺'),
              ),
            ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFFFF6B35)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(color: color, fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.w500));
}