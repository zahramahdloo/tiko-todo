import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/account/account_settings_controller.dart';
import '../../../../core/di/injection.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final controller = sl<AccountSettingsController>();
    final error = _isSignUp
        ? await controller.signUp(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          )
        : await controller.signIn(email: _emailController.text, password: _passwordController.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Image.asset('assets/icons/app_icon.png', width: 50, height: 50)),
                  const SizedBox(height: 16),
                  Text(
                    _isSignUp ? 'ساخت حساب تیکو' : 'ورود به تیکو',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'کارها، تنظیمات و ظاهر اپ روی همین دستگاه برای حساب شما ذخیره می‌شود.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 28),
                  if (_isSignUp) ...[
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'نام کاربر',
                        prefixIcon: Center(
                          widthFactor: 1,
                          child: FaIcon(FontAwesomeIcons.user, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'ایمیل',
                      prefixIcon: Center(
                        widthFactor: 1,
                        child: FaIcon(FontAwesomeIcons.envelope, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'رمز عبور',
                      prefixIcon: const Center(
                        widthFactor: 1,
                        child: FaIcon(FontAwesomeIcons.lock, size: 18),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: FaIcon(
                          _obscurePassword ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isSignUp ? 'ثبت‌نام' : 'ورود'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(_isSignUp ? 'حساب داری؟ وارد شو' : 'حساب نداری؟ ثبت‌نام کن'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
