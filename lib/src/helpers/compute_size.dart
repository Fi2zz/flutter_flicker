import 'package:flutter/widgets.dart';

// Base unit size (40.0) - fundamental measurement unit for the date picker
const double unitSize = 40.0;

// Standard width: 7 units (for 7 days of the week)
const double width = 7 * unitSize;
// Standard height: 5 units (for typical month grid with 5-6 rows)

const double height = 5 * unitSize;

const Size baseSize = Size(width, unitSize);

const Size standardSize = Size(width, height);

/// Enumeration defining different sources for size computation
///
/// This enum is used to specify the context or source type when computing
/// sizes for different UI components in the date picker.
enum ComputeSource {
  /// Panel source - used for computing panel container sizes
  panel,

  /// Root source - used for computing root container sizes
  root,

  /// Standard source - used for standard component sizes
  standard,

  /// Base source - used for base unit sizes
  base,

  /// Unit source - used for individual unit sizes
  unit,
}

/// Computes the appropriate size for date picker components based on context
///
/// This function calculates the optimal size for various date picker components
/// based on the source type, count of items, and scroll direction. It uses a
/// base unit system for consistent sizing across the entire date picker.
///
/// Parameters:
/// - [source]: The computation source type that determines sizing strategy
/// - [count]: Number of items/components to account for in size calculation
/// - [scrollDirection]: The scroll direction (horizontal/vertical) for layout
///
/// Returns:
/// A [Size] object with the computed width and height dimensions
///
/// Example:
/// ```dart
///
/// // Get size for a panel with 2 items horizontally
/// Size panelSize = computeSize(ComputeSource.panel, 2, Axis.horizontal);
/// ```
Size computeSize([ComputeSource? source, int? count, Axis? scrollDirection]) {
  // Calculate size based on count, scroll direction, and source type
  switch ((count, scrollDirection, source)) {
    // Panel with 2 items arranged horizontally
    case (2, Axis.horizontal, ComputeSource.panel):
      return Size(width * count!, height);

    // Panel with 2 items arranged vertically
    case (2, Axis.vertical, ComputeSource.panel):
      return Size(width, (height + unitSize) * count!);

    // Root container with 2 items arranged horizontally
    case (2, Axis.horizontal, ComputeSource.root):
      return Size(width * count!, height + unitSize * count);

    // Root container with 2 items arranged vertically
    case (2, Axis.vertical, ComputeSource.root):
      return Size(width, (height + unitSize) * count! + unitSize);

    // Default root container size (with extra padding)
    case (_, _, ComputeSource.root):
      return const Size(width, height + unitSize * 2);

    // Default standard size
    default:
      return standardSize;
  }
}
