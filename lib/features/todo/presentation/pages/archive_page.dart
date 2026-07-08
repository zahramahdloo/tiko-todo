import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/jalali_date.dart';
import '../../../../core/widgets/app_bar_brand_title.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ResponsiveContent(
          child: BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              final completedGroups = state is TodoLoaded
                  ? _groupCompletedTodos(state.todos)
                  : const <_ArchiveTaskGroup>[];
              final completedCount = completedGroups.fold<int>(
                0,
                (sum, group) => sum + group.todos.length,
              );

              return Column(
                children: [
                  _ArchiveHeader(
                    taskCount: completedGroups.length,
                    completedCount: completedCount,
                  ),
                  Expanded(
                    child: switch (state) {
                      TodoLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      TodoError() => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      TodoLoaded() when completedGroups.isEmpty =>
                        const _EmptyArchive(),
                      TodoLoaded() => ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          18,
                          horizontalPadding,
                          28,
                        ),
                        itemCount: completedGroups.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                      ),
                      _ => const SizedBox.shrink(),
                    },
                  ),
                ],
              );
            },
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
      appBar: AppBar(
        centerTitle: true,
        title: const AppBarBrandTitle(
          title: 'جزئیات آرشیو',
          iconSize: 24,
          fontSize: 18,
        ),
      ),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.65),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withValues(alpha: 0.04),
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
                              strokeWidth: 2.2,
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
  final int taskCount;
  final int completedCount;

  const _ArchiveHeader({required this.taskCount, required this.completedCount});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedArchive,
                size: 28,
                color: Colors.white,
                strokeWidth: 2.2,
              ),
              const Spacer(),
              AppBarBrandTitle(
                title: 'آرشیو',
                iconSize: 24,
                fontSize: 20,
                foregroundColor: Colors.white,
                iconBackgroundColor: Colors.white.withValues(alpha: 0.16),
                iconBorderColor: Colors.white.withValues(alpha: 0.22),
              ),
              const Spacer(),
              const SizedBox(width: 28),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ArchiveHeaderMetric(
                  value: toPersianDigits(completedCount),
                  label: 'انجام‌شده',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ArchiveHeaderMetric(
                  value: toPersianDigits(taskCount),
                  label: 'عنوان',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArchiveHeaderMetric extends StatelessWidget {
  final String value;
  final String label;

  const _ArchiveHeaderMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.70),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.statusCompleted.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedTickDouble01,
                        size: 24,
                        color: AppColors.statusCompleted,
                        strokeWidth: 2.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      group.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.70,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                        strokeWidth: 2.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _ArchiveMetaChip(
                    icon: HugeIcons.strokeRoundedTaskDone01,
                    label: '${toPersianDigits(group.todos.length)} بار',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ArchiveMetaChip(
                      icon: HugeIcons.strokeRoundedCalendarCheckIn01,
                      label: completedAt == null
                          ? 'تاریخ ثبت نشده'
                          : _formatCompactDate(completedAt),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchiveMetaChip extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;

  const _ArchiveMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.statusCompleted.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            size: 18,
            color: AppColors.statusCompleted,
            strokeWidth: 2.2,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
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
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
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
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        HugeIcon(icon: icon, size: 22, color: secondary, strokeWidth: 2.2),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: secondary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
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
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: subtask.isCompleted
                ? HugeIcons.strokeRoundedTick02
                : HugeIcons.strokeRoundedCircle,
            size: 20,
            color: subtask.isCompleted ? AppColors.statusCompleted : secondary,
            strokeWidth: 2.2,
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.70),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArchive,
                    size: 34,
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2.2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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

String _formatCompactDate(DateTime date) {
  return toPersianDigits(formatJalaliDate(date.toLocal()));
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
