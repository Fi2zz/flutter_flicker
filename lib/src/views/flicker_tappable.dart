import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Shared widgets for the Flicker package
///
/// This file contains common UI components used throughout the date picker:
/// - FadeInOut: Animated visibility widget with fade transitions
/// - Tappable: Enhanced gesture detector with visual feedback
/// - Chevron: Custom-painted arrow buttons for navigation
/// - Right: Rotatable triangle indicator for expand/collapse states
/// - ConstrainedContainer: Container with axis-specific constraints
/// - RootView: Main container with theme-based styling
///
/// Usage Example:
/// ```dart
/// // Tappable with feedback
/// Tappable(
///   onTap: () => print('Tapped!'),
///   child: Container(width: 100, height: 50),
/// )

/// ```

/// Tappable Widget
///
/// Wraps GestureDetector to provide unified touch interaction control
/// When tappable is false, all touch events are disabled
/// Supports state management and animation effects with scale feedback
class Tappable extends StatefulWidget {
  /// Whether the widget is tappable
  final bool tappable;

  /// Tap callback
  final GestureTapCallback? onTap;

  /// Tap down callback
  final GestureTapDownCallback? onTapDown;

  /// Tap up callback
  final GestureTapUpCallback? onTapUp;

  /// Tap cancel callback
  final GestureTapCancelCallback? onTapCancel;

  /// Double tap callback
  final GestureTapCallback? onDoubleTap;

  /// Long press callback
  final GestureLongPressCallback? onLongPress;

  /// Pan start callback
  final GestureDragStartCallback? onPanStart;

  /// Pan update callback
  final GestureDragUpdateCallback? onPanUpdate;

  /// Pan end callback
  final GestureDragEndCallback? onPanEnd;

  /// Pan cancel callback
  final GestureDragCancelCallback? onPanCancel;

  /// Scale start callback
  final GestureScaleStartCallback? onScaleStart;

  /// Scale update callback
  final GestureScaleUpdateCallback? onScaleUpdate;

  /// Scale end callback
  final GestureScaleEndCallback? onScaleEnd;

  /// Hit test behavior
  final HitTestBehavior? behavior;

  /// Whether to exclude from semantics
  final bool excludeFromSemantics;

  /// Drag start behavior
  final DragStartBehavior dragStartBehavior;

  /// Child widget
  final Widget child;

  final EdgeInsetsGeometry? padding;

  /// Creates a tappable widget
  ///
  /// - [tappable]: Whether tappable, all touch events disabled when false
  /// - [onTap]: Tap callback
  /// - [onTapDown]: Tap down callback
  /// - [onTapUp]: Tap up callback
  /// - [onTapCancel]: Tap cancel callback
  /// - [onDoubleTap]: Double tap callback
  /// - [onLongPress]: Long press callback
  /// - [child]: Child widget
  const Tappable({
    super.key,
    this.tappable = true,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.behavior,
    this.excludeFromSemantics = false,
    this.dragStartBehavior = DragStartBehavior.start,
    this.padding,
    required this.child,
  });

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.tappable) {
      setState(() => _isPressed = true);
      widget.onTapDown?.call(details);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.tappable) {
      setState(() => _isPressed = false);
      widget.onTapUp?.call(details);
    }
  }

  void _handleTapCancel() {
    if (widget.tappable) {
      setState(() => _isPressed = false);
      widget.onTapCancel?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.tappable ? widget.onTap : null,
      onTapDown: widget.tappable ? _handleTapDown : null,
      onTapUp: widget.tappable ? _handleTapUp : null,
      onTapCancel: widget.tappable ? _handleTapCancel : null,
      onDoubleTap: widget.tappable ? widget.onDoubleTap : null,
      onLongPress: widget.tappable ? widget.onLongPress : null,
      onPanStart: widget.tappable ? widget.onPanStart : null,
      onPanUpdate: widget.tappable ? widget.onPanUpdate : null,
      onPanEnd: widget.tappable ? widget.onPanEnd : null,
      onPanCancel: widget.tappable ? widget.onPanCancel : null,
      onScaleStart: widget.tappable ? widget.onScaleStart : null,
      onScaleUpdate: widget.tappable ? widget.onScaleUpdate : null,
      onScaleEnd: widget.tappable ? widget.onScaleEnd : null,
      behavior: widget.behavior,
      excludeFromSemantics: widget.excludeFromSemantics,
      dragStartBehavior: widget.dragStartBehavior,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.all(0),
        child: Opacity(
          opacity: _isPressed || widget.tappable == false ? 0.4 : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}
