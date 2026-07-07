import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failure.dart';
import '../constants/todo_table.dart';
import '../models/todo_model.dart';
import 'todo_remote_datasource.dart';

class SupabaseTodoRemoteDataSource implements TodoRemoteDataSource {
  final SupabaseClient client;

  SupabaseTodoRemoteDataSource(this.client);

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final userId = _currentUserId();
      final response = await client
          .from(TodoTable.name)
          .select()
          .eq(TodoTable.userId, userId)
          .order(TodoTable.createdAt, ascending: false);

      return List<Map<String, dynamic>>.from(
        response,
      ).map(TodoModel.fromMap).toList();
    } on Failure {
      rethrow;
    } on PostgrestException catch (error) {
      throw ServerFailure(error.message);
    } catch (error) {
      throw ServerFailure('Failed to load todos: $error');
    }
  }

  @override
  Future<void> insert(TodoModel todo) async {
    try {
      final payload = _payloadForSave(todo);
      payload[TodoTable.userId] = _currentUserId();

      await client.from(TodoTable.name).insert(payload);
    } on Failure {
      rethrow;
    } on PostgrestException catch (error) {
      throw ServerFailure(error.message);
    } catch (error) {
      throw ServerFailure('Failed to add todo: $error');
    }
  }

  @override
  Future<void> update(TodoModel todo) async {
    try {
      final id = todo.id;
      final userId = _currentUserId();

      if (id == null) {
        throw const ServerFailure('Cannot update a todo without an id.');
      }

      await client
          .from(TodoTable.name)
          .update(_payloadForSave(todo))
          .eq(TodoTable.id, id)
          .eq(TodoTable.userId, userId);
    } on Failure {
      rethrow;
    } on PostgrestException catch (error) {
      throw ServerFailure(error.message);
    } catch (error) {
      throw ServerFailure('Failed to update todo: $error');
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await client
          .from(TodoTable.name)
          .delete()
          .eq(TodoTable.id, id)
          .eq(TodoTable.userId, _currentUserId());
    } on Failure {
      rethrow;
    } on PostgrestException catch (error) {
      throw ServerFailure(error.message);
    } catch (error) {
      throw ServerFailure('Failed to delete todo: $error');
    }
  }

  Map<String, dynamic> _payloadForSave(TodoModel todo) {
    return todo.toMap()
      ..remove(TodoTable.id)
      ..remove(TodoTable.createdAt)
      ..remove(TodoTable.updatedAt);
  }

  String _currentUserId() {
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      throw const AuthenticationFailure('A signed-in user is required.');
    }

    return userId;
  }
}
