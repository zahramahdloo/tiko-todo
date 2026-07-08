import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../error/api_error_messages.dart';
import 'app_user.dart';

class AccountSettingsController extends ChangeNotifier {
  static const _primaryColorKey = 'primary_color';
  static const _themeModeKey = 'theme_mode';
  static const _hideCompletedKey = 'hide_completed';

  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _authStateSubscription;

  AppUser? _currentUser;
  Color _primaryColor = const Color(0xFF2463EB);
  ThemeMode _themeMode = ThemeMode.system;
  bool _hideCompleted = false;
  bool _isLoaded = false;

  AccountSettingsController(this._client) {
    _authStateSubscription = _client.auth.onAuthStateChange.listen((state) {
      _setCurrentUser(state.session?.user);
    });
  }

  AppUser? get currentUser => _currentUser;
  Color get primaryColor => _primaryColor;
  ThemeMode get themeMode => _themeMode;
  bool get hideCompleted => _hideCompleted;
  bool get isLoaded => _isLoaded;
  bool get isSignedIn => _currentUser != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final colorValue = prefs.getString(_primaryColorKey);
    final themeModeValue = prefs.getString(_themeModeKey);

    if (colorValue != null) {
      _primaryColor = Color(
        int.tryParse(colorValue) ?? _primaryColor.toARGB32(),
      );
    }

    if (themeModeValue != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == themeModeValue,
        orElse: () => ThemeMode.system,
      );
    }

    _hideCompleted = prefs.getBool(_hideCompletedKey) ?? false;

    _currentUser = _mapNullableSupabaseUser(_client.auth.currentUser);

    _isLoaded = true;
    notifyListeners();
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();

    if (trimmedName.length < 2) return 'نام نمایشی را حداقل با ۲ حرف وارد کنید';
    if (!normalizedEmail.contains('@')) {
      return 'ایمیل را با قالب درست وارد کنید';
    }
    if (password.length < 6) return 'رمز عبور باید حداقل ۶ کاراکتر باشد';

    try {
      final response = await _client.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {'name': trimmedName},
      );

      final user = response.user;
      if (user != null) {
        _setCurrentUser(user);
      }

      return null;
    } on AuthException catch (e) {
      return _authErrorMessage(e.message);
    } catch (_) {
      return 'ساخت حساب تیکو انجام نشد. دوباره تلاش کنید';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (!normalizedEmail.contains('@')) {
      return 'ایمیل را با قالب درست وارد کنید';
    }
    if (password.isEmpty) return 'رمز عبور حساب تیکو را وارد کنید';

    try {
      final response = await _client.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = response.user;
      if (user == null) return 'ورود به تیکو انجام نشد';

      _setCurrentUser(user);
      return null;
    } on AuthException catch (e) {
      return _authErrorMessage(e.message);
    } catch (_) {
      return 'ورود به تیکو انجام نشد. دوباره تلاش کنید';
    }
  }

  Future<String?> signOut() async {
    try {
      await _client.auth.signOut();
      _setCurrentUser(null);
      return null;
    } on AuthException catch (e) {
      return _authErrorMessage(e.message);
    } catch (_) {
      return 'خروج از حساب تیکو انجام نشد. دوباره تلاش کنید';
    }
  }

  Future<String?> updateProfileName(String name) async {
    final user = _currentUser;
    final trimmed = name.trim();

    if (user == null) return 'برای ویرایش پروفایل، دوباره وارد حساب تیکو شوید';
    if (trimmed.length < 2) return 'نام نمایشی را حداقل با ۲ حرف وارد کنید';

    try {
      final response = await _client.auth.updateUser(
        UserAttributes(data: {'name': trimmed}),
      );

      _setCurrentUser(response.user, fallback: user.copyWith(name: trimmed));
      return null;
    } on AuthException catch (e) {
      return _authErrorMessage(e.message);
    } catch (_) {
      return 'نام نمایشی ذخیره نشد. دوباره تلاش کنید';
    }
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_primaryColorKey, color.toARGB32().toString());

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);

    notifyListeners();
  }

  Future<void> setHideCompleted(bool value) async {
    _hideCompleted = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideCompletedKey, value);

    notifyListeners();
  }

  AppUser _mapSupabaseUser(User user) {
    final metadata = user.userMetadata;

    return AppUser(
      id: user.id,
      name:
          metadata?['name'] as String? ??
          user.email?.split('@').first ??
          'کاربر',
      email: user.email ?? '',
    );
  }

  AppUser? _mapNullableSupabaseUser(User? user) {
    return user == null ? null : _mapSupabaseUser(user);
  }

  void _setCurrentUser(User? user, {AppUser? fallback}) {
    final nextUser = user == null ? fallback : _mapSupabaseUser(user);

    if (_sameUser(_currentUser, nextUser)) return;

    _currentUser = nextUser;
    notifyListeners();
  }

  bool _sameUser(AppUser? current, AppUser? next) {
    return current?.id == next?.id &&
        current?.name == next?.name &&
        current?.email == next?.email;
  }

  String _authErrorMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('invalid login credentials')) {
      return 'ایمیل یا رمز عبور با حساب تیکو هم‌خوانی ندارد';
    }

    if (lower.contains('already registered') ||
        lower.contains('user already registered')) {
      return 'با این ایمیل قبلاً حساب تیکو ساخته شده است';
    }

    if (lower.contains('email not confirmed')) {
      return 'برای فعال شدن حساب تیکو، ایمیل‌تان را تأیید کنید';
    }

    return ApiErrorMessages.userMessage(AuthException(message));
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
