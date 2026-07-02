import 'package:supabase_flutter/supabase_flutter.dart';

class TodoRemoteDataSource {
  final SupabaseClient client;

  TodoRemoteDataSource(this.client);

  Future<List<Map<String, dynamic>>> getTodos() async {
    final userId = _currentUserId();
    final response = await client
        .from('todos')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> insert(Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data)
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');

    payload['user_id'] = _currentUserId();

    await client.from('todos').insert(payload);
  }

  Future<void> update(Map<String, dynamic> data) async {
    final id = data['id'];
    final userId = _currentUserId();

    if (id == null) {
      throw ArgumentError('Cannot update a todo without an id.');
    }

    final payload = Map<String, dynamic>.from(data)
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');

    await client
        .from('todos')
        .update(payload)
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> delete(int id) async {
    await client
        .from('todos')
        .delete()
        .eq('id', id)
        .eq('user_id', _currentUserId());
  }

  String _currentUserId() {
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      throw StateError('A signed-in Supabase user is required.');
    }

    return userId;
  }
}
