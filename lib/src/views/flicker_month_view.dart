import 'package:flutter/widgets.dart';
import 'flicker_month_controller.dart';
import 'flicker_view_title.dart';
import 'flicker_swipable_view.dart';
import 'flicker_week_view.dart';
import 'flicker_month_grid.dart';
import 'flicker_month_controller_view.dart';
import 'date_helpers.dart';
import 'flicker_extensions.dart';

// ============================================================================
// TYPE DEFINITIONS
// ============================================================================

/// Custom day cell builder
///
/// Allows complete customization of individual day cells in the calendar.
/// Provides all necessary state information for custom rendering.
///
/// Parameters:
/// - [index] Cell index in the grid
/// - [date] Cell date, may be null (empty cell)
/// - [selected] Whether this date is selected
/// - [disabled] Whether this date is disabled
/// - [isInRange] In range selection mode, whether this date is within selected range
/// - [isRangeStart] Whether this date is the start of a range
/// - [isRangeEnd] Whether this date is the end of a range
/// - [isToday] Whether this date is today
typedef FlickerDayBuilder =
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

// ============================================================================
// FLICKER MONTH VIEW WIDGET
// ============================================================================

/// Flicker month view component
///
/// A specialized component for displaying date picker month view.
/// Handles month-specific logic, date rendering, and user interactions.
///
/// Main features:
/// - Supports single, multiple, and range selection modes
/// - Customizable date cell appearance
/// - Supports horizontal and vertical scrolling
/// - Supports date range restrictions
/// - Supports disabling specific dates
class FlickerMonthView extends StatefulWidget {
  // ========================================
  // Selection Related Properties
  // ========================================

  /// Selection mode - determines how users can select dates
  final FlickerSelectionMode? mode;

  /// Currently selected date list
  final List<DateTime> value;

  /// Callback when selection changes
  final Function(List<DateTime>)? onValueChange;

  // ========================================
  // Date Range Properties
  // ========================================

  /// Minimum selectable date
  final DateTime? startDate;

  /// Maximum selectable date
  final DateTime? endDate;

  /// Callback to determine if a date should be disabled
  final bool Function(DateTime)? disabledDate;

  // ========================================
  // Custom Rendering Properties
  // ========================================

  /// Custom day cell builder for complete UI customization
  final FlickerDayBuilder? dayBuilder;

  // ========================================
  // Layout Configuration Properties
  // ========================================

  /// First day of week configuration
  final FirstDayOfWeek firstDayOfWeek;

  /// Number of months to display simultaneously (1 or 2)
  final int viewCount;

  /// Scroll direction - horizontal or vertical
  final Axis scrollDirection;

  /// Size of the month view
  final Size size;

  // ========================================
  // Event Callback Properties
  // ========================================

  /// Callback when switching to year view
  final ValueChanged<DateTime> onShowYearView;

  // ========================================
  // Constructor
  // ========================================

  /// Create FlickerMonthView instance
  const FlickerMonthView({
    super.key,
    required this.firstDayOfWeek,
    required this.viewCount,
    required this.scrollDirection,
    required this.size,
    required this.onShowYearView,
    this.mode = FlickerSelectionMode.single,
    this.value = const [],
    this.startDate,
    this.endDate,
    this.disabledDate,
    this.onValueChange,
    this.dayBuilder,
  });

  @override
  State<FlickerMonthView> createState() => FlickerMonthViewState();
}

// ============================================================================
// FLICKER MONTH VIEW STATE
// ============================================================================

class FlickerMonthViewState extends State<FlickerMonthView> {
  // ========================================
  // Private Fields
  // ========================================

  /// Swipe controller
  final SwipeController _swipeController = SwipeController();

  /// Month controller (combines model and grid generator)
  late FlickerMonthController _controller;

  /// Currently displayed date
  late DateTime _display = _extractDisplay();

  // ========================================
  // Initialization and Lifecycle Methods
  // ========================================

  @override
  void initState() {
    super.initState();

    // Initialize month controller
    _controller = FlickerMonthController(
      disabled: widget.disabledDate,
      sync: (value) => widget.onValueChange?.call(value),
    );

    // Sync component state
    _controller.onWidgetUpdate(widget.value, widget.mode);
    _display = _extractDisplay();

    // Initialize grid
    _generateGrid();
  }



 

  @override
  void didUpdateWidget(covariant FlickerMonthView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if selection mode or value changed
    if (oldWidget.mode != widget.mode || oldWidget.value != widget.value) {
      _controller.onWidgetUpdate(widget.value, widget.mode);
      _display = _extractDisplay();
    }

    // Check if date range changed
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _generateGrid();
    }
  }

  // ========================================
  // Display Date Related Methods
  // ========================================

  /// Extract display date from selected values
  ///
  /// Logic:
  /// - If there are selected values: single mode takes last, other modes take first
  /// - If no selected values: use today's date
  DateTime _extractDisplay() {
    final value = widget.value;
    if (value.isNotEmpty) {
      if (widget.mode == FlickerSelectionMode.single) return value.last;
      return value.first;
    }
    return DateHelpers.maybeToday(null);
  }

  /// Update display date
  ///
  /// [date] New display date
  void updateDisplay(DateTime date) => setState(() => _display = date);

  // ========================================
  // Grid Generation Methods
  // ========================================

  /// Generate date grid
  void _generateGrid() {
    _controller.generate(startDate: widget.startDate, endDate: widget.endDate);
  }

  // ========================================
  // Swipe Boundary Check Methods
  // ========================================

  /// Check if date reaches boundary
  ///
  /// [date] Date to check
  /// [direction] Swipe direction
  ///
  /// Returns:
  /// - true: reached boundary, cannot continue swiping
  /// - false: not reached boundary, can continue swiping
  bool _reachBoundary(DateTime date, SwipeDirection direction) {
    final boundaryDate = direction == SwipeDirection.forward
        ? widget.endDate
        : widget.startDate;

    if (boundaryDate == null) {
      // If no boundary date is set, consider forward swipe as reached boundary
      return direction == SwipeDirection.forward;
    }

    final nextMonth = direction == SwipeDirection.forward
        ? DateHelpers.nextMonth(boundaryDate)
        : DateHelpers.prevMonth(boundaryDate);

    return DateHelpers.isSameMonth(date, nextMonth);
  }

  /// Check if can swipe to specified date
  ///
  /// [date] Target date
  /// [direction] Swipe direction
  ///
  /// Returns:
  /// - true: can swipe
  /// - false: cannot swipe (reached boundary)
  bool _canSwipe(DateTime date, SwipeDirection direction) {
    return widget.startDate == null && widget.endDate == null
        ? true
        : !_reachBoundary(date, direction);
  }

  /// Check if controller button can be tapped
  ///
  /// [direction] Swipe direction
  ///
  /// Returns:
  /// - true: can tap
  /// - false: cannot tap
  bool _canTap(SwipeDirection direction) {
    final step = direction == SwipeDirection.backward ? -1 : 1;
    return _canSwipe(DateHelpers.calcMonth(_display, step), direction);
  }

  // ========================================
  // Event Handling Methods
  // ========================================

  /// Handle swipe view index change
  ///
  /// [index] New index
  void _handleIndexChange(int index) {
    final date = _controller.at(index);
    if (date == null) return;

    // Check if date range needs to be expanded
    if (index == 0 || index == _controller.grid.length - 1) {
      // Use post-frame callback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() {
          _controller.from(date);
          final has = _controller.has(date);
          if (has) _display = date;
        }),
      );
      return;
    }

    // Use post-frame callback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() => _display = date),
    );
  }

  /// Handle swipe validation - convert index to DateTime
  ///
  /// [nextIndex] Next index
  /// [direction] Swipe direction
  ///
  /// Returns:
  /// - true: can swipe to this index
  /// - false: cannot swipe to this index
  bool _handleCanSwipe(int nextIndex, SwipeDirection direction) {
    final nextDate = _controller.at(nextIndex);
    return nextDate != null && _canSwipe(nextDate, direction);
  }

  // ========================================
  // Date Cell Building Methods
  // ========================================

  // Note: Original helper methods have been moved to FlickerMonthControllerView component

  // ========================================
  // Swipe View Building Methods
  // ========================================

  // Cache for built grid widgets to avoid rebuilding
  final Map<String, Widget> _gridWidgetCache = {};

  /// Build swipe view content
  ///
  /// [context] Build context
  /// [current] Currently displayed date
  ///
  /// Returns built swipe view content
  Widget _swipableBuilder(BuildContext context, DateTime current) {
    // Generate grid data (now cached in DateHelpers)
    final grids = DateHelpers.generateGrid(
      current,
      context.getFirstDayOfWeek(widget.firstDayOfWeek),
      widget.viewCount,
    );

    // Pre-allocate children list for better performance
    final allChildren = <Widget>[];

    // Build grid child components using FlickerMonthGrid
    for (int gridIndex = 0; gridIndex < grids.length; gridIndex++) {
      final data = grids[gridIndex];

      final child = FlickerMonthGrid(
        gridData: data,
        controller: _controller,
        disabledDate: widget.disabledDate,
        dayBuilder: widget.dayBuilder,
      );

      // Add date title for vertical scrolling
      if (widget.scrollDirection == Axis.vertical) {
        if (gridIndex == 0) {
          allChildren.add(FlickerViewTitle(date: _display));
          allChildren.add(child);
        } else if (gridIndex == grids.length - 1) {
          final title = DateHelpers.nextMonth(_display);
          allChildren.add(FlickerViewTitle(date: title));
          allChildren.add(child);
        } else {
          allChildren.add(child);
        }
      } else {
        allChildren.add(child);
      }
    }

    final result = Flex(
      direction: widget.scrollDirection,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allChildren,
    );

    return result;
  }

  // ========================================
  // Component Building Methods
  // ========================================

  /// Build swipe view component
  Widget _buildSwipableView() {
    return SizedBox.fromSize(
      size: widget.size,
      child: SwipableView<DateTime>(
        items: _controller.grid,
        initialIndex: _controller.findIndex(_display),
        scrollDirection: widget.scrollDirection,
        controller: _swipeController,
        canSwipe: _handleCanSwipe,
        onIndexChange: _handleIndexChange,
        builder: (context, date) => _swipableBuilder(context, date),
      ),
    );
  }

  /// Build week view component
  Widget _buildWeekView() {
    return FlickerWeekView.count(
      direction: widget.scrollDirection,
      viewCount: widget.viewCount,
      firstDayOfWeek: widget.firstDayOfWeek,
    );
  }



  /// Build month controller view component
  Widget _buildMonthControllerView() {
    return FlickerMonthControllerView(
      displayDate: _display,
      viewCount: widget.viewCount,
      scrollDirection: widget.scrollDirection,
      startDate: widget.startDate,
      endDate: widget.endDate,
      canTapLeft: _canTap(SwipeDirection.backward),
      canTapRight: _canTap(SwipeDirection.forward),
      onTapLeft: () => _swipeController.slide(widget.viewCount * -1),
      onTapRight: () => _swipeController.slide(widget.viewCount),
      onShowYearView: widget.onShowYearView,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    // Clear widget cache to prevent memory leaks
    _gridWidgetCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Column(
          children: [
            _buildMonthControllerView(),
            _buildWeekView(),
            _buildSwipableView(),
          ],
        );
      },
    );
  }
}
