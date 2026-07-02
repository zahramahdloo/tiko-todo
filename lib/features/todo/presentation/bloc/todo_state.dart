import 'package:equatable/equatable.dart';

import '../../domain/entities/todo.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoLoading extends TodoState {
  const TodoLoading();
}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  final bool isSaving;

  const TodoLoaded(this.todos, {this.isSaving = false});

  @override
  List<Object?> get props => [todos, isSaving];
}

class TodoError extends TodoState {
  final String message;
  final List<Todo> previousTodos;

  const TodoError(this.message, {this.previousTodos = const []});

  @override
  List<Object?> get props => [message, previousTodos];
}
