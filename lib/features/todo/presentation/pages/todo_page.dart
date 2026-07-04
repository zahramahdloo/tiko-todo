import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/account/account_settings_controller.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/todo_priority.dart';
import '../../../../core/enums/todo_status.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/add_task_bottom.dart';
import '../widgets/delete_dialog.dart';
import '../widgets/edit_task.dart';
import '../widgets/todo_item.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

enum _TodoFilter {
  all,
  active,
  completed,
  inProgress,
  cancelled,
  today,
  tomorrow,
  overdue,
  archived,
}

enum _TodoSort { newest, oldest, priority, dueDate }

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  _TodoFilter _filter = _TodoFilter.all;
  _TodoSort _sort = _TodoSort.newest;

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Todo> _visibleTodos(List<Todo> todos) {
    final query = _searchController.text.trim().toLowerCase();
    final settings = sl<AccountSettingsController>();

    final visible = todos.where((todo) {
      final searchableText = [
        todo.title,
        todo.category,
        ...todo.subtasks.map((subtask) => subtask.title),
      ].join(' ').toLowerCase();
      final matchesSearch = query.isEmpty || searchableText.contains(query);
      final matchesFilter = switch (_filter) {
        _TodoFilter.all => !todo.isArchived,
        _TodoFilter.active => !todo.isArchived && todo.status != TodoStatus.completed,
        _TodoFilter.completed => !todo.isArchived && todo.status == TodoStatus.completed,
        _TodoFilter.inProgress => !todo.isArchived && todo.status == TodoStatus.inProgress,
        _TodoFilter.cancelled => !todo.isArchived && todo.status == TodoStatus.cancelled,
        _TodoFilter.today => !todo.isArchived && _isToday(todo.dueAt),
        _TodoFilter.tomorrow => !todo.isArchived && _isTomorrow(todo.dueAt),
        _TodoFilter.overdue => !todo.isArchived && _isOverdue(todo),
        _TodoFilter.archived => todo.isArchived,
      };
      final matchesCompletedVisibility =
          !settings.hideCompleted ||
          todo.status != TodoStatus.completed ||
          _filter == _TodoFilter.completed ||
          _filter == _TodoFilter.archived;

      return matchesSearch && matchesFilter && matchesCompletedVisibility;
    }).toList();

    visible.sort((a, b) {
      return switch (_sort) {
        _TodoSort.newest => (b.id ?? 0).compareTo(a.id ?? 0),
        _TodoSort.oldest => (a.id ?? 0).compareTo(b.id ?? 0),
        _TodoSort.priority => _priorityRank(b.priority).compareTo(_priorityRank(a.priority)),
        _TodoSort.dueDate => _dueSortValue(a).compareTo(_dueSortValue(b)),
      };
    });

    return visible;
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isTomorrow(DateTime? date) {
    if (date == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  bool _isOverdue(Todo todo) {
    final dueAt = todo.dueAt;
    if (dueAt == null || todo.status == TodoStatus.completed) return false;
    final today = DateTime.now();
    final dueDate = DateTime(dueAt.year, dueAt.month, dueAt.day);
    final currentDate = DateTime(today.year, today.month, today.day);
    return dueDate.isBefore(currentDate);
  }

  int _priorityRank(TodoPriority priority) => switch (priority) {
    TodoPriority.low => 0,
    TodoPriority.normal => 1,
    TodoPriority.high => 2,
    TodoPriority.urgent => 3,
  };

  int _dueSortValue(Todo todo) {
    return todo.dueAt?.millisecondsSinceEpoch ?? 8640000000000000;
  }

  void _openAddSheet() {
    showAddTaskBottomSheet(
      context: context,
      controller: _controller,
      onAdd:
          (
            String title,
            TodoStatus status,
            TodoPriority priority,
            DateTime? reminderAt,
            DateTime? dueAt,
            String category,
            List<TodoSubtask> subtasks,
          ) async {
            context.read<TodoBloc>().add(
              AddTodo(
                Todo(
                  title: title.trim(),
                  status: status,
                  priority: priority,
                  reminderAt: reminderAt,
                  dueAt: dueAt,
                  category: category,
                  subtasks: subtasks,
                ),
              ),
            );
            _controller.clear();
          },
    );
  }

  void _openEditDialog(Todo todo) {
    _controller.text = todo.title;
    showEditTaskDialog(
      context: context,
      controller: _controller,
      todo: todo,
      onSave:
          (
            String title,
            TodoStatus status,
            TodoPriority priority,
            DateTime? dueAt,
            String category,
            List<TodoSubtask> subtasks,
          ) async {
            context.read<TodoBloc>().add(
              UpdateTodo(
                todo.copyWith(
                  title: title.trim(),
                  status: status,
                  priority: priority,
                  dueAt: dueAt,
                  category: category,
                  subtasks: subtasks,
                  clearDueAt: dueAt == null,
                ),
              ),
            );
            _controller.clear();
          },
    );
  }

  Future<void> _confirmDelete(Todo todo) async {
    final id = todo.id;

    if (id == null) return;

    final confirmed = await showDeleteDialog(context);

    if (!mounted || !confirmed) return;

    context.read<TodoBloc>().add(DeleteTodo(id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('«${todo.title}» حذف شد'),
        action: SnackBarAction(
          label: 'بازگردانی',
          onPressed: () {
            context.read<TodoBloc>().add(AddTodo(todo));
          },
        ),
      ),
    );
  }

  void _toggleArchive(Todo todo) {
    context.read<TodoBloc>().add(UpdateTodo(todo.copyWith(isArchived: !todo.isArchived)));
  }

  void _toggleSubtask(Todo todo, int subtaskIndex) {
    final subtasks = [...todo.subtasks];
    final subtask = subtasks[subtaskIndex];
    subtasks[subtaskIndex] = subtask.copyWith(isCompleted: !subtask.isCompleted);
    context.read<TodoBloc>().add(UpdateTodo(todo.copyWith(subtasks: subtasks)));
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 720 ? 24.0 : 16.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: AnimatedBuilder(
          animation: sl<AccountSettingsController>(),
          builder: (context, _) {
            return _TodoAppBar(
              searchController: _searchController,
              filter: _filter,
              sort: _sort,
              onSearchChanged: (_) => setState(() {}),
              onFilterChanged: (filter) => setState(() => _filter = filter),
              onSortChanged: (sort) => setState(() => _sort = sort),
              onAdd: _openAddSheet,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: const Color(0xFF2B60E4),
        foregroundColor: Colors.white,
        child: const FaIcon(FontAwesomeIcons.plus, size: 18),
      ),
      body: AnimatedBuilder(
        animation: sl<AccountSettingsController>(),
        builder: (context, _) {
          return BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              if (state is TodoLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TodoError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.circleExclamation, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<TodoBloc>().add(const LoadTodo()),
                        child: const Text('تلاش مجدد'),
                      ),
                    ],
                  ),
                );
              }

              if (state is TodoLoaded) {
                final visibleTodos = _visibleTodos(state.todos);
                final hasActiveFilter =
                    _filter != _TodoFilter.all || _searchController.text.trim().isNotEmpty;

                if (state.todos.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(FontAwesomeIcons.listCheck, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'هیچ کاری وجود ندارد\nروی + بزن تا اولین کار رو اضافه کنی',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (visibleTodos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.magnifyingGlassMinus,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hasActiveFilter
                                ? 'کاری با این جستجو یا فیلتر پیدا نشد'
                                : 'کاری برای نمایش وجود ندارد',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final completedCount = state.todos
                    .where((todo) => todo.status == TodoStatus.completed)
                    .length;
                final urgentCount = state.todos
                    .where((todo) => !todo.isArchived && todo.priority == TodoPriority.urgent)
                    .length;
                final overdueCount = state.todos.where(_isOverdue).length;

                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: CustomScrollView(
                          slivers: [
                            // === تولبار دکمه‌ها (تازه‌سازی / کار جدید / تنظیمات / مرتب‌سازی) ===
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'تازه‌سازی',
                                      onPressed: () =>
                                          context.read<TodoBloc>().add(const LoadTodo()),
                                      icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 17),
                                    ),
                                    IconButton(
                                      tooltip: 'کار جدید',
                                      onPressed: _openAddSheet,
                                      icon: const FaIcon(FontAwesomeIcons.plus, size: 17),
                                    ),
                                    const Spacer(),
                                    PopupMenuButton<_TodoSort>(
                                      tooltip: 'مرتب‌سازی',
                                      initialValue: _sort,
                                      onSelected: (value) {
                                        setState(() => _sort = value);
                                      },
                                      icon: const FaIcon(FontAwesomeIcons.sort, size: 17),
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: _TodoSort.newest,
                                          child: Text('جدیدترین'),
                                        ),
                                        PopupMenuItem(
                                          value: _TodoSort.oldest,
                                          child: Text('قدیمی‌ترین'),
                                        ),
                                        PopupMenuItem(
                                          value: _TodoSort.priority,
                                          child: Text('اولویت'),
                                        ),
                                        PopupMenuItem(
                                          value: _TodoSort.dueDate,
                                          child: Text('نزدیک‌ترین سررسید'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // === کارت خلاصه وضعیت ===
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                12,
                                horizontalPadding,
                                8,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: _TodoSummary(
                                  totalCount: state.todos.length,
                                  completedCount: completedCount,
                                  urgentCount: urgentCount,
                                  overdueCount: overdueCount,
                                ),
                              ),
                            ),

                            // === لیست کارها ===
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                8,
                                horizontalPadding,
                                96,
                              ),
                              sliver: SliverList.separated(
                                itemCount: visibleTodos.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final todo = visibleTodos[index];
                                  return TodoItem(
                                    todo: todo,
                                    onToggle: () => context.read<TodoBloc>().add(ToggleTodo(todo)),
                                    onEdit: () => _openEditDialog(todo),
                                    onDelete: () => _confirmDelete(todo),
                                    onArchive: () => _toggleArchive(todo),
                                    onToggleSubtask: (subtaskIndex) =>
                                        _toggleSubtask(todo, subtaskIndex),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (state.isSaving)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                  ],
                );
              }

              return const SizedBox();
            },
          );
        },
      ),
    );
  }
}

class _TodoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final _TodoFilter filter;
  final _TodoSort sort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_TodoFilter> onFilterChanged;
  final ValueChanged<_TodoSort> onSortChanged;
  final VoidCallback onAdd;

  const _TodoAppBar({
    required this.searchController,
    required this.filter,
    required this.sort,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onAdd,
  });

  @override
  Size get preferredSize => const Size.fromHeight(180);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72,
      centerTitle: true,
      titleSpacing: 0,
      actions: [
        IconButton(
          tooltip: 'تنظیمات',
          onPressed: () => context.push('/settings'),
          icon: const FaIcon(FontAwesomeIcons.gear, size: 18, color: Color(0xFF2B60E4)),
        ),
      ],

      title: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          final totalCount = state is TodoLoaded ? state.todos.length : 0;
          final pendingCount = state is TodoLoaded
              ? state.todos.where((todo) => todo.status != TodoStatus.completed).length
              : 0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icons/app_icon.png', width: 25, height: 25),
                  const SizedBox(width: 8),
                  const Text('تیکو', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              const SizedBox(height: 2),
            ],
          );
        },
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(108),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'جستجو در کارها',
                    prefixIcon: const Center(
                      widthFactor: 1,
                      child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16),
                    ),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'پاک کردن جستجو',
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                            icon: const FaIcon(FontAwesomeIcons.xmark, size: 16),
                          ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChipButton(
                      label: 'همه',
                      selected: filter == _TodoFilter.all,
                      onSelected: () => onFilterChanged(_TodoFilter.all),
                    ),
                    _FilterChipButton(
                      label: 'انجام نشده',
                      selected: filter == _TodoFilter.active,
                      onSelected: () => onFilterChanged(_TodoFilter.active),
                    ),
                    _FilterChipButton(
                      label: 'انجام شده',
                      selected: filter == _TodoFilter.completed,
                      onSelected: () => onFilterChanged(_TodoFilter.completed),
                    ),
                    _FilterChipButton(
                      label: 'در حال انجام',
                      selected: filter == _TodoFilter.inProgress,
                      onSelected: () => onFilterChanged(_TodoFilter.inProgress),
                    ),
                    _FilterChipButton(
                      label: 'لغو شده',
                      selected: filter == _TodoFilter.cancelled,
                      onSelected: () => onFilterChanged(_TodoFilter.cancelled),
                    ),
                    _FilterChipButton(
                      label: 'امروز',
                      selected: filter == _TodoFilter.today,
                      onSelected: () => onFilterChanged(_TodoFilter.today),
                    ),
                    _FilterChipButton(
                      label: 'فردا',
                      selected: filter == _TodoFilter.tomorrow,
                      onSelected: () => onFilterChanged(_TodoFilter.tomorrow),
                    ),
                    _FilterChipButton(
                      label: 'عقب‌افتاده',
                      selected: filter == _TodoFilter.overdue,
                      onSelected: () => onFilterChanged(_TodoFilter.overdue),
                    ),
                    _FilterChipButton(
                      label: 'آرشیو',
                      selected: filter == _TodoFilter.archived,
                      onSelected: () => onFilterChanged(_TodoFilter.archived),
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

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChipButton({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.primary.withValues(alpha: 0.14),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}

class _TodoSummary extends StatelessWidget {
  final int totalCount;
  final int completedCount;
  final int urgentCount;
  final int overdueCount;

  const _TodoSummary({
    required this.totalCount,
    required this.completedCount,
    required this.urgentCount,
    required this.overdueCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.chartSimple, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$completedCount از $totalCount کار انجام شده',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryPill(
                icon: FontAwesomeIcons.exclamation,
                label: '$urgentCount فوری',
                color: AppColors.priorityUrgent,
              ),
              _SummaryPill(
                icon: FontAwesomeIcons.triangleExclamation,
                label: '$overdueCount عقب‌افتاده',
                color: AppColors.statusPending,
              ),
              _SummaryPill(
                icon: FontAwesomeIcons.checkDouble,
                label: '${(progress * 100).round()}٪ پیشرفت',
                color: AppColors.statusCompleted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final Color color;

  const _SummaryPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
