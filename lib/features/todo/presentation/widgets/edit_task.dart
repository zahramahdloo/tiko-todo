import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';
import '../../../../core/utils/jalali_date.dart';
import '../../../../core/widgets/jalali_date_picker.dart';
import '../../domain/entities/todo.dart';

Future<void> showEditTaskDialog({
  required BuildContext context,
  required TextEditingController controller,
  required Todo todo,
  required Future<void> Function(
    String title,
    TodoStatus status,
    TodoPriority priority,
    DateTime? dueAt,
    String category,
    List<TodoSubtask> subtasks,
  )
  onSave,
}) {
  TodoStatus selectedStatus = todo.status;
  TodoPriority selectedPriority = todo.priority;
  DateTime? selectedDueAt = todo.dueAt;
  String selectedCategory = todo.category;

  final subtaskController = TextEditingController(
    text: todo.subtasks.map((subtask) => subtask.title).join('\n'),
  );

  final categories = ['شخصی', 'کاری', 'خرید', 'دانشگاه', 'فوری'];

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final mediaQuery = MediaQuery.of(context);

          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            title: const Text('ویرایش'),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 420,
                maxHeight: mediaQuery.size.height * 0.68,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'ویرایش عنوان کار',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'دسته‌بندی',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
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
                          vertical: 8,
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
                        fontSize: 13,
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
                          vertical: 8,
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
                        fontSize: 13,
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
                          vertical: 8,
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
                        fontSize: 13,
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
                                lastDate: now.add(
                                  const Duration(days: 3650),
                                ),
                                title: 'انتخاب تاریخ سررسید',
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
                                  ? 'بدون سررسید'
                                  : formatJalaliDate(selectedDueAt!),
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
                        fontSize: 13,
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
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () async {
                  final title = controller.text.trim();
                  if (title.isEmpty) return;

                  final status = selectedStatus;
                  final priority = selectedPriority;
                  final dueAt = selectedDueAt;
                  final category = selectedCategory;
                  final subtasks = _mergeSubtasks(
                    subtaskController.text,
                    todo.subtasks,
                  );

                  Navigator.of(dialogContext).pop();

                  await onSave(
                    title,
                    status,
                    priority,
                    dueAt,
                    category,
                    subtasks,
                  );
                },
                child: const Text(
                  'ذخیره',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  ).whenComplete(subtaskController.dispose);
}

List<TodoSubtask> _mergeSubtasks(String value, List<TodoSubtask> oldSubtasks) {
  return value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map((line) {
        TodoSubtask? old;
        for (final item in oldSubtasks) {
          if (item.title == line) {
            old = item;
            break;
          }
        }

        return TodoSubtask(title: line, isCompleted: old?.isCompleted ?? false);
      })
      .toList();
}
