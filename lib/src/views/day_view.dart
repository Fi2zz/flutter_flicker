import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/store/context.dart';
import 'package:flutter_flicker/src/widgets/views.dart';
import 'package:flutter_flicker/src/store/store.dart';
import 'package:flutter_flicker/src/helpers/helpers.dart';

/// Type definition for custom day cell builders
///
/// This function type allows users to completely customize the appearance
/// of individual day cells in the calendar. The builder receives context
/// about the date and its state, and should return a widget to display.
///
/// ## Parameters
/// - [index]: Position in the grid (0-41 for a 6-week month view)
/// - [date]: The date being rendered (null for empty cells)
/// - [selected]: Whether this date is currently selected
/// - [disabled]: Whether this date is disabled for selection
/// - [isInRange]: Whether this date is within a selected range
/// - [isRangeStart]: Whether this date is the start of a range
/// - [isRangeEnd]: Whether this date is the end of a range
/// - [isToday]: Whether this date is today
typedef DayBuilder =
    Widget Function(
      int index,
      DateTime? date, {
      bool? selected,
      bool? disabled,
      bool? isInRange,
      bool? isRangeStart,
      bool? isRangeEnd,
      bool? isToday,
    });

/// A cell view widget that renders individual date cells in the calendar
///
/// This widget is responsible for displaying a single date cell with all
/// its associated states (selected, disabled, in range, etc.). It handles
/// the visual appearance, interaction, and state management for each date.
///
/// ## Features
/// - **State-aware rendering**: Handles selected, disabled, range, and today states
/// - **Custom builders**: Supports custom day builders for complete customization
/// - **Theme integration**: Applies appropriate styles based on date state
/// - **Interactive**: Handles tap events for date selection
///
/// ## Usage
/// ```dart
/// DayView(
///   index: 15,
///   date: DateTime(2024, 1, 15),
///   selected: true,
///   isToday: false,
///   onTap: () => selectDate(date),
/// )
/// ```
class DayView extends StatelessWidget {
  /// The date this cell represents (null for empty cells)
  final DateTime? date;

  /// The index position of this cell in the grid (0-41 for 6-week view)
  final int index;

  /// Creates a cell view
  ///
  /// The [date] and [index] parameters are required. All state parameters
  /// default to false, and [onTap] is optional.
  const DayView({
    super.key,
    required this.date,
    required this.index,
    // this.selected = false,
    // this.isInRange = false,
    // this.isRangeStart = false,
    // this.isRangeEnd = false,
    // this.isToday = false,
  });

  /// Builds the cell with appropriate styling and interaction
  ///
  /// Determines the cell's state, applies the appropriate theme styling,
  /// and handles tap interactions. If a custom dayBuilder is available
  /// in the store, delegates rendering to it.
  @override
  Widget build(BuildContext context) {
    final store = Context.storeOf(context);

    final builder = store.dayBuilder;

    // Handle empty cells (null dates)
    if (date == null) {
      return builder != null ? builder(index, null) : const SizedBox.shrink();
    }
    onTap() => store.onSelectDate(date!);
    // Cache store values to reduce repeated lookups
    final isRange = store.mode == SelectionMode.range;
    final selected = store.selection.any(date!);
    final isInRange = isRange && store.selection.between(date!);
    bool notEmpty = store.selection.isNotEmpty;

    // Determine range start and end positions for visual styling
    DateTime? first = notEmpty ? store.selection.first : null;
    DateTime? last = notEmpty ? store.selection.last : null;
    final isRangeStart =
        isRange && notEmpty && DateHelpers.isSameDay(first!, date!);
    final isRangeEnd =
        isRange && notEmpty && DateHelpers.isSameDay(last!, date!);
    final isToday = DateHelpers.isToday(date!);

    // Check if this date is disabled
    bool disabled = store.disabledDate(date!);
    Widget child = const SizedBox.shrink();

    // Use custom builder if available
    if (builder != null) {
      child = builder(
        index,
        date,
        selected: selected,
        disabled: disabled,
        isRangeEnd: isRangeEnd,
        isRangeStart: isRangeStart,
        isInRange: isInRange,
        isToday: isToday,
      );
    } else {
      final theme = Context.themeOf(context);
      // Determine if this date should be highlighted (today but not selected)
      final highlight = !selected && isToday;

      // Get appropriate decoration based on state
      final decoration = theme.getDayDecoration(
        isSelected: selected,
        isDisabled: disabled,
        isHighlighted: highlight,
        isInRange: isInRange,
        isRangeStart: isRangeStart,
        isRangeEnd: isRangeEnd,
      );

      // Get appropriate text style based on state
      final textStyle = theme.getDayTextStyle(
        isSelected: selected,
        isDisabled: disabled,
        isHighlighted: highlight,
        isInRange: isInRange,
        isRangeStart: isRangeStart,
        isRangeEnd: isRangeEnd,
      );

      // Build the cell container with styling
      final container = Container(
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(date!.day.toString(), style: textStyle),
      );
      child = container;
    }
    // Wrap in tappable widget for interaction
    return Tappable(tappable: !disabled, onTap: onTap, child: child);
  }
}
