import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_state.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 720 ? 24.0 : 16.0;
    final maxWidth = width >= 840 ? 760.0 : 720.0;
    final weekDays = _visibleWeek(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F4),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                _TimetableHeader(
                  selectedDate: _selectedDate,
                  weekDays: weekDays,
                  onDateSelected: (date) {
                    setState(() => _selectedDate = _dateOnly(date));
                  },
                ),
                Expanded(
                  child: BlocBuilder<TodoBloc, TodoState>(
                    builder: (context, state) {
                      if (state is TodoLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is TodoError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      }

                      if (state is TodoLoaded) {
                        final todos = _todosForDate(state.todos, _selectedDate);

                        if (todos.isEmpty) {
                          return const _EmptyTimetable();
                        }

                        return ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            16,
                            horizontalPadding,
                            24,
                          ),
                          itemCount: todos.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _TimelineTaskCard(todo: todos[index]);
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimetableHeader extends StatelessWidget {
  final DateTime selectedDate;
  final List<DateTime> weekDays;
  final ValueChanged<DateTime> onDateSelected;

  const _TimetableHeader({
    required this.selectedDate,
    required this.weekDays,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final jalali = _JalaliDate.fromGregorian(selectedDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedCalendar03,
                size: 28,
                color: Colors.white,
                strokeWidth: 2.35,
              ),
              const Spacer(),
              Column(
                children: [
                  const Text(
                    'جدول زمانی',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${jalali.day} ${jalali.monthName} ${jalali.year}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => onDateSelected(DateTime.now()),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedRefresh,
                  size: 24,
                  color: Colors.white,
                  strokeWidth: 2.35,
                ),
                tooltip: 'امروز',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: weekDays.map((date) {
              final selected = _isSameDay(date, selectedDate);
              final day = _JalaliDate.fromGregorian(date);

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onDateSelected(date),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        Text(
                          _shortWeekday(date),
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: selected ? 1 : 0.58,
                            ),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TimelineTaskCard extends StatelessWidget {
  final Todo todo;

  const _TimelineTaskCard({required this.todo});

  @override
  Widget build(BuildContext context) {
    final accent = _priorityColor(todo.priority);
    final time = _taskDate(todo);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(time),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time == null ? 'بدون ساعت' : 'یادآوری',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 3, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            todo.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (todo.priority == TodoPriority.urgent)
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedBookmark02,
                            size: 24,
                            color: accent,
                            strokeWidth: 2.35,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${todo.category} • ${_statusLabel(todo.status)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      children: [
                        _Detail(
                          icon: HugeIcons.strokeRoundedFlag01,
                          label: _priorityLabel(todo.priority),
                        ),
                        _Detail(
                          icon: HugeIcons.strokeRoundedTask01,
                          label: '${todo.subtasks.length} زیرکار',
                        ),
                        if (todo.dueAt != null)
                          _Detail(
                            icon: HugeIcons.strokeRoundedCalendar03,
                            label: _formatJalali(todo.dueAt!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;

  const _Detail({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(
          icon: icon,
          size: 18,
          color: AppColors.textSecondary,
          strokeWidth: 2.35,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyTimetable extends StatelessWidget {
  const _EmptyTimetable();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCalendar03,
              size: 80,
              color: Colors.grey,
              strokeWidth: 2.35,
            ),
            SizedBox(height: 12),
            Text(
              'برای این روز کاری زمان‌بندی نشده',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

List<DateTime> _visibleWeek(DateTime selectedDate) {
  final daysFromSaturday = switch (selectedDate.weekday) {
    DateTime.saturday => 0,
    DateTime.sunday => 1,
    DateTime.monday => 2,
    DateTime.tuesday => 3,
    DateTime.wednesday => 4,
    DateTime.thursday => 5,
    DateTime.friday => 6,
    _ => 0,
  };
  final start = _dateOnly(
    selectedDate,
  ).subtract(Duration(days: daysFromSaturday));
  return List.generate(7, (index) => start.add(Duration(days: index)));
}

List<Todo> _todosForDate(List<Todo> todos, DateTime date) {
  final visible = todos.where((todo) {
    if (todo.isArchived) return false;
    final taskDate = todo.dueAt ?? todo.reminderAt;
    return taskDate != null && _isSameDay(taskDate, date);
  }).toList();

  visible.sort((a, b) {
    final aTime = _taskDate(a)?.millisecondsSinceEpoch ?? 0;
    final bTime = _taskDate(b)?.millisecondsSinceEpoch ?? 0;
    return aTime.compareTo(bTime);
  });

  return visible;
}

DateTime? _taskDate(Todo todo) => todo.reminderAt ?? todo.dueAt;

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _shortWeekday(DateTime date) {
  return switch (date.weekday) {
    DateTime.saturday => 'ش',
    DateTime.sunday => 'ی',
    DateTime.monday => 'د',
    DateTime.tuesday => 'س',
    DateTime.wednesday => 'چ',
    DateTime.thursday => 'پ',
    DateTime.friday => 'ج',
    _ => '',
  };
}

String _formatTime(DateTime? date) {
  if (date == null) return 'تمام روز';
  if (date.hour == 0 && date.minute == 0) return 'تمام روز';
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String _formatJalali(DateTime date) {
  final jalali = _JalaliDate.fromGregorian(date);
  return '${jalali.day} ${jalali.monthName}';
}

String _statusLabel(TodoStatus status) {
  return switch (status) {
    TodoStatus.pending => 'در انتظار',
    TodoStatus.inProgress => 'در حال انجام',
    TodoStatus.completed => 'انجام شده',
    TodoStatus.cancelled => 'لغو شده',
  };
}

String _priorityLabel(TodoPriority priority) {
  return switch (priority) {
    TodoPriority.low => 'اولویت کم',
    TodoPriority.normal => 'اولویت معمولی',
    TodoPriority.high => 'اولویت زیاد',
    TodoPriority.urgent => 'اولویت فوری',
  };
}

Color _priorityColor(TodoPriority priority) {
  return switch (priority) {
    TodoPriority.low => AppColors.priorityLow,
    TodoPriority.normal => AppColors.priorityNormal,
    TodoPriority.high => AppColors.priorityHigh,
    TodoPriority.urgent => AppColors.priorityUrgent,
  };
}

class _JalaliDate {
  final int year;
  final int month;
  final int day;

  const _JalaliDate({
    required this.year,
    required this.month,
    required this.day,
  });

  String get monthName {
    return const [
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
    ][month - 1];
  }

  static _JalaliDate fromGregorian(DateTime date) {
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

    return _JalaliDate(year: jy, month: jm + 1, day: jDayNo + 1);
  }
}
