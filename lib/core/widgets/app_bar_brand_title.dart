import 'package:flutter/material.dart';

class AppBarBrandTitle extends StatelessWidget {
  final String title;
  final double iconSize;
  final double fontSize;
  final Color? foregroundColor;
  final Color? iconBackgroundColor;
  final Color? iconBorderColor;

  const AppBarBrandTitle({
    super.key,
    required this.title,
    this.iconSize = 28,
    this.fontSize = 20,
    this.foregroundColor,
    this.iconBackgroundColor,
    this.iconBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color:
                iconBackgroundColor ??
                colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  iconBorderColor ??
                  colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/icons/app_icon.png',
              width: iconSize,
              height: iconSize,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
