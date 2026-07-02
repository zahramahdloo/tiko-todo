import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/todo/data/datasources/todo_remote_datasource.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';
import '../../features/todo/domain/usecases/add_todo.dart';
import '../../features/todo/domain/usecases/delete_todo.dart';
import '../../features/todo/domain/usecases/get_todos.dart';
import '../../features/todo/domain/usecases/update_todo.dart';
import '../../features/todo/presentation/bloc/todo_bloc.dart';
import '../account/account_settings_controller.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSource(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(sl<TodoRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetTodosUseCase>(
    () => GetTodosUseCase(sl<TodoRepository>()),
  );
  sl.registerLazySingleton<AddTodoUseCase>(
    () => AddTodoUseCase(sl<TodoRepository>()),
  );
  sl.registerLazySingleton<DeleteTodoUseCase>(
    () => DeleteTodoUseCase(sl<TodoRepository>()),
  );
  sl.registerLazySingleton<UpdateTodoUseCase>(
    () => UpdateTodoUseCase(sl<TodoRepository>()),
  );

  final accountSettingsController = AccountSettingsController(
    sl<SupabaseClient>(),
  );
  await accountSettingsController.load();

  sl.registerSingleton<AccountSettingsController>(accountSettingsController);

  sl.registerFactory<TodoBloc>(
    () => TodoBloc(
      getTodos: sl<GetTodosUseCase>(),
      addTodo: sl<AddTodoUseCase>(),
      deleteTodo: sl<DeleteTodoUseCase>(),
      updateTodo: sl<UpdateTodoUseCase>(),
    ),
  );
}
