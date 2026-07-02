import 'package:go_router/go_router.dart';

import '../../features/account/presentation/pages/auth_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/todo/presentation/bloc/todo_bloc.dart';
import '../../features/todo/presentation/bloc/todo_event.dart';
import '../../features/todo/presentation/pages/splash_page.dart';
import '../../features/todo/presentation/pages/todo_page.dart';
import '../di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
    GoRoute(
      path: '/home',
      builder: (context, state) => BlocProvider<TodoBloc>(
        create: (_) => sl<TodoBloc>()..add(const LoadTodo()),
        child: const TodoPage(),
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
