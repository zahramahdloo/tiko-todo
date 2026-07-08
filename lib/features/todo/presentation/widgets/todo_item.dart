import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/jalali_date.dart';
import '../../domain/entities/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;
  final ValueChanged<int> onToggleSubtask;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
    required this.onToggleSubtask,
  });

  static Color _statusColor(TodoStatus status) {
    return switch (status) {
      TodoStatus.pending => AppColors.statusPending,
      TodoStatus.inProgress => AppColors.statusInProgress,
      TodoStatus.completed => AppColors.statusCompleted,
      TodoStatus.cancelled => AppColors.statusCancelled,
    };
  }

  static String _statusLabel(TodoStatus status) {
    return switch (status) {
      TodoStatus.pending => 'در انتظار',
      TodoStatus.inProgress => 'در حال انجام',
      TodoStatus.completed => 'انجام شده',
      TodoStatus.cancelled => 'لغو شده',
    };
  }

  static Color _priorityColor(TodoPriority priority) {
    return switch (priority) {
      TodoPriority.low => AppColors.priorityLow,
      TodoPriority.normal => AppColors.priorityNormal,
      TodoPriority.high => AppColors.priorityHigh,
      TodoPriority.urgent => AppColors.priorityUrgent,
    };
  }

  static String _priorityLabel(TodoPriority priority) {
    return switch (priority) {
      TodoPriority.low => 'کم',
      TodoPriority.normal => 'معمولی',
      TodoPriority.high => 'زیاد',
      TodoPriority.urgent => 'فوری',
    };
  }

  @override
  Widget build(BuildContext context) {
    final completed = todo.status == TodoStatus.completed;
    final colorScheme = Theme.of(context).colorScheme;
    final completedSubtasks = todo.subtasks
        .where((subtask) => subtask.isCompleted)
        .length;
    final visibleSubtasks = todo.subtasks.take(3).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: completed
            ? AppColors.statusCompleted.withValues(alpha: 0.08)
            : colorScheme.surface,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? AppColors.statusCompleted : Colors.transparent,
              border: Border.all(
                color: completed
                    ? AppColors.statusCompleted
                    : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: completed
                ? const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedTick02,
                      size: 24,
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : null,
          ),
        ),
        title: Text(
          todo.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            decoration: completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: completed
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    label: todo.category,
                    textColor: colorScheme.onSurfaceVariant,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  _InfoChip(
                    label: _statusLabel(todo.status),
                    textColor: _statusColor(todo.status),
                    backgroundColor: _statusColor(
                      todo.status,
                    ).withValues(alpha: 0.12),
                  ),
                  _InfoChip(
                    label: _priorityLabel(todo.priority),
                    textColor: Colors.white,
                    backgroundColor: _priorityColor(todo.priority),
                  ),
                  if (todo.dueAt != null)
                    _InfoChip(
                      label: _dueLabel(todo.dueAt!, completed),
                      textColor: _isOverdue(todo.dueAt!, completed)
                          ? AppColors.priorityUrgent
                          : AppColors.primary,
                      backgroundColor: _isOverdue(todo.dueAt!, completed)
                          ? AppColors.priorityUrgent.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.10),
                    ),
                ],
              ),
              if (todo.subtasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completedSubtasks از ${todo.subtasks.length} زیرکار انجام شده',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ).copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      ...List.generate(visibleSubtasks.length, (index) {
                        final subtask = visibleSubtasks[index];

                        return InkWell(
                          onTap: () => onToggleSubtask(index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: subtask.isCompleted
                                      ? HugeIcons.strokeRoundedCheckmarkCircle02
                                      : HugeIcons.strokeRoundedCircle,
                                  size: 20,
                                  color: subtask.isCompleted
                                      ? AppColors.statusCompleted
                                      : colorScheme.onSurfaceVariant,
                                  strokeWidth: 2.2,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    subtask.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                      decoration: subtask.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              if (todo.reminderAt != null &&
                  todo.reminderAt!.isAfter(DateTime.now()))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _ReminderCountdown(reminderAt: todo.reminderAt!),
                ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'گزینه‌ها',
          onSelected: (value) {
            switch (value) {
              case 'toggle':
                onToggle();
                break;
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
              case 'archive':
                onArchive();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  HugeIcon(
                    icon: completed
                        ? HugeIcons.strokeRoundedRotateLeft01
                        : HugeIcons.strokeRoundedCheckmarkCircle02,
                    size: 24,
                    strokeWidth: 2.2,
                  ),
                  const SizedBox(width: 8),
                  Text(completed ? 'بازگردانی' : 'انجام شد'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit02,
                    size: 24,
                    strokeWidth: 2.2,
                  ),
                  SizedBox(width: 8),
                  Text('ویرایش'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedArchive,
                    size: 24,
                    strokeWidth: 2.2,
                  ),
                  const SizedBox(width: 8),
                  Text(todo.isArchived ? 'خروج از آرشیو' : 'آرشیو'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    size: 24,
                    color: Colors.red,
                    strokeWidth: 2.2,
                  ),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isOverdue(DateTime dueAt, bool completed) {
    if (completed) return false;

    final now = DateTime.now();
    final dueDate = DateTime(dueAt.year, dueAt.month, dueAt.day);
    final currentDate = DateTime(now.year, now.month, now.day);

    return dueDate.isBefore(currentDate);
  }

  static String _dueLabel(DateTime dueAt, bool completed) {
    if (_isOverdue(dueAt, completed)) {
      return 'عقب‌افتاده';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(dueAt.year, dueAt.month, dueAt.day);
    final difference = dueDate.difference(today).inDays;

    if (difference == 0) return 'امروز';
    if (difference == 1) return 'فردا';

    return _formatDate(dueAt);
  }

  static String _formatDate(DateTime date) {
    return formatJalaliDate(date);
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;

  const _InfoChip({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReminderCountdown extends StatefulWidget {
  final DateTime reminderAt;

  const _ReminderCountdown({required this.reminderAt});

  @override
  State<_ReminderCountdown> createState() => _ReminderCountdownState();
}

class _ReminderCountdownState extends State<_ReminderCountdown> {
  late final Stream<Duration> _stream;

  @override
  void initState() {
    super.initState();

    _stream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => widget.reminderAt.difference(DateTime.now()),
    );
  }

  String _format(Duration d) {
    if (d.isNegative) return '';

    if (d.inHours > 0) {
      return '${d.inHours} ساعت و ${d.inMinutes.remainder(60)} دقیقه';
    }

    if (d.inMinutes > 0) {
      return '${d.inMinutes} دقیقه و ${d.inSeconds.remainder(60)} ثانیه';
    }

    return '${d.inSeconds} ثانیه';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: _stream,
      builder: (context, snapshot) {
        final d = snapshot.data ?? Duration.zero;

        if (d.isNegative) return const SizedBox.shrink();

        return Row(
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedBellDot,
              size: 18,
              color: AppColors.primary,
              strokeWidth: 2.2,
            ),
            const SizedBox(width: 4),
            Text(_format(d), style: const TextStyle(fontSize: 11)),
          ],
        );
      },
    );
  }
}
