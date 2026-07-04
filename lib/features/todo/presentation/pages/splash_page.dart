import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/account/account_settings_controller.dart';
import '../../../../core/di/injection.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      final settings = sl<AccountSettingsController>();
      context.go(settings.isSignedIn ? '/home' : '/auth');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/app_icon.png', width: 80, height: 80)
                .animate()
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 600.ms),
            const SizedBox(height: 20),
            const Text(
                  'تیکو',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IranYekan',
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
