import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class UpdateTodoUseCase {
  final TodoRepository repository;

  const UpdateTodoUseCase(this.repository);

  Future<void> call(Todo todo) {
    return repository.updateTodo(todo);
  }
}
