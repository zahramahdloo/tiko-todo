import 'package:equatable/equatable.dart';

import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';

class TodoSubtask extends Equatable {
  final String title;
  final bool isCompleted;

  const TodoSubtask({required this.title, this.isCompleted = false});

  TodoSubtask copyWith({String? title, bool? isCompleted}) {
    return TodoSubtask(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [title, isCompleted];
}

class Todo extends Equatable {
  final int? id;
  final String title;
  final TodoStatus status;
  final TodoPriority priority;
  final DateTime? reminderAt;
  final DateTime? dueAt;
  final String category;
  final List<TodoSubtask> subtasks;
  final bool isArchived;

  const Todo({
    this.id,
    required this.title,
    required this.status,
    required this.priority,
    this.reminderAt,
    this.dueAt,
    this.category = 'شخصی',
    this.subtasks = const [],
    this.isArchived = false,
  });

  Todo copyWith({
    int? id,
    String? title,
    TodoStatus? status,
    TodoPriority? priority,
    DateTime? reminderAt,
    DateTime? dueAt,
    String? category,
    List<TodoSubtask>? subtasks,
    bool? isArchived,
    bool clearReminder = false,
    bool clearDueAt = false,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      category: category ?? this.category,
      subtasks: subtasks ?? this.subtasks,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    status,
    priority,
    reminderAt,
    dueAt,
    category,
    subtasks,
    isArchived,
  ];
}
