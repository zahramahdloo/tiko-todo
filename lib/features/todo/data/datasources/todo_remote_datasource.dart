import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<void> insert(TodoModel todo);
  Future<void> update(TodoModel todo);
  Future<void> delete(int id);
}
