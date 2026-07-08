import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../settings/presentation/pages/settings_page.dart';
import 'add_task_page.dart';
import 'archive_page.dart';
import 'timetable_page.dart';
import 'todo_page.dart';

class MainShellPage extends StatefulWidget {
  final int initialIndex;

  const MainShellPage({super.key, this.initialIndex = 0});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MainShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _selectedIndex = widget.initialIndex;
    }
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const TodoPage(),
          AddTaskPage(onTaskAdded: () => _selectTab(0)),
          const TimetablePage(),
          const ArchivePage(),
          const SettingsPage(showAppBar: false, showQuickAccess: false),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectTab,
          height: 72,
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: primary.withValues(alpha: 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const _NavIcon(icon: HugeIcons.strokeRoundedHome01),
              selectedIcon: _NavIcon(
                icon: HugeIcons.strokeRoundedHome01,
                color: primary,
              ),
              label: 'خانه',
            ),
            NavigationDestination(
              icon: const _NavIcon(icon: HugeIcons.strokeRoundedPlusSignCircle),
              selectedIcon: _NavIcon(
                icon: HugeIcons.strokeRoundedPlusSignCircle,
                color: primary,
              ),
              label: 'افزودن',
            ),
            NavigationDestination(
              icon: const _NavIcon(icon: HugeIcons.strokeRoundedCalendar03),
              selectedIcon: _NavIcon(
                icon: HugeIcons.strokeRoundedCalendar03,
                color: primary,
              ),
              label: 'جدول زمانی',
            ),
            NavigationDestination(
              icon: const _NavIcon(icon: HugeIcons.strokeRoundedArchive),
              selectedIcon: _NavIcon(
                icon: HugeIcons.strokeRoundedArchive,
                color: primary,
              ),
              label: 'آرشیو',
            ),
            NavigationDestination(
              icon: const _NavIcon(icon: HugeIcons.strokeRoundedSettings02),
              selectedIcon: _NavIcon(
                icon: HugeIcons.strokeRoundedSettings02,
                color: primary,
              ),
              label: 'تنظیمات',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final List<List<dynamic>> icon;
  final Color? color;

  const _NavIcon({required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return HugeIcon(icon: icon, size: 26, color: color, strokeWidth: 2.2);
  }
}
