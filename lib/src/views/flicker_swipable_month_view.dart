import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/views/generic_swipable_view.dart';
import 'package:flutter_flicker/src/utils/constants.dart';
export './generic_swipable_view.dart' show SwipeDirection;

/// Date range selection data class
///
/// Represents a range of dates with start and end dates
class DateTimeRange {
  /// Start date of the range
  final DateTime start;

  /// End date of the range
  final DateTime end;
  const DateTimeRange({required this.start, required this.end});
}

/// Swipable view builder type definition
///
/// - [context]: Build context
/// - [item]: Date item for the view
typedef SwipableViewBuilder =
    Widget Function(BuildContext context, DateTime current);

/// Date swipe callback function type
///
/// Called when a swipe gesture is detected
/// - [direction]: The direction of the swipe
typedef DateSwipeCallback = void Function(SwipeDirection direction);

/// Date swipe validation callback function type
///
/// Called before a swipe gesture is executed to determine if the swipe is allowed
/// - [nextDate]: The target date that would be navigated to
/// - [direction]: The direction of the swipe
/// Returns true if the swipe should be allowed, false otherwise
typedef DateSwipeValidationCallback =
    bool Function(DateTime nextDate, SwipeDirection direction);

/// Date swipable view controller
///
/// Extends the generic swipable controller, specifically for date view control.
/// Provides the same API as the original SwipableController for backward compatibility.
class SwipableController extends GenericSwipableController {
  // Maintain the same API as the original SwipableController
}

/// Create a 13-month date range centered on the specified date
///
/// By default, creates a range from 6 months before [start] to 6 months after, totaling 13 months.
/// If the [end] parameter is provided, the specified end date is used.
///
/// - [start]: Start date
/// - [end]: End date (optional), defaults to 6 months after start if not provided
///
/// Returns a [DateTimeRange] object containing the 13-month range.
DateTimeRange range13(DateTime start, [DateTime? end]) {
  end = end ?? DateTime(start.year, start.month + 6);
  start = DateTime(start.year, start.month - 6);
  return DateTimeRange(start: start, end: end);
}

/// Create a valid date range from an optional DateTimeRange
///
/// If [range] is null, returns a 13-month range centered on the current date.
/// This is a backward-compatible helper function.
///
/// - [range]: Optional date range
///
/// Returns a valid [DateTimeRange] object.
DateTimeRange fromDateTimeRange(DateTimeRange? range) {
  return range ?? range13(DateTime.now());
}

/// Create DateTimeRange from start and end dates
///
/// Intelligently creates date range based on provided parameters:
/// - If both [startDate] and [endDate] are provided: directly create range
/// - If only [startDate] is provided: end date is set to 6 months after start date
/// - If only [endDate] is provided: start date is set to 6 months before end date
/// - If neither is provided: use default range of 6 months before and after current date
///
/// - [startDate]: Start date (optional)
/// - [endDate]: End date (optional)
///
/// Returns a [DateTimeRange] object created based on the parameters.
DateTimeRange fromStartEndDates(DateTime? startDate, DateTime? endDate) {
  if (startDate != null && endDate != null) {
    return DateTimeRange(start: startDate, end: endDate);
  } else if (startDate != null) {
    return DateTimeRange(
      start: startDate,
      end: DateTime(startDate.year, startDate.month + 6),
    );
  } else if (endDate != null) {
    return DateTimeRange(
      start: DateTime(endDate.year, endDate.month - 6),
      end: endDate,
    );
  } else {
    return range13(DateTime.now());
  }
}

/// Swipable date view component
///
/// Supports horizontal and vertical swiping, provides custom date range and disabled date functionality.
/// Based on the generic GenericSwipableView implementation, specifically handles date-related logic.
///
/// ## Usage Examples
///
/// ### Basic Usage
/// ```dart
/// SwipableView(
///   value: DateTime.now(),
///   onViewChange: (date) => print('Current month: $date'),
///   builder: (context, date) => MonthGridView(
///     month: date.month,
///     year: date.year,
///     // ... other parameters
///   ),
/// )
/// ```
///
/// ### Specify Date Range
/// ```dart
/// SwipableView(
///   startDate: DateTime(2023, 1, 1),  // Start date
///   endDate: DateTime(2024, 12, 31),  // End date
///   value: DateTime.now(),
///   onViewChange: (date) => setState(() => currentDate = date),
///   builder: (context, date) => YourCustomWidget(date),
/// )
/// ```
///
/// ### Using External Controller
/// ```dart
/// final controller = SwipableController();
///
/// SwipableView(
///   controller: controller,
///   value: DateTime.now(),
///   onViewChange: (date) => print(date),
///   builder: (context, date) => YourWidget(date),
/// )
///
/// // Programmatic swipe control
/// controller.slide(1);  // Next page
/// controller.slide(-1); // Previous page
/// ```
///
/// ### Using Swipe Callbacks
/// ```dart
/// SwipableView(
///   value: DateTime.now(),
///   onViewChange: (date) => print('Month changed: $date'),
///   onSwipe: (direction) {
///     print('Swiped: $direction');
///   },
///   canSwipe: (nextDate, direction) {
///     // Allow swipe only if next month is not in the future
///     if (direction == SwipeDirection.forward) {
///       return nextDate.isBefore(DateTime.now().add(Duration(days: 30)));
///     }
///     return true; // Always allow backward swipe
///   },
///   builder: (context, date) => YourWidget(date),
/// )
/// ```
class FlickerSwipableView extends StatefulWidget {
  /// Start date of the swipable view
  ///
  /// If null, will be automatically set to 6 months before the current date.
  /// If only [startDate] is provided without [endDate],
  /// then [endDate] will be automatically set to 6 months after [startDate].
  final DateTime? startDate;

  /// End date of the swipable view
  ///
  /// If null, will be automatically set to 6 months after the current date.
  /// If only [endDate] is provided without [startDate],
  /// then [startDate] will be automatically set to 6 months before [endDate].
  final DateTime? endDate;

  /// External controller for programmatic swipe control
  ///
  /// Page switching can be controlled through the [SwipableController.slide] method.
  /// For example: controller.slide(1) switches to next page, controller.slide(-1) switches to previous page.
  final SwipableController? controller;

  /// Currently displayed month
  ///
  /// This value determines the initially displayed month and must be within the [startDate] and [endDate] range.
  final DateTime value;

  /// Optional date disable function
  ///
  /// Returns true if the date is disabled, false if available.
  /// Disabled dates will prevent swiping to that month.
  final bool Function(DateTime)? disabledDate;

  /// Month change callback function
  ///
  /// This function is called when the user swipes to switch months, passing in the new month date.
  final void Function(DateTime) onViewChange;

  /// Custom builder function
  ///
  /// Used to build the view content for each month, receiving the current month's DateTime object.
  final SwipableViewBuilder builder;

  /// Swipe direction
  ///
  /// [Axis.horizontal] indicates horizontal swiping (default), [Axis.vertical] indicates vertical swiping.
  final Axis scrollDirection;

  /// Swipe gesture callback
  ///
  /// Called when a swipe gesture is detected, passing the swipe direction.
  final DateSwipeCallback? onSwipe;

  /// Swipe validation callback
  ///
  /// Called before executing a swipe to determine if the swipe is allowed.
  /// Receives the target date and swipe direction, returns true to allow or false to prevent.
  final DateSwipeValidationCallback? canSwipe;

  /// Create a swipable month view
  ///
  /// ## Parameter Description
  /// - [startDate]: Start date of the view range (optional)
  /// - [endDate]: End date of the view range (optional)
  /// - [value]: Currently displayed month (required)
  /// - [onViewChange]: Month change callback (required)
  /// - [builder]: Custom builder (required)
  /// - [disabledDate]: Date disable function (optional)
  /// - [controller]: External controller (optional)
  /// - [scrollDirection]: Swipe direction (default horizontal)
  /// - [onSwipe]: Swipe gesture callback (optional)
  /// - [canSwipe]: Swipe validation callback (optional)
  const FlickerSwipableView({
    super.key,
    this.startDate,
    this.endDate,
    required this.value,
    required this.onViewChange,
    required this.builder,
    this.disabledDate,
    this.controller,
    this.scrollDirection = Axis.horizontal,
    this.onSwipe,
    this.canSwipe,
  });

  @override
  State<FlickerSwipableView> createState() => _FlickerSwipableViewState();
}

class _FlickerSwipableViewState extends State<FlickerSwipableView> {
  late List<DateTime> _grid;
  late DateTimeRange _range;
  late DateTime _current;
  int _currentIndex = 0;

  /// Generate date grid
  void _generateDateGrid(DateTimeRange? range) {
    _range = fromDateTimeRange(range);
    _grid = DateHelpers.generateCalendar(_range.start, _range.end);
  }

  /// Find the index of the specified date in the grid
  int _findDateIndex(DateTime? date) {
    if (date == null) return -1;
    return _grid.indexWhere((m) => DateHelpers.isSameMonth(m, date));
  }

  /// Get initial index
  int _getInitialIndex() {
    int initialIndex = _findDateIndex(widget.value);
    if (initialIndex == -1) {
      // If current value is not in range, regenerate range containing this value
      _generateDateGrid(range13(widget.value));
      initialIndex = _findDateIndex(widget.value);
    }
    return initialIndex.clamp(0, _grid.length - 1);
  }

  /// Handle index change
  void _handleIndexChange(int index) {
    if (index >= 0 && index < _grid.length) {
      final newDate = _grid[index];

      // Check if date range needs to be expanded
      if (index == 0 || index == _grid.length - 1) {
        // Use post-frame callback to avoid calling setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _expandDateRange(newDate);
        });
        return;
      }

      // Use post-frame callback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _current = newDate;
          _currentIndex = index;
        });
        widget.onViewChange(newDate);
      });
    }
  }

  /// Expand date range
  void _expandDateRange(DateTime centerDate) {
    setState(() {
      _generateDateGrid(range13(centerDate));
      final newIndex = _findDateIndex(centerDate);
      _currentIndex = newIndex.clamp(0, _grid.length - 1);
      _current = _grid[_currentIndex];
    });
    widget.onViewChange(_current);
  }

  @override
  void initState() {
    super.initState();
    final range = fromStartEndDates(widget.startDate, widget.endDate);
    _generateDateGrid(range);
    _currentIndex = _getInitialIndex();
    _current = DateHelpers.maybeToday(widget.value);
  }

  @override
  void didUpdateWidget(FlickerSwipableView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if value has changed
    if (_current != widget.value) {
      final targetIndex = _findDateIndex(widget.value);
      if (targetIndex != -1) {
        // value is within current range
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _currentIndex = targetIndex;
            _current = widget.value;
          });
        });
      } else {
        // value is outside current range, regenerate range
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _expandDateRange(widget.value);
        });
      }
    }

    // Check if date range has changed
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          final range = fromStartEndDates(widget.startDate, widget.endDate);
          _generateDateGrid(range);
          _currentIndex = _getInitialIndex();
        });
      });
    }
  }

  /// Handle swipe callback - convert index to DateTime
  void _handleSwipe(SwipeDirection direction) {
    widget.onSwipe?.call(direction);
  }

  /// Handle swipe validation - convert index to DateTime
  bool _handleCanSwipe(int nextIndex, SwipeDirection direction) {
    if (widget.canSwipe == null) return true;
    if (nextIndex < 0 || nextIndex >= _grid.length) return false;
    final nextDate = _grid[nextIndex];
    return widget.canSwipe!(nextDate, direction);
  }

  @override
  Widget build(BuildContext context) {
    if (_grid.isEmpty) return const SizedBox.shrink();
    return GenericSwipableView<DateTime>(
      items: _grid,
      initialIndex: _currentIndex,
      controller: widget.controller,
      scrollDirection: widget.scrollDirection,
      onIndexChange: _handleIndexChange,
      onSwipe: widget.onSwipe != null ? _handleSwipe : null,
      canSwipe: widget.canSwipe != null ? _handleCanSwipe : null,
      builder: widget.builder,
    );
  }
}

class FlickerMonthGridView extends StatelessWidget {
  final List<Widget> children;
  const FlickerMonthGridView({super.key, required this.children});
  @override
  Widget build(BuildContext context) {
    final child = GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1,
      children: children,
    );
    return SizedBox.fromSize(size: monthSize, child: child);
  }
}
