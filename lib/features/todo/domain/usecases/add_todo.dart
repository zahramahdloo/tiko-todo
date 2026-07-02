import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class AddTodoUseCase {
  final TodoRepository repository;

  const AddTodoUseCase(this.repository);

  Future<void> call(Todo todo) {
    return repository.addTodo(todo);
  }
}
