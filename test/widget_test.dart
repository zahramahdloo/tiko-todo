import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/core/enums/todo_priority.dart';
import 'package:todo_app/core/enums/todo_status.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';
import 'package:todo_app/features/todo/domain/entities/todo.dart';

void main() {
  test('TodoModel converts between database map and entity safely', () {
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
}
