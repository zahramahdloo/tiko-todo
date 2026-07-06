import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/jalali_date.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_state.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
            children: [
              const _ArchiveHeader(),
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
                      final completedGroups = _groupCompletedTodos(state.todos);

                      if (completedGroups.isEmpty) {
                        return const _EmptyArchive();
                      }

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16,
                          horizontalPadding,
                          24,
                        ),
                        itemCount: completedGroups.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final group = completedGroups[index];
                          return _ArchiveTaskTile(
                            group: group,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    _ArchiveTaskDetailPage(group: group),
                              ),
                            ),
                          );
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
    );
  }
}

class _ArchiveTaskDetailPage extends StatelessWidget {
  final _ArchiveTaskGroup group;

  const _ArchiveTaskDetailPage({required this.group});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('جزئیات آرشیو')),
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 640,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              18,
              horizontalPadding,
              24,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.statusCompleted.withValues(
                              alpha: 0.14,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedTickDouble01,
                              size: 24,
                              color: AppColors.statusCompleted,
                              strokeWidth: 2.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            group.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _DetailRow(
                      icon: HugeIcons.strokeRoundedTaskDone01,
                      label: 'تعداد انجام',
                      value: '${toPersianDigits(group.todos.length)} بار',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: HugeIcons.strokeRoundedCalendarCheckIn01,
                      label: 'آخرین انجام',
                      value: group.latestCompletedAt == null
                          ? 'تاریخ ثبت نشده'
                          : _formatDateTime(group.latestCompletedAt!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'دفعات انجام',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...group.todos.indexed.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ArchiveOccurrenceCard(
                    index: entry.$1 + 1,
                    todo: entry.$2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveHeader extends StatelessWidget {
  const _ArchiveHeader();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: const Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedArchive,
            size: 28,
            color: Colors.white,
            strokeWidth: 2.35,
          ),
          Spacer(),
          Text(
            'آرشیو',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Spacer(),
          SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _ArchiveTaskTile extends StatelessWidget {
  final _ArchiveTaskGroup group;
  final VoidCallback onTap;

  const _ArchiveTaskTile({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final completedAt = group.latestCompletedAt;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.statusCompleted.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedTick02,
                    size: 22,
                    color: AppColors.statusCompleted,
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
                      group.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      group.todos.length == 1
                          ? completedAt == null
                                ? 'تاریخ ثبت نشده'
                                : 'انجام شده در ${_formatDateTime(completedAt)}'
                          : completedAt == null
                          ? 'تاریخ ثبت نشده'
                          : '${toPersianDigits(group.todos.length)} بار انجام شده، آخرین بار ${_formatDateTime(completedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                size: 22,
                color: AppColors.textSecondary,
                strokeWidth: 2.35,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveOccurrenceCard extends StatelessWidget {
  final int index;
  final Todo todo;

  const _ArchiveOccurrenceCard({required this.index, required this.todo});

  @override
  Widget build(BuildContext context) {
    final completedAt = todo.completedAt;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.statusCompleted.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  toPersianDigits(index),
                  style: const TextStyle(
                    color: AppColors.statusCompleted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  completedAt == null
                      ? 'تاریخ ثبت نشده'
                      : _formatDateTime(completedAt),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: HugeIcons.strokeRoundedCalendarCheckIn01,
            label: 'تاریخ',
            value: completedAt == null
                ? 'تاریخ ثبت نشده'
                : _formatExactDate(completedAt),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: HugeIcons.strokeRoundedTime03,
            label: 'ساعت',
            value: completedAt == null
                ? 'تاریخ ثبت نشده'
                : _formatTime(completedAt),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: HugeIcons.strokeRoundedFolder01,
            label: 'دسته‌بندی',
            value: todo.category,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: HugeIcons.strokeRoundedFlag01,
            label: 'اولویت',
            value: _priorityLabel(todo.priority),
          ),
          if (todo.subtasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...todo.subtasks.map(
              (subtask) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SubtaskRow(subtask: subtask),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HugeIcon(
          icon: icon,
          size: 22,
          color: AppColors.textSecondary,
          strokeWidth: 2.35,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  final TodoSubtask subtask;

  const _SubtaskRow({required this.subtask});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: subtask.isCompleted
                ? HugeIcons.strokeRoundedTick02
                : HugeIcons.strokeRoundedCircle,
            size: 20,
            color: subtask.isCompleted
                ? AppColors.statusCompleted
                : AppColors.textSecondary,
            strokeWidth: 2.35,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              subtask.title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedArchive,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 2.35,
            ),
            const SizedBox(height: 12),
            Text(
              'هنوز کاری انجام نشده',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'وقتی کاری را انجام‌شده کنی، عنوانش اینجا می‌آید.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveTaskGroup {
  final String title;
  final List<Todo> todos;

  const _ArchiveTaskGroup({required this.title, required this.todos});

  DateTime? get latestCompletedAt => todos.first.completedAt;
}

List<_ArchiveTaskGroup> _groupCompletedTodos(List<Todo> todos) {
  final groups = <String, List<Todo>>{};
  final titles = <String, String>{};

  for (final todo in todos) {
    if (todo.status != TodoStatus.completed) continue;

    final key = _normalizeTitle(todo.title);
    groups.putIfAbsent(key, () => []).add(todo);
    titles.putIfAbsent(key, () => todo.title.trim());
  }

  final archiveGroups = groups.entries.map((entry) {
    final groupTodos = [...entry.value]..sort(_compareCompletedTodos);
    return _ArchiveTaskGroup(
      title: titles[entry.key] ?? groupTodos.first.title,
      todos: groupTodos,
    );
  }).toList();

  archiveGroups.sort((a, b) {
    final bTime = b.latestCompletedAt?.millisecondsSinceEpoch ?? 0;
    final aTime = a.latestCompletedAt?.millisecondsSinceEpoch ?? 0;
    return bTime.compareTo(aTime);
  });

  return archiveGroups;
}

int _compareCompletedTodos(Todo a, Todo b) {
  final bTime = b.completedAt?.millisecondsSinceEpoch ?? 0;
  final aTime = a.completedAt?.millisecondsSinceEpoch ?? 0;
  return bTime.compareTo(aTime);
}

String _normalizeTitle(String title) {
  return title.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

String _formatDateTime(DateTime date) {
  return '${_formatExactDate(date)}، ساعت ${_formatTime(date)}';
}

String _formatExactDate(DateTime date) {
  final jalaliDate = toPersianDigits(formatJalaliDate(date.toLocal()));
  return '$jalaliDate، ${_weekdayName(date.toLocal())}';
}

String _formatTime(DateTime date) {
  final localDate = date.toLocal();
  final hour = localDate.hour.toString().padLeft(2, '0');
  final minute = localDate.minute.toString().padLeft(2, '0');
  return toPersianDigits('$hour:$minute');
}

String _weekdayName(DateTime date) {
  return JalaliDate.weekdayNames[date.weekday - 1];
}

String _priorityLabel(TodoPriority priority) => switch (priority) {
  TodoPriority.low => 'کم',
  TodoPriority.normal => 'معمولی',
  TodoPriority.high => 'زیاد',
  TodoPriority.urgent => 'فوری',
};
