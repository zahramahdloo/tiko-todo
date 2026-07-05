import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() => _dueAt = picked);
    }
  }

  Future<void> _pickReminderAt() async {
    final now = DateTime.now();
    final initialDate = _reminderAt ?? now.add(const Duration(hours: 1));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      initialEntryMode: TimePickerEntryMode.input,
      helpText: 'زمان یادآوری را وارد کن',
      cancelText: 'انصراف',
      confirmText: 'تأیید',
      hourLabelText: 'ساعت',
      minuteLabelText: 'دقیقه',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    final picked = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
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
    final width = MediaQuery.sizeOf(context).width;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final horizontalPadding = width >= 720 ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('افزودن کار'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                viewInsets.bottom + 24,
              ),
              children: [
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'عنوان کار',
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
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'دسته‌بندی',
                        ),
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _category = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<TodoPriority>(
                              initialValue: _priority,
                              decoration: const InputDecoration(
                                labelText: 'اولویت',
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
                                  child: Text('فوری'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _priority = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<TodoStatus>(
                              initialValue: _status,
                              decoration: const InputDecoration(
                                labelText: 'وضعیت',
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
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _status = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: _pickDueDate,
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCalendar03,
                          size: 24,
                          strokeWidth: 2.35,
                        ),
                        label: Text(
                          _dueAt == null
                              ? 'انتخاب تاریخ سررسید'
                              : _formatGregorian(_dueAt!),
                        ),
                      ),
                      if (_dueAt != null)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                            onPressed: () => setState(() => _dueAt = null),
                            child: const Text('حذف تاریخ سررسید'),
                          ),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickReminderAt,
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedClock01,
                          size: 24,
                          strokeWidth: 2.35,
                        ),
                        label: Text(
                          _reminderAt == null
                              ? 'انتخاب زمان یادآوری'
                              : 'یادآوری: ${_formatGregorian(_reminderAt!)} - ${_formatTime(_reminderAt!)}',
                        ),
                      ),
                      if (_reminderAt != null)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                            onPressed: () => setState(() => _reminderAt = null),
                            child: const Text('حذف یادآوری'),
                          ),
                        ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _subtaskController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'زیرکارها',
                          hintText: 'هر زیرکار را در یک خط بنویس',
                        ),
                      ),
                      const SizedBox(height: 20),
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

String _formatGregorian(DateTime date) {
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}

String _formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
