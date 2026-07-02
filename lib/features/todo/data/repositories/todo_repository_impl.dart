import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_remote_datasource.dart';

import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remote;

  TodoRepositoryImpl(this.remote);

  @override
  Future<List<Todo>> getTodos() async {
    final data = await remote.getTodos();
    return data.map((e) => TodoModel.fromMap(e).toEntity()).toList();
  }

  @override
  Future<void> addTodo(Todo todo) {
    return remote.insert(TodoModel.fromEntity(todo).toMap());
  }

  @override
  Future<void> deleteTodo(int id) {
    return remote.delete(id);
  }

  @override
  Future<void> updateTodo(Todo todo) {
    return remote.update(TodoModel.fromEntity(todo).toMap());
  }
}
