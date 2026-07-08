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
    } catch (_) {
      throw const ServerFailure('خطا در بارگذاری کارها.');
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
    } catch (_) {
      throw const ServerFailure('خطا در افزودن کار.');
    }
  }

  @override
  Future<void> update(TodoModel todo) async {
    try {
      final id = todo.id;
      final userId = _currentUserId();

      if (id == null) {
        throw const ServerFailure(
          'این کار شناسه معتبر ندارد و قابل ویرایش نیست.',
        );
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
    } catch (_) {
      throw const ServerFailure('خطا در ویرایش کار.');
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
    } catch (_) {
      throw const ServerFailure('خطا در حذف کار.');
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
      throw const AuthenticationFailure(
        'برای انجام این کار باید وارد حساب کاربری شوید.',
      );
    }

    return userId;
  }
}
