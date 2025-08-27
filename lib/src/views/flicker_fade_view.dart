import 'package:flutter/material.dart';

class FlickerFadeView extends StatelessWidget {
  /// Animation duration (300 milliseconds)
  final Duration duration = const Duration(milliseconds: 300);

  /// Child widget to animate
  final Widget child;

  /// Whether the child should be visible
  final bool visible;

  /// Creates a fade in/out widget
  ///
  /// - [child]: Child widget to animate
  /// - [visible]: Whether the child should be visible
  const FlickerFadeView({
    super.key,
    required this.child,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0, // 直接受控
      duration: duration,
      curve: Curves.easeInOut,
      child: IgnorePointer(ignoring: visible == false, child: child),
    );
  }
}
