import 'package:flutter/widgets.dart';
import 'flicker_tappable.dart';
import 'flicker_extensions.dart';



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
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * 0.15;
    final height = size.height * 0.35;
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
    final height = size.height * 0.4;
    final width = size.width * 0.8;
    path.moveTo(centerX, centerY + height / 2); // Bottom vertex
    path.lineTo(centerX - width / 2, centerY - height / 2); // Top left vertex
    path.lineTo(centerX + width / 2, centerY - height / 2); // Top right vertex
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
