import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/jalali_date.dart';
import '../../../../core/widgets/jalali_date_picker.dart';
import '../../../../core/widgets/reminder_time_picker.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';

class AddTaskPage extends StatefulWidget {
  final VoidCallback onTaskAdded;

  const AddTaskPage({super.key, required this.onTaskAdded});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleController = TextEditingController();
  final _subtaskController = TextEditingController();
  TodoStatus _status = TodoStatus.pending;
  TodoPriority _priority = TodoPriority.normal;
  DateTime? _reminderAt;
  DateTime? _dueAt;
  String _category = 'شخصی';

  static const _categories = ['شخصی', 'کاری', 'خرید', 'دانشگاه', 'فوری'];

  @override
  void dispose() {
    _titleController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showJalaliDatePicker(
      context: context,
      initialDate: _dueAt ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
      title: 'انتخاب تاریخ سررسید',
    );

    if (picked != null) {
      setState(() {
        _dueAt = picked;
        if (_reminderAt != null) {
          final oldReminder = _reminderAt!;
          final updatedReminder = DateTime(
            picked.year,
            picked.month,
            picked.day,
            oldReminder.hour,
            oldReminder.minute,
          );
          _reminderAt = updatedReminder.isAfter(now) ? updatedReminder : null;
        }
      });
    }
  }

  Future<void> _pickReminderAt() async {
    final dueAt = _dueAt;
    if (dueAt == null) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('اول تاریخ را انتخاب کن'),
            content: const Text(
              'برای تنظیم یادآوری، ابتدا تاریخ سررسید را انتخاب کن و بعد زمان را وارد کن.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('باشه'),
              ),
            ],
          );
        },
      );
      return;
    }

    final now = DateTime.now();
    final initialDate = _reminderAt ?? dueAt;

    final pickedTime = await showReminderTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    final picked = DateTime(
      dueAt.year,
      dueAt.month,
      dueAt.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (picked.isBefore(now)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('زمان یادآوری باید در آینده باشد')),
      );
      return;
    }

    setState(() => _reminderAt = picked);
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('عنوان کار را وارد کن')));
      return;
    }

    final reminderAt = _reminderAt;
    if (reminderAt != null) {
      await NotificationService.scheduleNotificationAt(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        scheduledAt: reminderAt,
      );
    }

    if (!mounted) return;

    context.read<TodoBloc>().add(
      AddTodo(
        Todo(
          title: title,
          status: _status,
          priority: _priority,
          reminderAt: reminderAt,
          dueAt: _dueAt,
          category: _category,
          subtasks: _parseSubtasks(_subtaskController.text),
        ),
      ),
    );

    _titleController.clear();
    _subtaskController.clear();
    setState(() {
      _status = TodoStatus.pending;
      _priority = TodoPriority.normal;
      _reminderAt = null;
      _dueAt = null;
      _category = 'شخصی';
    });
    widget.onTaskAdded();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    final dueLabel = _dueAt == null ? 'بدون سررسید' : formatJalaliDate(_dueAt!);
    final reminderLabel = _reminderAt == null
        ? 'بدون یادآوری'
        : '${formatJalaliDate(_reminderAt!)}، ${_formatTime(_reminderAt!)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('افزودن کار'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 640,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              ResponsiveLayout.horizontalPadding(context),
              16,
              ResponsiveLayout.horizontalPadding(context),
              viewInsets.bottom + 24,
            ),
            children: [
              _HeaderStrip(primary: primary),
              const SizedBox(height: 14),
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      icon: HugeIcons.strokeRoundedTaskAdd01,
                      title: 'جزئیات اصلی',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.done,
                      minLines: 1,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'مثلا: آماده کردن گزارش هفتگی',
                        prefixIcon: Center(
                          widthFactor: 1,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedTaskAdd01,
                            size: 24,
                            strokeWidth: 2.35,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle(
                      icon: HugeIcons.strokeRoundedFolder01,
                      title: 'دسته‌بندی',
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories
                          .map(
                            (category) => _OptionChip(
                              label: category,
                              selected: _category == category,
                              selectedColor: primary,
                              onSelected: () =>
                                  setState(() => _category = category),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle(
                      icon: HugeIcons.strokeRoundedFlag01,
                      title: 'اولویت و وضعیت',
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _OptionChip(
                          label: 'کم',
                          selected: _priority == TodoPriority.low,
                          selectedColor: AppColors.priorityLow,
                          onSelected: () =>
                              setState(() => _priority = TodoPriority.low),
                        ),
                        _OptionChip(
                          label: 'معمولی',
                          selected: _priority == TodoPriority.normal,
                          selectedColor: AppColors.priorityNormal,
                          onSelected: () =>
                              setState(() => _priority = TodoPriority.normal),
                        ),
                        _OptionChip(
                          label: 'زیاد',
                          selected: _priority == TodoPriority.high,
                          selectedColor: AppColors.priorityHigh,
                          onSelected: () =>
                              setState(() => _priority = TodoPriority.high),
                        ),
                        _OptionChip(
                          label: 'فوری',
                          selected: _priority == TodoPriority.urgent,
                          selectedColor: AppColors.priorityUrgent,
                          onSelected: () =>
                              setState(() => _priority = TodoPriority.urgent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<TodoStatus>(
                        segments: const [
                          ButtonSegment(
                            value: TodoStatus.pending,
                            label: Text('در انتظار'),
                          ),
                          ButtonSegment(
                            value: TodoStatus.inProgress,
                            label: Text('در حال انجام'),
                          ),
                          ButtonSegment(
                            value: TodoStatus.completed,
                            label: Text('انجام شده'),
                          ),
                          ButtonSegment(
                            value: TodoStatus.cancelled,
                            label: Text('لغو شده'),
                          ),
                        ],
                        selected: {_status},
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          side: WidgetStateProperty.resolveWith((states) {
                            final selected = states.contains(
                              WidgetState.selected,
                            );
                            return BorderSide(
                              color: selected
                                  ? primary.withValues(alpha: 0.45)
                                  : Colors.black.withValues(alpha: 0.08),
                            );
                          }),
                        ),
                        onSelectionChanged: (value) =>
                            setState(() => _status = value.first),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle(
                      icon: HugeIcons.strokeRoundedCalendar03,
                      title: 'زمان‌بندی',
                    ),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: HugeIcons.strokeRoundedCalendar03,
                      title: 'تاریخ سررسید',
                      value: dueLabel,
                      active: _dueAt != null,
                      onTap: _pickDueDate,
                      onClear: _dueAt == null
                          ? null
                          : () => setState(() {
                              _dueAt = null;
                              _reminderAt = null;
                            }),
                    ),
                    const SizedBox(height: 8),
                    _ActionTile(
                      icon: HugeIcons.strokeRoundedClock01,
                      title: 'یادآوری',
                      value: reminderLabel,
                      active: _reminderAt != null,
                      onTap: _pickReminderAt,
                      onClear: _reminderAt == null
                          ? null
                          : () => setState(() => _reminderAt = null),
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle(
                      icon: HugeIcons.strokeRoundedTask01,
                      title: 'زیرکارها',
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _subtaskController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'هر زیرکار را در یک خط بنویس',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedPlusSign,
                          size: 24,
                          color: Colors.white,
                          strokeWidth: 2.35,
                        ),
                        label: const Text('ثبت کار'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderStrip extends StatelessWidget {
  final Color primary;

  const _HeaderStrip({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedPlusSign,
                color: Colors.white,
                size: 25,
                strokeWidth: 2.35,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'یک کار تازه بساز',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'عنوان را بنویس، زمان‌بندی کن و با یک لمس ثبتش کن.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        HugeIcon(icon: icon, color: primary, size: 21, strokeWidth: 2.35),
        const SizedBox(width: 7),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onSelected;

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: selectedColor.withValues(alpha: 0.13),
      labelStyle: TextStyle(
        color: selected ? selectedColor : AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(
        color: selected
            ? selectedColor.withValues(alpha: 0.42)
            : Colors.black.withValues(alpha: 0.08),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String value;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.active,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = active ? primary : AppColors.textSecondary;

    return Material(
      color: active
          ? primary.withValues(alpha: 0.08)
          : AppColors.background.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active
                  ? primary.withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              HugeIcon(icon: icon, color: color, size: 23, strokeWidth: 2.35),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active ? AppColors.textPrimary : color,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  tooltip: 'حذف',
                  onPressed: onClear,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedMultiplicationSign,
                    size: 21,
                    strokeWidth: 2.35,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

List<TodoSubtask> _parseSubtasks(String value) {
  return value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map((title) => TodoSubtask(title: title))
      .toList();
}

String _formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
