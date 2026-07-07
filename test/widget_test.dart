import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/core/enums/todo_priority.dart';
import 'package:todo_app/core/enums/todo_status.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';
import 'package:todo_app/features/todo/domain/entities/todo.dart';

void main() {
  group('TodoModel', () {
    test('converts between database map and entity safely', () {
      final reminderAt = DateTime(2026, 6, 29, 10, 30);
      final todo = Todo(
        id: 7,
        title: 'Pay bills',
        status: TodoStatus.inProgress,
        priority: TodoPriority.high,
        reminderAt: reminderAt,
      );

      final map = TodoModel.fromEntity(todo).toMap();
      final entity = TodoModel.fromMap(map).toEntity();

      expect(entity, todo);
    });

    test('normalizes invalid remote enum values to safe defaults', () {
      final entity = TodoModel.fromMap({
        'id': 1,
        'title': 'Remote task',
        'status': 'unknown',
        'priority': 'unknown',
        'subtasks': <Map<String, Object?>>[],
      }).toEntity();

      expect(entity.status, TodoStatus.pending);
      expect(entity.priority, TodoPriority.normal);
    });

    test('maps Supabase jsonb subtasks to domain subtasks', () {
      final entity = TodoModel.fromMap({
        'id': 1,
        'title': 'Remote task',
        'subtasks': [
          {'title': 'First step', 'isCompleted': true},
          {'title': 'Second step', 'isCompleted': false},
        ],
      }).toEntity();

      expect(entity.subtasks, const [
        TodoSubtask(title: 'First step', isCompleted: true),
        TodoSubtask(title: 'Second step'),
      ]);
    });
  });
}
