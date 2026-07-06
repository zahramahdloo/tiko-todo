class JalaliDate {
  final int year;
  final int month;
  final int day;

  const JalaliDate({
    required this.year,
    required this.month,
    required this.day,
  });

  static const monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static const weekdayNames = [
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
    'شنبه',
    'یکشنبه',
  ];

  static const shortWeekdayNames = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  String get monthName => monthNames[month - 1];

  JalaliDate copyWith({int? year, int? month, int? day}) {
    return JalaliDate(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
    );
  }

  JalaliDate addMonths(int value) {
    final monthIndex = (year * 12 + month - 1) + value;
    final newYear = monthIndex ~/ 12;
    final newMonth = monthIndex % 12 + 1;
    final newDay = day.clamp(1, daysInMonth(newYear, newMonth));
    return JalaliDate(year: newYear, month: newMonth, day: newDay);
  }

  DateTime toGregorian() {
    var jy = year - 979;
    final jm = month - 1;
    final jd = day - 1;
    const jDaysInMonth = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];
    const gDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    var jDayNo = 365 * jy + (jy ~/ 33) * 8 + ((jy % 33) + 3) ~/ 4;
    for (var i = 0; i < jm; i++) {
      jDayNo += jDaysInMonth[i];
    }
    jDayNo += jd;

    var gDayNo = jDayNo + 79;
    var gy = 1600 + 400 * (gDayNo ~/ 146097);
    gDayNo %= 146097;

    var leap = true;
    if (gDayNo >= 36525) {
      gDayNo--;
      gy += 100 * (gDayNo ~/ 36524);
      gDayNo %= 36524;

      if (gDayNo >= 365) {
        gDayNo++;
      } else {
        leap = false;
      }
    }

    gy += 4 * (gDayNo ~/ 1461);
    gDayNo %= 1461;

    if (gDayNo >= 366) {
      leap = false;
      gDayNo--;
      gy += gDayNo ~/ 365;
      gDayNo %= 365;
    }

    var gd = gDayNo + 1;
    var gm = 0;
    while (gm < 12) {
      final days = gm == 1 && leap ? 29 : gDaysInMonth[gm];
      if (gd <= days) break;
      gd -= days;
      gm++;
    }

    return DateTime(gy, gm + 1, gd);
  }

  static JalaliDate fromGregorian(DateTime date) {
    final gy = date.year - 1600;
    final gm = date.month - 1;
    final gd = date.day - 1;
    final gDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    final jDaysInMonth = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];

    var gDayNo =
        365 * gy + (gy + 3) ~/ 4 - (gy + 99) ~/ 100 + (gy + 399) ~/ 400;
    for (var i = 0; i < gm; ++i) {
      gDayNo += gDaysInMonth[i];
    }
    if (gm > 1 &&
        ((gy + 1600) % 4 == 0 && (gy + 1600) % 100 != 0 ||
            (gy + 1600) % 400 == 0)) {
      gDayNo++;
    }
    gDayNo += gd;

    var jDayNo = gDayNo - 79;
    final jNp = jDayNo ~/ 12053;
    jDayNo %= 12053;

    var jy = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);
    jDayNo %= 1461;

    if (jDayNo >= 366) {
      jy += (jDayNo - 1) ~/ 365;
      jDayNo = (jDayNo - 1) % 365;
    }

    var jm = 0;
    while (jm < 11 && jDayNo >= jDaysInMonth[jm]) {
      jDayNo -= jDaysInMonth[jm];
      jm++;
    }

    return JalaliDate(year: jy, month: jm + 1, day: jDayNo + 1);
  }

  static int daysInMonth(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return isLeapYear(year) ? 30 : 29;
  }

  static bool isLeapYear(int year) {
    final mod = year % 33;
    return const [1, 5, 9, 13, 17, 22, 26, 30].contains(mod);
  }
}

String formatJalaliDate(DateTime date) {
  final jalali = JalaliDate.fromGregorian(date);
  return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
}

String toPersianDigits(Object value) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  var text = value.toString();
  for (var i = 0; i < english.length; i++) {
    text = text.replaceAll(english[i], persian[i]);
  }
  return text;
}
