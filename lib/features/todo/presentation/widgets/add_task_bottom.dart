import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/jalali_date.dart';
import '../../../../core/widgets/jalali_date_picker.dart';
import '../../../../core/widgets/reminder_time_picker.dart';
import '../../domain/entities/todo.dart';

Future<void> showAddTaskBottomSheet({
  required BuildContext context,
  required TextEditingController controller,
  required Future<void> Function(
    String title,
    TodoStatus status,
    TodoPriority priority,
    DateTime? reminderAt,
    DateTime? dueAt,
    String category,
    List<TodoSubtask> subtasks,
  )
  onAdd,
}) {
  TodoStatus selectedStatus = TodoStatus.pending;
  TodoPriority selectedPriority = TodoPriority.normal;
  DateTime? selectedReminderAt;
  DateTime? selectedDueAt;
  String selectedCategory = 'شخصی';

  final subtaskController = TextEditingController();
  final categories = ['شخصی', 'کاری', 'خرید', 'دانشگاه', 'فوری'];

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final mediaQuery = MediaQuery.of(context);

          Future<void> pickReminderAt() async {
            final dueAt = selectedDueAt;
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
            final initialDate = selectedReminderAt ?? dueAt;

            final pickedTime = await showReminderTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(initialDate),
            );

            if (pickedTime == null || !context.mounted) return;

            final picked = DateTime(
              dueAt.year,
              dueAt.month,
              dueAt.day,
              pickedTime.hour,
              pickedTime.minute,
            );

            if (picked.isBefore(now)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('زمان یادآوری باید در آینده باشد'),
                ),
              );
              return;
            }

            setState(() => selectedReminderAt = picked);
          }

          return SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 560,
                  maxHeight: mediaQuery.size.height * 0.92,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    right: 20,
                    left: 20,
                    top: 24,
                    bottom: mediaQuery.viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'ایجاد کار جدید',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: controller,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'عنوان کار را وارد کنید',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'دسته‌بندی',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() => selectedCategory = val);
                        },
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'اولویت',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<TodoPriority>(
                        initialValue: selectedPriority,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: TodoPriority.low,
                            child: Text('کم'),
                          ),
                          DropdownMenuItem(
                            value: TodoPriority.normal,
                            child: Text('معمولی'),
                          ),
                          DropdownMenuItem(
                            value: TodoPriority.high,
                            child: Text('زیاد'),
                          ),
                          DropdownMenuItem(
                            value: TodoPriority.urgent,
                            child: Text('فوری 🔴'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() => selectedPriority = val);
                        },
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'وضعیت',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<TodoStatus>(
                        initialValue: selectedStatus,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: TodoStatus.pending,
                            child: Text('در انتظار'),
                          ),
                          DropdownMenuItem(
                            value: TodoStatus.inProgress,
                            child: Text('در حال انجام'),
                          ),
                          DropdownMenuItem(
                            value: TodoStatus.completed,
                            child: Text('انجام شده'),
                          ),
                          DropdownMenuItem(
                            value: TodoStatus.cancelled,
                            child: Text('لغو شده'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() => selectedStatus = val);
                        },
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'تاریخ سررسید',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final now = DateTime.now();
                                final picked = await showJalaliDatePicker(
                                  context: context,
                                  initialDate: selectedDueAt ?? now,
                                  firstDate: now.subtract(
                                    const Duration(days: 365),
                                  ),
                                  lastDate: now.add(const Duration(days: 3650)),
                                  title: 'انتخاب تاریخ سررسید',
                                );

                                if (picked != null) {
                                  setState(() {
                                    selectedDueAt = picked;
                                    if (selectedReminderAt != null) {
                                      final oldReminder = selectedReminderAt!;
                                      final updatedReminder = DateTime(
                                        picked.year,
                                        picked.month,
                                        picked.day,
                                        oldReminder.hour,
                                        oldReminder.minute,
                                      );
                                      selectedReminderAt =
                                          updatedReminder.isAfter(now)
                                          ? updatedReminder
                                          : null;
                                    }
                                  });
                                }
                              },
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedCalendar03,
                                size: 24,
                                strokeWidth: 2.35,
                              ),
                              label: Text(
                                selectedDueAt == null
                                    ? 'بدون تاریخ سررسید'
                                    : 'سررسید: ${formatJalaliDate(selectedDueAt!)}',
                              ),
                            ),
                          ),
                          if (selectedDueAt != null)
                            IconButton(
                              tooltip: 'حذف سررسید',
                              onPressed: () => setState(() {
                                selectedDueAt = null;
                                selectedReminderAt = null;
                              }),
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedMultiplicationSign,
                                size: 24,
                                strokeWidth: 2.35,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'زیرکارها',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: subtaskController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'هر زیرکار را در یک خط بنویس',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'یادآوری',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: pickReminderAt,
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedClock01,
                                size: 24,
                                strokeWidth: 2.35,
                              ),
                              label: Text(
                                selectedReminderAt == null
                                    ? 'انتخاب زمان یادآوری'
                                    : 'یادآوری: ${formatJalaliDate(selectedReminderAt!)} - ${_formatTime(selectedReminderAt!)}',
                              ),
                            ),
                          ),
                          if (selectedReminderAt != null)
                            IconButton(
                              tooltip: 'حذف یادآوری',
                              onPressed: () =>
                                  setState(() => selectedReminderAt = null),
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedMultiplicationSign,
                                size: 24,
                                strokeWidth: 2.35,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            final title = controller.text.trim();
                            if (title.isEmpty) return;

                            final status = selectedStatus;
                            final priority = selectedPriority;
                            final reminderAt = selectedReminderAt;
                            final dueAt = selectedDueAt;
                            final category = selectedCategory;
                            final subtasks = _parseSubtasks(
                              subtaskController.text,
                            );

                            Navigator.of(sheetContext).pop();

                            if (reminderAt != null) {
                              await NotificationService.scheduleNotificationAt(
                                id:
                                    DateTime.now().millisecondsSinceEpoch ~/
                                    1000,
                                title: title,
                                scheduledAt: reminderAt,
                              );
                            }

                            await onAdd(
                              title,
                              status,
                              priority,
                              reminderAt,
                              dueAt,
                              category,
                              subtasks,
                            );
                          },
                          child: const Text(
                            'افزودن کار',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  ).whenComplete(subtaskController.dispose);
}

List<TodoSubtask> _parseSubtasks(String value) {
  return value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map((line) => TodoSubtask(title: line))
      .toList();
}

String _formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
