import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/views/day_view.dart';
import 'package:flutter_flicker/src/store/grid.dart';
import 'package:flutter_flicker/src/views/header_view.dart';
import 'package:flutter_flicker/src/widgets/views.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_flicker/src/helpers/helpers.dart';
import 'package:flutter_flicker/src/store/context.dart';
import 'package:flutter_flicker/src/store/store.dart';
import 'package:flutter_flicker/src/widgets/swipable_view.dart';
import 'package:flutter_flicker/src/helpers/compute_size.dart';

/// Month View Component
///
/// The primary calendar view that displays a monthly grid of dates with full
/// interaction capabilities. This component serves as the main interface for
/// date selection and navigation within the Flicker date picker.
///
/// ## Key Features
///
/// ### Interactive Calendar Grid
/// - Displays a complete month with proper week alignment
/// - Supports single, range, and multiple date selection modes
/// - Handles date validation and disabled state management
/// - Provides visual feedback for selection states
///
/// ### Navigation & Gestures
/// - Swipe-based month navigation with smooth animations
/// - Boundary detection to prevent invalid navigation
/// - Automatic grid regeneration for infinite scrolling
/// - Integration with header navigation controls
///
/// ### Performance Optimization
/// - Efficient grid management with lazy loading
/// - Optimized rendering for smooth scrolling
/// - Memory-conscious date generation
/// - Reactive updates using signals pattern
///
/// ## Architecture
///
/// The MonthView integrates several key components:
/// - [Grid] for efficient date management and infinite scrolling
/// - [SwipeController] for gesture-based navigation
/// - [HeaderView] for navigation controls and weekday labels
/// - [Store] for state management and selection logic
///
/// ## Layout Structure
///
/// ```
/// MonthView
/// ├── HeaderView (navigation + weekdays)
/// └── SwipableView (calendar grid)
///     └── DayView widgets (individual dates)
/// ```
///
/// ## Usage
///
/// This component is typically used as the main view in the date picker:
/// ```dart
/// MonthView() // Automatically integrates with context
/// ```
class MonthView extends StatefulWidget {
  /// Creates a month view component
  const MonthView({super.key});

  @override
  State<MonthView> createState() => MonthViewState();
}

/// State management for the MonthView component
///
/// Handles the lifecycle of controllers, grid management, and navigation logic.
/// This state class coordinates between swipe gestures, grid updates, and
/// store synchronization to provide a seamless user experience.
class MonthViewState extends State<MonthView> {
  /// Controller for managing swipe-based navigation between months
  final SwipeController _controller = SwipeController();

  /// Grid manager for efficient date generation and infinite scrolling
  final Grid _grid = Grid();

  /// Cleanup resources when the widget is disposed
  @override
  void dispose() {
    _controller.dispose();
    _grid.dispose();
    super.dispose();
  }

  /// Checks if navigation would reach a date boundary
  ///
  /// Determines whether swiping in the given direction would exceed the
  /// configured start or end date limits. This prevents users from navigating
  /// to months that contain no selectable dates.
  ///
  /// [store] The current store instance with date constraints
  /// [date] The target date to check
  /// [direction] The swipe direction (forward/backward)
  ///
  /// Returns true if the navigation would exceed boundaries
  bool _reachBoundary(Store store, DateTime date, SwipeDirection direction) {
    final boundaryDate = direction == SwipeDirection.forward
        ? store.endDate
        : store.startDate;
    if (boundaryDate == null) return direction == SwipeDirection.forward;
    final nextMonth = direction == SwipeDirection.forward
        ? DateHelpers.nextMonth(boundaryDate)
        : DateHelpers.prevMonth(boundaryDate);

    return DateHelpers.isSameMonth(date, nextMonth);
  }

  /// Determines if swiping to a specific index is allowed
  ///
  /// Validates whether navigation to the given grid index would violate
  /// date boundaries. This method is called by the SwipableView to prevent
  /// invalid navigation attempts.
  ///
  /// [store] The current store instance
  /// [nextIndex] The target grid index
  /// [direction] The swipe direction
  ///
  /// Returns true if the swipe is allowed
  bool _canSwipe(Store store, int nextIndex, SwipeDirection direction) {
    final nextDate = _grid.at(nextIndex);
    if (nextDate == null) return false;
    return !_reachBoundary(store, nextDate, direction);
  }

  /// Handles grid index changes during navigation
  ///
  /// Called when the user swipes to a new month. This method updates the
  /// store's display date and triggers grid regeneration when approaching
  /// the boundaries to maintain infinite scrolling.
  ///
  /// [store] The current store instance
  /// [index] The new grid index
  void _onIndexChange(Store store, int index) {
    final date = _grid.at(index);
    if (date == null) return;
    // Regenerate grid when approaching boundaries for infinite scrolling
    if (index == 0 || index == _grid.length - 1) _grid.fromDate(date);
    store.display = date;
  }

  /// Builds a calendar grid for a single month
  ///
  /// Creates a grid of date cells from the provided date data. This method
  /// optimizes performance by pre-allocating the widget list and only building
  /// cells for valid dates.
  ///
  /// [data] List of dates for the month (includes nulls for empty cells)
  /// [store] The current store instance for state access
  ///
  /// Returns a [Widget] containing the formatted calendar grid
  Widget _buildGrid(List<DateTime?> data, Store store) {
    if (kDebugMode) {
      debugPrint('MonthView _buildGrid data.length: ${data.length}');
    }
    // Use List.filled for better performance with known size
    final children = List<Widget>.filled(data.length, const SizedBox.shrink());
    // Build cells only for non-null dates to reduce widget creation
    for (int i = 0; i < data.length; i++) {
      children[i] = _itemBuilder(i, data[i]);
    }
    return StandardView(child: NeverScrollableGridView(children: children));
  }

  /// Builds the complete calendar view for the current display
  ///
  /// This method generates the calendar layout based on the current view
  /// configuration. It handles both single and multiple month displays,
  /// and adapts the layout for vertical or horizontal scrolling.
  ///
  /// [context] The build context
  /// [current] The current display date
  ///
  /// Returns a [Widget] containing the complete calendar layout
  Widget _builder(BuildContext context, DateTime current) {
    final store = Context.storeOf(context);
    final grids = _grid.generateCells(current, store);
    final children = <Widget>[];

    // Build grids for each month in the current view
    for (int gridIndex = 0; gridIndex < grids.length; gridIndex++) {
      final data = grids[gridIndex];
      // Add date title for vertical scrolling
      if (store.isVertical) {
        children.add(TitleView(date: store.displays[gridIndex]));
      }
      children.add(_buildGrid(data, store));
    }

    // Use Flex to support both horizontal and vertical layouts
    return Flex(
      direction: store.scrollDirection,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Builds an individual date cell widget
  ///
  /// Creates a [DayView] for each date in the calendar grid with appropriate
  /// state information. This method handles all selection states including
  /// single selection, range selection, and multiple selection modes.
  ///
  /// The method optimizes performance by caching store values and only
  /// computing necessary state information for each cell.
  ///
  /// [index] The cell index in the grid
  /// [date] The date for this cell (null for empty cells)
  ///
  /// Returns a [DayView] widget with proper state configuration
  Widget _itemBuilder(int index, DateTime? date) =>
      DayView(date: date, index: index);

  /// Builds the complete month view widget
  ///
  /// Creates the main calendar interface combining the header navigation
  /// and the swipable calendar grid. This method uses reactive programming
  /// with the Watch widget to automatically rebuild when relevant signals change.
  ///
  /// The build method:
  /// 1. Initializes the calendar grid with date boundaries
  /// 2. Sets up reactive dependencies for automatic updates
  /// 3. Combines HeaderView and SwipableView in a column layout
  /// 4. Configures swipe behavior and navigation callbacks
  ///
  /// Returns a [Widget] containing the complete month view interface
  @override
  Widget build(BuildContext context) {
    final store = Context.storeOf(context);
    // Initialize the calendar grid with the configured date range
    _grid.generateCalendar(store.startDate!, store.endDate!);

    // Use Watch for reactive updates when signals change
    return Watch(
      (context) {
        return Column(
          children: [
            // Header with navigation controls and weekday labels
            HeaderView(controller: _controller),
            // Main calendar grid with swipe navigation
            ComputedView(
              source: ComputeSource.panel,
              child: SwipableView<DateTime>(
                items: _grid.items,
                initialIndex: _grid.findIndex(store.display),
                scrollDirection: store.scrollDirection,
                controller: _controller,
                canSwipe: (index, dir) => _canSwipe(store, index, dir),
                onIndexChange: (index) => _onIndexChange(store, index),
                builder: _builder,
              ),
            ),
          ],
        );
      },
      // Define reactive dependencies for automatic rebuilds
      dependencies: [
        store.viewCountSignal,
        store.firstDayOfWeekSignal,
        store.scrollDirectionSignal,
        store.startDateSignal,
        store.endDateSignal,
        store.displaySignal,
      ],
    );
  }
}
