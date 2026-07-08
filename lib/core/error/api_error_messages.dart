import 'failure.dart';

class ApiErrorMessages {
  ApiErrorMessages._();

  static String userMessage(Object error) {
    final message = error is Failure ? error.message : error.toString();
    final normalized = message.toLowerCase();

    if (_containsAny(normalized, [
      'signed-in user',
      'signed in user',
      'not authenticated',
      'unauthenticated',
      'jwt',
      'session',
      'token has expired',
      'invalid token',
      '401',
    ])) {
      return 'برای ادامه، دوباره وارد حساب تیکو شوید.';
    }

    if (_containsAny(normalized, [
      'invalid login credentials',
      'invalid credentials',
    ])) {
      return 'ایمیل یا رمز عبور با حساب تیکو هم‌خوانی ندارد.';
    }

    if (_containsAny(normalized, [
      'invalid email',
      'email address is invalid',
      'unable to validate email address',
      'invalid format',
    ])) {
      return 'ایمیل را با قالب درست وارد کنید.';
    }

    if (_containsAny(normalized, [
      'password should be',
      'password must be',
      'valid password',
      'weak password',
    ])) {
      return 'رمز عبور باید حداقل ۶ کاراکتر و مطمئن‌تر باشد.';
    }

    if (_containsAny(normalized, [
      'email not confirmed',
      'confirm your email',
    ])) {
      return 'برای فعال شدن حساب تیکو، ایمیل‌تان را تأیید کنید.';
    }

    if (_containsAny(normalized, [
      'security purposes',
      'only request this',
      'rate limit',
      'too many requests',
      '429',
    ])) {
      final seconds = RegExp(
        r'after\s+(\d+)\s+seconds?',
      ).firstMatch(normalized)?.group(1);

      if (seconds != null) {
        return 'برای امنیت حساب، ${_toPersianDigits(seconds)} ثانیه دیگر دوباره تلاش کنید.';
      }

      return 'چند بار پشت سر هم تلاش کردید. کمی صبر کنید و دوباره امتحان کنید.';
    }

    if (_containsAny(normalized, [
      'already registered',
      'user already registered',
      'already exists',
      'duplicate',
    ])) {
      return 'این مورد قبلاً در تیکو ثبت شده است.';
    }

    if (_containsAny(normalized, [
      'permission denied',
      'row-level security',
      'violates row-level security',
      'rls',
      '403',
    ])) {
      return 'به این اطلاعات دسترسی ندارید. یک‌بار دوباره وارد حساب تیکو شوید.';
    }

    if (_containsAny(normalized, [
      'duplicate key',
      'unique constraint',
      '23505',
    ])) {
      return 'این مورد قبلاً در تیکو ثبت شده است.';
    }

    if (_containsAny(normalized, [
      'null value',
      'not-null constraint',
      '23502',
    ])) {
      return 'چند بخش ضروری کامل نشده است.';
    }

    if (_containsAny(normalized, [
      'foreign key',
      'violates foreign key',
      '23503',
    ])) {
      return 'اطلاعات مرتبط با این مورد پیدا نشد.';
    }

    if (_containsAny(normalized, [
      'invalid input syntax',
      'invalid uuid',
      '22p02',
    ])) {
      return 'اطلاعات ارسال‌شده قابل پردازش نیست.';
    }

    if (_containsAny(normalized, [
      'relation',
      'does not exist',
      'schema cache',
      'column',
      'table',
    ])) {
      return 'جدول‌های تیکو در Supabase کامل آماده نشده‌اند.';
    }

    if (_containsAny(normalized, [
      'database error',
      'internal server error',
      '500',
      '502',
      '503',
      '504',
    ])) {
      return 'سرور تیکو فعلاً پاسخ نمی‌دهد. کمی بعد دوباره تلاش کنید.';
    }

    if (_containsAny(normalized, [
      'network',
      'socket',
      'connection',
      'timeout',
      'failed host lookup',
      'connection refused',
      'connection closed',
    ])) {
      return 'ارتباط تیکو با اینترنت برقرار نشد. اتصال را بررسی کنید.';
    }

    if (_containsAny(normalized, ['not found', '404'])) {
      return 'این مورد دیگر پیدا نشد.';
    }

    if (_containsAny(normalized, ['cannot update a todo without an id'])) {
      return 'این کار هنوز آماده ویرایش نیست.';
    }

    if (_isPersian(message) && !_hasLatinLetters(message)) {
      return _withTrailingPeriod(message.trim());
    }

    return 'مشکلی پیش آمد. لطفاً دوباره تلاش کنید.';
  }

  static bool _containsAny(String value, List<String> patterns) {
    return patterns.any(value.contains);
  }

  static bool _isPersian(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }

  static bool _hasLatinLetters(String value) {
    return RegExp(r'[A-Za-z]').hasMatch(value);
  }

  static String _toPersianDigits(String value) {
    const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return value.replaceAllMapped(
      RegExp(r'\d'),
      (match) => persianDigits[int.parse(match.group(0)!)],
    );
  }

  static String _withTrailingPeriod(String value) {
    if (value.endsWith('.') || value.endsWith('!') || value.endsWith('؟')) {
      return value;
    }

    return '$value.';
  }
}
