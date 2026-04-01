import 'dart:convert';

enum Priority { low, medium, high }
enum TaskStatus { pending, completed }

class Task {
  final String id;
  String title;
  String description;
  Priority priority;
  String tag;
  DateTime? dueDate;
  TaskStatus status;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = Priority.medium,
    this.tag = '',
    this.dueDate,
    this.status = TaskStatus.pending,
    required this.createdAt,
    this.completedAt,
  });

  int get points {
    switch (priority) {
      case Priority.low:
        return 10;
      case Priority.medium:
        return 20;
      case Priority.high:
        return 40;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority.index,
    'tag': tag,
    'dueDate': dueDate?.toIso8601String(),
    'status': status.index,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    priority: Priority.values[json['priority'] ?? 1],
    tag: json['tag'] ?? '',
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    status: TaskStatus.values[json['status'] ?? 0],
    createdAt: DateTime.parse(json['createdAt']),
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
  );

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    String? tag,
    DateTime? dueDate,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      tag: tag ?? this.tag,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}