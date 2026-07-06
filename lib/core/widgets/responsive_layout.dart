import 'package:flutter/material.dart';

class ResponsiveLayout {
  ResponsiveLayout._();

  static const compactBreakpoint = 720.0;
  static const wideBreakpoint = 840.0;
  static const defaultMaxWidth = 720.0;
  static const wideMaxWidth = 760.0;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compactBreakpoint;
  }

  static double horizontalPadding(BuildContext context) {
    return isCompact(context) ? 16.0 : 24.0;
  }

  static double maxContentWidth(
    BuildContext context, {
    double compact = defaultMaxWidth,
    double wide = wideMaxWidth,
  }) {
    return MediaQuery.sizeOf(context).width >= wideBreakpoint ? wide : compact;
  }

  static EdgeInsets pagePadding(
    BuildContext context, {
    double top = 16,
    double bottom = 24,
  }) {
    final horizontal = horizontalPadding(context);
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }
}

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveContent({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveLayout.maxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}
