import 'package:flutter/material.dart';

import '../utils/jalali_date.dart';

Future<DateTime?> showJalaliDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String title = 'انتخاب تاریخ',
}) {
  final first = _dateOnly(firstDate);
  final last = _dateOnly(lastDate);
  final initial = _dateOnly(initialDate).isBefore(first)
      ? first
      : _dateOnly(initialDate).isAfter(last)
      ? last
      : _dateOnly(initialDate);

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return _JalaliDatePickerDialog(
        title: title,
        initialDate: initial,
        firstDate: first,
        lastDate: last,
      );
    },
  );
}

class _JalaliDatePickerDialog extends StatefulWidget {
  final String title;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _JalaliDatePickerDialog({
    required this.title,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_JalaliDatePickerDialog> createState() =>
      _JalaliDatePickerDialogState();
}

class _JalaliDatePickerDialogState extends State<_JalaliDatePickerDialog> {
  late JalaliDate _selected;
  late JalaliDate _visibleMonth;

  @override
  void initState() {
    super.initState();
    _selected = JalaliDate.fromGregorian(widget.initialDate);
    _visibleMonth = _selected.copyWith(day: 1);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final selectedGregorian = _selected.toGregorian();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '${_weekdayName(selectedGregorian)}، ${toPersianDigits(_selected.day)} ${_selected.monthName} ${toPersianDigits(_selected.year)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'ماه قبل',
                      onPressed: () {
                        setState(
                          () => _visibleMonth = _visibleMonth.addMonths(-1),
                        );
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      tooltip: 'ماه بعد',
                      onPressed: () {
                        setState(
                          () => _visibleMonth = _visibleMonth.addMonths(1),
                        );
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                    const Spacer(),
                    Text(
                      '${_visibleMonth.monthName} ${toPersianDigits(_visibleMonth.year)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: JalaliDate.shortWeekdayNames
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                _MonthGrid(
                  visibleMonth: _visibleMonth,
                  selected: _selected,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  primary: primary,
                  onSelected: (date) => setState(() => _selected = date),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('لغو'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_selected.toGregorian()),
                      child: const Text('تأیید'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        final today = _dateOnly(DateTime.now());
                        if (today.isBefore(widget.firstDate) ||
                            today.isAfter(widget.lastDate)) {
                          return;
                        }
                        setState(() {
                          _selected = JalaliDate.fromGregorian(today);
                          _visibleMonth = _selected.copyWith(day: 1);
                        });
                      },
                      child: const Text('امروز'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final JalaliDate visibleMonth;
  final JalaliDate selected;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color primary;
  final ValueChanged<JalaliDate> onSelected;

  const _MonthGrid({
    required this.visibleMonth,
    required this.selected,
    required this.firstDate,
    required this.lastDate,
    required this.primary,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final monthStart = visibleMonth.toGregorian();
    final offset = _daysFromSaturday(monthStart.weekday);
    final daysInMonth = JalaliDate.daysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );
    final today = _dateOnly(DateTime.now());

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final day = index - offset + 1;
        if (day < 1 || day > daysInMonth) {
          return const SizedBox.shrink();
        }

        final jalali = visibleMonth.copyWith(day: day);
        final gregorian = jalali.toGregorian();
        final enabled =
            !gregorian.isBefore(firstDate) && !gregorian.isAfter(lastDate);
        final isSelected =
            jalali.year == selected.year &&
            jalali.month == selected.month &&
            jalali.day == selected.day;
        final isToday = gregorian == today;

        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: enabled ? () => onSelected(jalali) : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected ? primary : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: primary.withValues(alpha: 0.55))
                  : null,
            ),
            child: Center(
              child: Text(
                toPersianDigits(day),
                style: TextStyle(
                  color: !enabled
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.34)
                      : isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

int _daysFromSaturday(int weekday) {
  return switch (weekday) {
    DateTime.saturday => 0,
    DateTime.sunday => 1,
    DateTime.monday => 2,
    DateTime.tuesday => 3,
    DateTime.wednesday => 4,
    DateTime.thursday => 5,
    DateTime.friday => 6,
    _ => 0,
  };
}

String _weekdayName(DateTime date) {
  return switch (date.weekday) {
    DateTime.saturday => 'شنبه',
    DateTime.sunday => 'یکشنبه',
    DateTime.monday => 'دوشنبه',
    DateTime.tuesday => 'سه‌شنبه',
    DateTime.wednesday => 'چهارشنبه',
    DateTime.thursday => 'پنجشنبه',
    DateTime.friday => 'جمعه',
    _ => '',
  };
}
