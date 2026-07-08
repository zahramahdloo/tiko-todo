import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/presentation/pages/auth_page.dart';
import '../../features/todo/presentation/bloc/todo_bloc.dart';
import '../../features/todo/presentation/bloc/todo_event.dart';
import '../../features/todo/presentation/pages/main_shell_page.dart';
import '../../features/todo/presentation/pages/splash_page.dart';
import '../account/account_settings_controller.dart';
import '../di/injection.dart';
import 'app_routes.dart';

GoRouter createAppRouter(AccountSettingsController settings) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: settings,
    redirect: (context, state) {
      final location = state.uri.path;
      final isPublicRoute =
          location == AppRoutes.splash || location == AppRoutes.auth;

      if (!settings.isSignedIn && !isPublicRoute) {
        return AppRoutes.auth;
      }

      if (settings.isSignedIn && location == AppRoutes.auth) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthPage(),
      ),
      _todoShellRoute(path: AppRoutes.home),
      _todoShellRoute(path: AppRoutes.settings, initialIndex: 4),
      _todoShellRoute(path: AppRoutes.archive, initialIndex: 3),
    ],
  );
}

GoRoute _todoShellRoute({required String path, int initialIndex = 0}) {
  return GoRoute(
    path: path,
    builder: (context, state) => BlocProvider<TodoBloc>(
      create: (_) => sl<TodoBloc>()..add(const LoadTodo()),
      child: MainShellPage(initialIndex: initialIndex),
    ),
  );
}
