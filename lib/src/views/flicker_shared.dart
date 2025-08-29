import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/constants/ui_constants.dart';
import 'flicker_extensions.dart';

const double gridBasicSize = 40.0;
const double gridViewWidth = 7 * gridBasicSize;
const double gridViewHeight = 5 * gridBasicSize;

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
/// // Fade in/out animation
/// FadeInOut(
///   visible: isVisible,
///   child: Text('Hello World'),
/// )
///
/// // Tappable with feedback
/// Tappable(
///   onTap: () => print('Tapped!'),
///   child: Container(width: 100, height: 50),
/// )
///
/// // Navigation arrows
/// Chevron.left(onTap: () => previousPage())
/// Chevron.right(onTap: () => nextPage())
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

/// Chevron Arrow Button Component
///
/// Provides left/right arrow buttons with tap state feedback (opacity change on press)
/// Uses CustomPainter for optimized rendering and consistent visual appearance
class Chevron extends StatelessWidget {
  /// Tap callback
  final GestureTapCallback onTap;

  /// Arrow type, 'left' or 'right'
  final String type;

  /// Whether touchable
  final bool? touchable;

  /// Creates a chevron arrow button
  ///
  /// - [type]: Arrow type, 'left' or 'right'
  /// - [onTap]: Tap callback
  /// - [size]: Icon size, defaults to 24
  /// - [touchable]: Whether touchable
  const Chevron({
    super.key,
    required this.type,
    required this.onTap,
    this.touchable,
  });
  // @override

  // State<Chevron> createState() => _ChevronState();

  /// Gets the custom painted chevron widget
  Widget getCustomChevron(BuildContext context) {
    final theme = context.flickerTheme;
    Color color = theme.daySelectedTextStyle.color!;
    return CustomPaint(
      size: Size(20, 20),
      painter: _ChevronPainter(direction: type, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizedBox square = SizedBox.square(
      dimension: 40,
      child: AspectRatio(aspectRatio: 1, child: getCustomChevron(context)),
    );
    return Tappable(tappable: touchable != false, onTap: onTap, child: square);
  }

  /// Creates a left arrow button
  ///
  /// - [onTap]: Tap callback
  /// - [size]: Icon size, defaults to 20
  /// - [touchable]: Whether touchable
  static Chevron left({required GestureTapCallback onTap, bool? touchable}) {
    return Chevron(type: 'left', onTap: onTap, touchable: touchable);
  }

  /// Creates a right arrow button
  ///
  /// - [onTap]: Tap callback
  /// - [size]: Icon size, defaults to 20
  /// - [touchable]: Whether touchable
  static Chevron right({required GestureTapCallback onTap, bool? touchable}) {
    return Chevron(type: 'right', onTap: onTap, touchable: touchable);
  }
}

/// Custom Chevron Painter
///
/// Draws chevron arrows using CustomPainter for better performance and control.
/// Supports both left and right directions with customizable colors.
/// The arrow shape is flattened (height > width) for a modern appearance.
class _ChevronPainter extends CustomPainter {
  final String direction;
  final Color color;
  _ChevronPainter({required this.direction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = IconDrawingConstants.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * IconDrawingConstants.arrowWidthRatio;
    final height = size.height * IconDrawingConstants.arrowHeightRatio;
    if (direction == 'left') {
      // Draw left arrow: >
      path.moveTo(center.dx + width / 2, center.dy - height / 2);
      path.lineTo(center.dx - width / 2, center.dy);
      path.lineTo(center.dx + width / 2, center.dy + height / 2);
    } else {
      // Draw right arrow: <
      path.moveTo(center.dx - width / 2, center.dy - height / 2);
      path.lineTo(center.dx + width / 2, center.dy);
      path.lineTo(center.dx - width / 2, center.dy + height / 2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) {
    return oldDelegate.direction != direction || oldDelegate.color != color;
  }
}

/// Rotatable Arrow Component
///
/// Provides arrow rotation animation for expand/collapse state indication
/// Uses a triangle shape that flips vertically based on the active state
class Triangle extends StatefulWidget {
  /// Whether active (expanded state)
  final bool? active;

  /// Creates a rotatable arrow
  ///
  /// - [size]: Icon size
  /// - [active]: Whether active, arrow rotates when true
  const Triangle({super.key, this.active});

  @override
  State<StatefulWidget> createState() {
    return _TriangleState();
  }
}

/// Rotatable Arrow State Class
///
/// Manages the animation controller and handles the vertical flip animation
/// based on the active state changes.
class _TriangleState extends State<Triangle>
    with SingleTickerProviderStateMixin {
  /// Animation controller for rotation effects
  late final AnimationController animation = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  @override
  void dispose() {
    super.dispose();
    animation.dispose();
  }

  @override
  void didUpdateWidget(covariant Triangle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == true) {
      animation.forward();
    } else if (widget.active == false) {
      animation.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final theme = context.flickerTheme;
        Color color = theme.daySelectedTextStyle.color!;
        return Transform.scale(
          scaleY: widget.active == true ? -1.0 : 1.0,
          alignment: Alignment.center,
          child: CustomPaint(
            size: Size(12, 12),
            painter: _TrianglePainter(color: color),
          ),
        );
      },
    );
  }
}

/// Triangle Painter
///
/// Custom painter that draws a flattened triangle shape.
/// The triangle is wider than it is tall for a modern, flat appearance.
/// Default orientation is pointing downward.
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Flattened triangle, pointing down by default
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final height = size.height * IconDrawingConstants.triangleHeightRatio;
    final width = size.width * IconDrawingConstants.triangleWidthRatio;
    path.moveTo(centerX, centerY + height / 2); // Bottom vertex
    path.lineTo(centerX - width / 2, centerY - height / 2); // Top left vertex
    path.lineTo(centerX + width / 2, centerY - height / 2); // Top right vertex
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
