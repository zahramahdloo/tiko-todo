import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/account/account_settings_controller.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/responsive_layout.dart';

class SettingsPage extends StatefulWidget {
  final bool showAppBar;
  final bool showQuickAccess;

  const SettingsPage({
    super.key,
    this.showAppBar = true,
    this.showQuickAccess = true,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameController = TextEditingController();

  static const _colors = [
    Color(0xFF2463EB),
    Color(0xFF7C3AED),
    Color(0xFF00A676),
    Color(0xFFEF4444),
    Color(0xFFDB2777),
    Color(0xFFF59E0B),
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text =
        sl<AccountSettingsController>().currentUser?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName(AccountSettingsController settings) async {
    await settings.updateProfileName(_nameController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('نام کاربر ذخیره شد')));
  }

  Future<void> _signOut(AccountSettingsController settings) async {
    await settings.signOut();
    if (mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final settings = sl<AccountSettingsController>();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final user = settings.currentUser;

        return Scaffold(
          appBar: widget.showAppBar
              ? AppBar(title: const Text('تنظیمات'))
              : null,
          body: SafeArea(
            child: ResponsiveContent(
              maxWidth: 640,
              child: ListView(
                padding: ResponsiveLayout.pagePadding(context),
                children: [
                  _Section(
                    title: 'حساب کاربری',
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: settings.primaryColor.withValues(
                            alpha: 0.14,
                          ),
                          child: Text(
                            (user?.name.isNotEmpty ?? false)
                                ? user!.name.characters.first
                                : 'T',
                            style: TextStyle(
                              color: settings.primaryColor,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(user?.email ?? 'بدون ایمیل'),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'نام نمایشی',
                            prefixIcon: Center(
                              widthFactor: 1,
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedUser,
                                size: 24,
                                strokeWidth: 2.35,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _saveName(settings),
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedFloppyDisk,
                              size: 24,
                              strokeWidth: 2.35,
                            ),
                            label: const Text('ذخیره نام'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'ظاهر اپ',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('رنگ اصلی'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _colors.map((color) {
                            final selected =
                                color.toARGB32() ==
                                settings.primaryColor.toARGB32();
                            return InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => settings.setPrimaryColor(color),
                              child: Container(
                                width: 44,
                                height: 44,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedSettings02,
                                size: 28,
                                strokeWidth: 2.35,
                              ),
                              label: Text('سیستم'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedSun03,
                                size: 28,
                                strokeWidth: 2.35,
                              ),
                              label: Text('روشن'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedMoon,
                                size: 28,
                                strokeWidth: 2.35,
                              ),
                              label: Text('تاریک'),
                            ),
                          ],
                          selected: {settings.themeMode},
                          onSelectionChanged: (value) =>
                              settings.setThemeMode(value.first),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'رفتار لیست کارها',
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: settings.hideCompleted,
                      onChanged: settings.setHideCompleted,
                      title: const Text('مخفی کردن کارهای انجام‌شده'),
                      subtitle: const Text(
                        'وقتی روشن باشد، کارهای انجام‌شده از لیست اصلی پنهان می‌شوند.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'حساب',
                    child: Column(
                      children: [
                        if (widget.showQuickAccess)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const HugeIcon(
                              icon: HugeIcons.strokeRoundedTask01,
                              size: 28,
                              strokeWidth: 2.35,
                            ),
                            title: const Text('بازگشت به کارها'),
                            trailing: const HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft01,
                              size: 28,
                              strokeWidth: 2.35,
                            ),
                            onTap: () => context.go('/home'),
                          ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const HugeIcon(
                            icon: HugeIcons.strokeRoundedLogout03,
                            size: 28,
                            strokeWidth: 2.35,
                          ),
                          title: const Text('خروج از حساب'),
                          textColor: Colors.red,
                          iconColor: Colors.red,
                          onTap: () => _signOut(settings),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
