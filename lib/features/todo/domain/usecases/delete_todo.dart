import '../repositories/todo_repository.dart';

class DeleteTodoUseCase {
  final TodoRepository repository;

  const DeleteTodoUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteTodo(id);
  }
}
