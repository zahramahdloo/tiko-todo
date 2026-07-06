import 'dart:convert';

import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';
import '../../domain/entities/todo.dart';

class TodoModel {
  final int? id;
  final String title;
  final String status;
  final String priority;
  final int? reminderAt;
  final int? dueAt;
  final int? completedAt;
  final String category;
  final String subtasks;
  final bool isArchived;

  TodoModel({
    this.id,
    required this.title,
    required this.status,
    required this.priority,
    this.reminderAt,
    this.dueAt,
    this.completedAt,
    this.category = 'شخصی',
    this.subtasks = '[]',
    this.isArchived = false,
  });

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: _parseId(map['id']),
      title: map['title'] as String? ?? '',
      status: map['status'] as String? ?? TodoStatus.pending.name,
      priority: map['priority'] as String? ?? TodoPriority.normal.name,
      reminderAt: _parseDateToMillis(map['reminder_at']),
      dueAt: _parseDateToMillis(map['due_at']),
      completedAt: _parseDateToMillis(map['completed_at']),
      category: map['category'] as String? ?? 'شخصی',
      subtasks: _normalizeSubtasksToString(map['subtasks']),
      isArchived: _parseBool(map['is_archived']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'status': status,
      'priority': priority,
      'reminder_at': _millisToIsoString(reminderAt),
      'due_at': _millisToIsoString(dueAt),
      'completed_at': _millisToIsoString(completedAt),
      'category': category,
      'subtasks': _subtasksForSupabase(subtasks),
      'is_archived': isArchived,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      status: _statusFromString(status),
      priority: _priorityFromString(priority),
      reminderAt: reminderAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(reminderAt!),
      dueAt: dueAt == null ? null : DateTime.fromMillisecondsSinceEpoch(dueAt!),
      completedAt: completedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(completedAt!),
      category: category,
      subtasks: _subtasksToEntity(subtasks),
      isArchived: isArchived,
    );
  }

  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      title: todo.title,
      status: todo.status.name,
      priority: todo.priority.name,
      reminderAt: todo.reminderAt?.millisecondsSinceEpoch,
      dueAt: todo.dueAt?.millisecondsSinceEpoch,
      completedAt: todo.completedAt?.millisecondsSinceEpoch,
      category: todo.category,
      subtasks: jsonEncode(
        todo.subtasks
            .map(
              (subtask) => {
                'title': subtask.title,
                'isCompleted': subtask.isCompleted,
              },
            )
            .toList(),
      ),
      isArchived: todo.isArchived,
    );
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int? _parseDateToMillis(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final numericValue = int.tryParse(value);
      if (numericValue != null) return numericValue;

      final parsedDate = DateTime.tryParse(value);
      return parsedDate?.millisecondsSinceEpoch;
    }

    return null;
  }

  static String? _millisToIsoString(int? value) {
    if (value == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(value).toUtc().toIso8601String();
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == 'true' || value == '1';
    return false;
  }

  static TodoStatus _statusFromString(String value) {
    return TodoStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => TodoStatus.pending,
    );
  }

  static TodoPriority _priorityFromString(String value) {
    return TodoPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => TodoPriority.normal,
    );
  }

  static String _normalizeSubtasksToString(dynamic value) {
    if (value == null) return '[]';

    if (value is String) {
      if (value.trim().isEmpty) return '[]';
      return value;
    }

    if (value is List) {
      return jsonEncode(value);
    }

    return '[]';
  }

  static List<Map<String, dynamic>> _subtasksForSupabase(String value) {
    try {
      final decoded = jsonDecode(value);

      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  static List<TodoSubtask> _subtasksToEntity(String value) {
    try {
      final decoded = jsonDecode(value);

      if (decoded is! List) return [];

      return decoded
          .map((item) {
            if (item is Map<String, dynamic>) {
              return TodoSubtask(
                title: item['title'] as String? ?? '',
                isCompleted: item['isCompleted'] as bool? ?? false,
              );
            }

            if (item is Map) {
              return TodoSubtask(
                title: item['title'] as String? ?? '',
                isCompleted: item['isCompleted'] as bool? ?? false,
              );
            }

            return const TodoSubtask(title: '');
          })
          .where((subtask) => subtask.title.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
