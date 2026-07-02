import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/todo_status.dart';
import '../../domain/entities/todo.dart';
import '../../domain/usecases/add_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_todos.dart';
import '../../domain/usecases/update_todo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodosUseCase getTodos;
  final AddTodoUseCase addTodo;
  final DeleteTodoUseCase deleteTodo;
  final UpdateTodoUseCase updateTodo;

  TodoBloc({
    required this.getTodos,
    required this.addTodo,
    required this.deleteTodo,
    required this.updateTodo,
  }) : super(const TodoLoading()) {
    on<LoadTodo>(_load);
    on<AddTodo>(_add);
    on<DeleteTodo>(_delete);
    on<ToggleTodo>(_toggle);
    on<UpdateTodo>(_update);
  }

  Future<void> _load(LoadTodo event, Emitter<TodoState> emit) async {
    try {
      emit(const TodoLoading());
      final todos = await getTodos();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError('خطا در بارگذاری کارها: $e'));
    }
  }

  Future<void> _add(AddTodo event, Emitter<TodoState> emit) async {
    try {
      _emitSaving(emit);
      await addTodo(event.todo);
      final todos = await getTodos();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError('خطا در افزودن کار: $e', previousTodos: _currentTodos));
    }
  }

  Future<void> _delete(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      _emitSaving(emit);
      await deleteTodo(event.id);
      final todos = await getTodos();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError('خطا در حذف کار: $e', previousTodos: _currentTodos));
    }
  }

  Future<void> _toggle(ToggleTodo event, Emitter<TodoState> emit) async {
    try {
      _emitSaving(emit);
      final updated = event.todo.copyWith(
        status: event.todo.status == TodoStatus.completed
            ? TodoStatus.pending
            : TodoStatus.completed,
      );
      await updateTodo(updated);
      final todos = await getTodos();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(
        TodoError('خطا در تغییر وضعیت کار: $e', previousTodos: _currentTodos),
      );
    }
  }

  Future<void> _update(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      _emitSaving(emit);
      await updateTodo(event.todo);
      final todos = await getTodos();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError('خطا در ویرایش کار: $e', previousTodos: _currentTodos));
    }
  }

  List<Todo> get _currentTodos {
    final currentState = state;
    if (currentState is TodoLoaded) return currentState.todos;
    if (currentState is TodoError) return currentState.previousTodos;
    return const [];
  }

  void _emitSaving(Emitter<TodoState> emit) {
    final currentState = state;
    if (currentState is TodoLoaded) {
      emit(TodoLoaded(currentState.todos, isSaving: true));
    }
  }
}
