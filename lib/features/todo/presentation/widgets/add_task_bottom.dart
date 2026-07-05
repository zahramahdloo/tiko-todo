import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';
import '../../../../core/notifications/notification_service.dart';
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
  int? selectedReminder;
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
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDueAt ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 365),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 3650),
                                  ),
                                );

                                if (picked != null) {
                                  setState(() => selectedDueAt = picked);
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
                                    : 'سررسید: ${_formatDate(selectedDueAt!)}',
                              ),
                            ),
                          ),
                          if (selectedDueAt != null)
                            IconButton(
                              tooltip: 'حذف سررسید',
                              onPressed: () =>
                                  setState(() => selectedDueAt = null),
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
                      DropdownButtonFormField<int?>(
                        initialValue: selectedReminder,
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
                            value: null,
                            child: Text('بدون یادآوری'),
                          ),
                          DropdownMenuItem(
                            value: 10,
                            child: Text('۱۰ دقیقه دیگر'),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text('۳۰ دقیقه دیگر'),
                          ),
                          DropdownMenuItem(
                            value: 60,
                            child: Text('۱ ساعت دیگر'),
                          ),
                          DropdownMenuItem(value: 1440, child: Text('فردا')),
                        ],
                        onChanged: (val) =>
                            setState(() => selectedReminder = val),
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
                            final reminderMinutes = selectedReminder;
                            final dueAt = selectedDueAt;
                            final category = selectedCategory;
                            final subtasks = _parseSubtasks(
                              subtaskController.text,
                            );

                            DateTime? reminderAt;
                            if (reminderMinutes != null) {
                              reminderAt = DateTime.now().add(
                                Duration(minutes: reminderMinutes),
                              );
                            }

                            Navigator.of(sheetContext).pop();

                            if (reminderMinutes != null) {
                              await NotificationService.scheduleNotification(
                                id:
                                    DateTime.now().millisecondsSinceEpoch ~/
                                    1000,
                                title: title,
                                minutes: reminderMinutes,
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

String _formatDate(DateTime date) {
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}
