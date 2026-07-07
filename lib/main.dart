import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/account/account_settings_controller.dart';
import 'core/config/supabase_config.dart';
import 'core/di/injection.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SupabaseConfig.validate();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  await initDI();
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = sl<AccountSettingsController>();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'تیکو',
          locale: const Locale('fa'),
          supportedLocales: const [Locale('fa'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(settings.primaryColor),
          darkTheme: AppTheme.dark(settings.primaryColor),
          themeMode: settings.themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
