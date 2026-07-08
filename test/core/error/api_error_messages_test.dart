import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/core/error/api_error_messages.dart';
import 'package:todo_app/core/error/failure.dart';

void main() {
  group('ApiErrorMessages', () {
    test('translates missing signed-in user errors', () {
      expect(
        ApiErrorMessages.userMessage(
          const AuthenticationFailure('A signed-in user is required.'),
        ),
        'برای ادامه، دوباره وارد حساب تیکو شوید.',
      );
    });

    test('translates network errors', () {
      expect(
        ApiErrorMessages.userMessage(Exception('SocketException')),
        'ارتباط تیکو با اینترنت برقرار نشد. اتصال را بررسی کنید.',
      );
    });

    test('translates security rate limit errors with wait time', () {
      expect(
        ApiErrorMessages.userMessage(
          Exception(
            'You can only request this for security purposes after 14 seconds.',
          ),
        ),
        'برای امنیت حساب، ۱۴ ثانیه دیگر دوباره تلاش کنید.',
      );
    });

    test('translates common auth api errors', () {
      final cases = {
        'Unable to validate email address: invalid format':
            'ایمیل را با قالب درست وارد کنید.',
        'Password should be at least 6 characters':
            'رمز عبور باید حداقل ۶ کاراکتر و مطمئن‌تر باشد.',
        'Email not confirmed':
            'برای فعال شدن حساب تیکو، ایمیل‌تان را تأیید کنید.',
        'Token has expired or is invalid':
            'برای ادامه، دوباره وارد حساب تیکو شوید.',
      };

      for (final entry in cases.entries) {
        expect(ApiErrorMessages.userMessage(Exception(entry.key)), entry.value);
      }
    });

    test('translates common database api errors', () {
      final cases = {
        'new row violates row-level security policy for table "todos"':
            'به این اطلاعات دسترسی ندارید. یک‌بار دوباره وارد حساب تیکو شوید.',
        'duplicate key value violates unique constraint':
            'این مورد قبلاً در تیکو ثبت شده است.',
        'null value in column "title" violates not-null constraint':
            'چند بخش ضروری کامل نشده است.',
        'invalid input syntax for type uuid':
            'اطلاعات ارسال‌شده قابل پردازش نیست.',
        'relation "public.todos" does not exist':
            'جدول‌های تیکو در Supabase کامل آماده نشده‌اند.',
      };

      for (final entry in cases.entries) {
        expect(ApiErrorMessages.userMessage(Exception(entry.key)), entry.value);
      }
    });

    test('keeps existing Persian messages readable', () {
      expect(
        ApiErrorMessages.userMessage(const ServerFailure('دسترسی مجاز نیست')),
        'دسترسی مجاز نیست.',
      );
    });

    test('hides unknown English api messages', () {
      expect(
        ApiErrorMessages.userMessage(
          const ServerFailure('unexpected api text'),
        ),
        'مشکلی پیش آمد. لطفاً دوباره تلاش کنید.',
      );
    });

    test('hides mixed Persian messages with raw English api details', () {
      expect(
        ApiErrorMessages.userMessage(
          const ServerFailure('خطا در بارگذاری کارها: unexpected api text'),
        ),
        'مشکلی پیش آمد. لطفاً دوباره تلاش کنید.',
      );
    });
  });
}
