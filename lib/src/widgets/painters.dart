import 'package:flutter/widgets.dart';

/// A customizable chevron (arrow) widget for navigation controls
///
/// This widget renders a directional arrow using custom painting, commonly used
/// for navigation buttons in date pickers and other UI components.
///
/// ## Features
/// - **Directional arrows**: Supports left and right pointing chevrons
/// - **Custom styling**: Configurable color and consistent sizing
/// - **Optimized rendering**: Uses CustomPaint for efficient drawing
///
/// ## Usage
/// ```dart
/// Chevron(
///   type: 'left',
///   color: Colors.blue,
/// )
/// ```
///
/// The chevron is rendered within a 40x40 pixel square container to ensure
/// consistent touch targets and visual alignment.
class Chevron extends StatelessWidget {
  /// Direction of the chevron arrow
  ///
  /// Supported values:
  /// - `'left'`: Points to the left (←)
  /// - `'right'`: Points to the right (→)
  final String type;

  /// Color of the chevron arrow
  ///
  /// This color is used for the stroke of the arrow path.
  final Color color;

  /// Creates a chevron widget
  ///
  /// Both [type] and [color] are required parameters.
  /// The [type] determines the direction of the arrow.
  const Chevron({super.key, required this.type, required this.color});

  /// Builds the chevron widget with custom painting
  ///
  /// Creates a 40x40 pixel container with a custom-painted chevron arrow.
  /// The arrow is drawn using the [_ChevronPainter] with the specified
  /// direction and color.
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40, // Standard touch target size
      child: AspectRatio(
        aspectRatio: 1, // Maintain square aspect ratio
        child: CustomPaint(
          size: const Size(20, 20), // Drawing area size
          painter: _ChevronPainter(direction: type, color: color),
        ),
      ),
    );
  }
}

/// Custom painter for drawing chevron arrows
///
/// This painter creates directional arrow shapes using path drawing.
/// It supports left and right pointing chevrons with customizable colors.
///
/// The chevron is drawn as a V-shaped path with rounded stroke caps
/// and joins for a smooth appearance.
class _ChevronPainter extends CustomPainter {
  /// Direction of the chevron ('left' or 'right')
  final String direction;

  /// Color for the chevron stroke
  final Color color;

  /// Creates a chevron painter with the specified direction and color
  _ChevronPainter({required this.direction, required this.color});

  /// Paints the chevron arrow on the canvas
  ///
  /// This method:
  /// 1. Sets up paint properties for smooth, rounded strokes
  /// 2. Calculates the chevron path based on direction
  /// 3. Draws the path on the canvas
  ///
  /// The chevron is centered within the given size and scaled proportionally.
  @override
  void paint(Canvas canvas, Size size) {
    // Configure paint for smooth, rounded chevron
    final paint = Paint()
      ..color = color
      ..strokeWidth =
          2.0 // Consistent stroke width
      ..strokeCap = StrokeCap
          .round // Rounded line ends
      ..strokeJoin = StrokeJoin
          .round // Rounded corners
      ..style = PaintingStyle.stroke; // Outline only

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * 0.15; // Chevron width (15% of container)
    final height = size.height * 0.35; // Chevron height (35% of container)

    // Draw left-pointing chevron (←)
    if (direction == 'left') {
      path.moveTo(center.dx + width / 2, center.dy - height / 2); // Top right
      path.lineTo(center.dx - width / 2, center.dy); // Center left (point)
      path.lineTo(
        center.dx + width / 2,
        center.dy + height / 2,
      ); // Bottom right
    } else {
      // Draw right-pointing chevron (→)
      path.moveTo(center.dx - width / 2, center.dy - height / 2); // Top left
      path.lineTo(center.dx + width / 2, center.dy); // Center right (point)
      path.lineTo(center.dx - width / 2, center.dy + height / 2); // Bottom left
    }

    canvas.drawPath(path, paint);
  }

  /// Determines if the painter should repaint
  ///
  /// Returns true if the direction or color has changed since the last paint.
  /// This optimization prevents unnecessary repaints when properties are unchanged.
  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) {
    return oldDelegate.direction != direction || oldDelegate.color != color;
  }
}

/// A customizable triangle widget for dropdown indicators and UI accents
///
/// This widget renders a small triangular shape using custom painting, commonly
/// used as dropdown indicators, expand/collapse arrows, or decorative elements.
///
/// ## Features
/// - **Directional control**: Can be flipped vertically using the reverse parameter
/// - **Conditional rendering**: Hides when reverse is null
/// - **Custom styling**: Configurable color
/// - **Compact size**: Fixed 12x12 pixel dimensions for consistent UI
///
/// ## Usage
/// ```dart
/// Triangle(
///   reverse: false, // Points up
///   color: Colors.blue,
/// )
///
/// Triangle(
///   reverse: true, // Points down
///   color: Colors.red,
/// )
///
/// Triangle(
///   reverse: null, // Hidden
///   color: Colors.green,
/// )
/// ```
class Triangle extends StatelessWidget {
  /// Controls the triangle orientation and visibility
  ///
  /// - `false`: Triangle points up (▲)
  /// - `true`: Triangle points down (▼)
  /// - `null`: Triangle is hidden (returns empty widget)
  final bool? reverse;

  /// Color of the triangle fill
  final Color color;

  /// Creates a triangle widget
  ///
  /// The [color] is required, while [reverse] controls orientation and visibility.
  const Triangle({super.key, this.reverse, required this.color});

  /// Builds the triangle widget with optional vertical flipping
  ///
  /// Returns an empty widget if [reverse] is null, otherwise creates a
  /// 12x12 pixel triangle that can be flipped vertically based on the
  /// [reverse] parameter.
  @override
  Widget build(BuildContext context) {
    // Hide triangle when reverse is null
    if (reverse == null) return const SizedBox.shrink();

    return Transform.scale(
      scaleY: reverse == true ? -1.0 : 1.0, // Flip vertically if reversed
      alignment: Alignment.center, // Scale from center
      child: CustomPaint(
        size: const Size(12, 12), // Fixed compact size
        painter: _TrianglePainter(color: color),
      ),
    );
  }
}

/// Custom painter for drawing filled triangular shapes
///
/// This painter creates an upward-pointing triangle using path drawing.
/// The triangle is filled with a solid color and centered within the
/// given canvas size.
///
/// The triangle shape is designed to be compact and visually balanced,
/// with proportional width and height relative to the canvas size.
class _TrianglePainter extends CustomPainter {
  /// Color for the triangle fill
  final Color color;

  /// Creates a triangle painter with the specified fill color
  _TrianglePainter({required this.color});

  /// Paints a filled triangle on the canvas
  ///
  /// This method:
  /// 1. Sets up paint properties for solid fill
  /// 2. Calculates triangle vertices based on canvas size
  /// 3. Creates a triangular path and fills it
  ///
  /// The triangle is drawn with:
  /// - Width: 80% of canvas width
  /// - Height: 40% of canvas height
  /// - Centered horizontally and vertically
  /// - Apex pointing upward
  @override
  void paint(Canvas canvas, Size size) {
    // Configure paint for solid fill
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill; // Solid fill

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final height = size.height * 0.4; // Triangle height (40% of canvas)
    final width = size.width * 0.8; // Triangle width (80% of canvas)

    // Create triangle path (pointing up)
    path.moveTo(
      centerX,
      centerY + height / 2,
    ); // Bottom center (apex when flipped)
    path.lineTo(centerX - width / 2, centerY - height / 2); // Top left
    path.lineTo(centerX + width / 2, centerY - height / 2); // Top right
    path.close(); // Close the path to create a filled shape

    canvas.drawPath(path, paint);
  }

  /// Determines if the painter should repaint
  ///
  /// Returns false since the triangle shape and color are static once created.
  /// This optimization prevents unnecessary repaints.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
