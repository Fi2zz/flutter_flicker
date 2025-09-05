import 'package:flutter/widgets.dart';
import 'flicker_tappable.dart';
import 'flicker_extensions.dart';

/// Flicker day cell component
///
/// Responsible for rendering individual date cells, including styles, states and interaction logic
class FlickerDayCell extends StatelessWidget {
  /// Date, may be null (empty cell)
  final DateTime? date;
  
  /// Cell index
  final int index;
  
  /// Whether selected
  final bool selected;
  
  /// Whether disabled
  final bool disabled;
  
  /// Whether in range
  final bool isInRange;
  
  /// Whether range start
  final bool isRangeStart;
  
  /// Whether range end
  final bool isRangeEnd;
  
  /// Whether today
  final bool isToday;
  
  /// Tap callback
  final VoidCallback? onTap;
  
  /// Custom date builder
  final Widget Function(
    int index,
    DateTime? date, {
    bool? selected,
    bool? disabled,
    bool? isInRange,
    bool? isRangeStart,
    bool? isRangeEnd,
    bool? isToday,
  })? customBuilder;

  const FlickerDayCell({
    super.key,
    required this.date,
    required this.index,
    this.selected = false,
    this.disabled = false,
    this.isInRange = false,
    this.isRangeStart = false,
    this.isRangeEnd = false,
    this.isToday = false,
    this.onTap,
    this.customBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Handle empty cells
    if (date == null) {
      return customBuilder != null
          ? customBuilder!(index, null)
          : const SizedBox.shrink();
    }

    // Use custom builder
    if (customBuilder != null) {
      final child = customBuilder!(
        index,
        date,
        selected: selected,
        disabled: disabled,
        isRangeEnd: isRangeEnd,
        isRangeStart: isRangeStart,
        isInRange: isInRange,
        isToday: isToday,
      );

      return Tappable(
        tappable: !disabled,
        onTap: onTap,
        child: child,
      );
    }

    // Default date cell style
    final theme = context.flickerTheme;

    final highlight = !selected && isToday;
    final decoration = theme.getDayDecoration(
      isSelected: selected,
      isDisabled: disabled,
      isHighlighted: highlight,
      isInRange: isInRange,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
    );

    final textStyle = theme.getDayTextStyle(
      isSelected: selected,
      isDisabled: disabled,
      isHighlighted: highlight,
      isInRange: isInRange,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
    );

    final container = Container(
      decoration: decoration,
      alignment: Alignment.center,
      child: Text(date!.day.toString(), style: textStyle),
    );

    return Tappable(
      tappable: !disabled,
      onTap: onTap,
      child: container,
    );
  }
}