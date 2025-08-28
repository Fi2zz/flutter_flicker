import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/views/flicker_month_controller_view.dart';
import 'package:flutter_flicker/src/views/flicker_month_model.dart';
import 'package:flutter_flicker/src/views/flicker_date_title.dart';
import 'package:flutter_flicker/src/views/flicker_swipable_view.dart';
import 'package:flutter_flicker/src/views/flicker_week_view.dart';
import 'package:flutter_flicker/src/views/flicker_shared.dart';
import 'package:flutter_flicker/src/views/date_helpers.dart';
import 'flicker_extensions.dart';

// ============================================================================
// GRID GENERATOR
// ============================================================================

/// Date grid generator
///
/// Manages calendar grid generation logic, including:
/// - Generating date grids based on start and end dates
/// - Caching generation results to avoid redundant calculations
/// - Providing grid query and manipulation methods
class GridGenerator {
  // ========================================
  // Private Fields
  // ========================================

  /// Date grid data
  late List<DateTime> _grid;

  /// Last start date used for generation (for caching optimization)
  DateTime? _lastStartDate;

  /// Last end date used for generation (for caching optimization)
  DateTime? _lastEndDate;

  // ========================================
  // Public Interface
  // ========================================

  /// Get the date grid
  List<DateTime> get grid => _grid;

  // ========================================
  // Grid Generation Methods
  // ========================================

  /// Generate date grid (internal method)
  ///
  /// Uses guard pattern to avoid regenerating identical grids:
  /// - If start and end dates are the same as last time, skip generation
  /// - Otherwise call DateHelpers.generateCalendar to generate new grid
  ///
  /// [startDate] Grid start date
  /// [endDate] Grid end date
  void _generate(DateTime startDate, DateTime endDate) {
    // Guard: skip generation if parameters haven't changed
    if (_lastStartDate != null &&
        _lastEndDate != null &&
        DateHelpers.isSameMonth(_lastStartDate!, startDate) &&
        DateHelpers.isSameMonth(_lastEndDate!, endDate)) {
      return;
    }

    // Generate new grid and update cache
    _grid = DateHelpers.generateCalendar(startDate, endDate);
    _lastStartDate = startDate;
    _lastEndDate = endDate;
  }

  /// Generate grid based on optional start and end dates
  ///
  /// Supports four generation modes:
  /// 1. Both start and end dates provided: use specified range
  /// 2. Only start date provided: 6 months forward from start date
  /// 3. Only end date provided: 6 months backward from end date
  /// 4. Neither provided: centered around current month, 6 months each direction
  ///
  /// [startDate] Optional start date
  /// [endDate] Optional end date
  void generate({DateTime? startDate, DateTime? endDate}) {
    final DateTime start;
    final DateTime end;

    switch ((startDate != null, endDate != null)) {
      case (true, true):
        // Both dates provided
        start = startDate!;
        end = endDate!;
        break;
      case (true, false):
        // Only start date provided
        start = startDate!;
        end = DateTime(startDate.year, startDate.month + 6);
        break;
      case (false, true):
        // Only end date provided
        start = DateTime(endDate!.year, endDate.month - 6);
        end = endDate;
        break;
      case (false, false):
        // Neither provided, use default range
        final now = DateTime.now();
        start = DateTime(now.year, now.month - 6);
        end = DateTime(now.year, now.month + 6);
        break;
    }

    _generate(start, end);
  }

  /// Regenerate grid centered around the specified date
  ///
  /// Generates a grid centered around [centerDate], 6 months in each direction
  ///
  /// [centerDate] Center date
  void from(DateTime centerDate) {
    _generate(
      DateTime(centerDate.year, centerDate.month - 6),
      DateTime(centerDate.year, centerDate.month + 6),
    );
  }

  // ========================================
  // Grid Query Methods
  // ========================================

  /// Find the index of the specified date in the grid
  ///
  /// [date] Date to search for, can be null
  ///
  /// Returns:
  /// - Index when found
  /// - -1 when not found or date is null
  int findIndex(DateTime? date) {
    if (date == null) return -1;
    return _grid.indexWhere((m) => DateHelpers.isSameMonth(m, date));
  }

  /// Get date by index
  ///
  /// [index] Grid index
  ///
  /// Returns:
  /// - Corresponding DateTime when index is valid
  /// - null when index is invalid
  DateTime? at(int index) {
    if (index < 0 || index >= _grid.length) return null;
    return _grid[index];
  }

  /// Check if the specified date exists in the grid
  ///
  /// [date] Date to check
  ///
  /// Returns:
  /// - true: date exists in the grid
  /// - false: date does not exist in the grid
  bool has(DateTime date) {
    return _grid.any((gridDate) => DateHelpers.isSameMonth(gridDate, date));
  }
}

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

  /// Whether to highlight today's date
  final bool? highlightToday;

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
    this.highlightToday,
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
  final SwipeController _controller = SwipeController();

  /// Month view data model
  late FlickerMonthModel _model;

  /// Grid generator
  final GridGenerator _gridGenerator = GridGenerator();

  /// Currently displayed date
  late DateTime _display = _extractDisplay();

  // ========================================
  // Initialization and Lifecycle Methods
  // ========================================

  @override
  void initState() {
    super.initState();

    // Initialize data model
    _model = FlickerMonthModel(
      disabled: widget.disabledDate,
      rebuild: () => setState(() {}),
      sync: (value) => widget.onValueChange?.call(value),
    );

    // Sync component state
    _model.onWidgetUpdate(widget.value, widget.mode);
    _display = _extractDisplay();

    // Initialize grid
    _generateGrid();
  }

  @override
  void didUpdateWidget(covariant FlickerMonthView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if selection mode or value changed
    if (oldWidget.mode != widget.mode || oldWidget.value != widget.value) {
      _model.onWidgetUpdate(widget.value, widget.mode);
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
    _gridGenerator.generate(
      startDate: widget.startDate,
      endDate: widget.endDate,
    );
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
    final date = _gridGenerator.at(index);
    if (date == null) return;

    // Check if date range needs to be expanded
    if (index == 0 || index == _gridGenerator.grid.length - 1) {
      // Use post-frame callback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() {
          _gridGenerator.from(date);
          final has = _gridGenerator.has(date);
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
    final nextDate = _gridGenerator.at(nextIndex);
    return nextDate != null && _canSwipe(nextDate, direction);
  }

  // ========================================
  // Date Cell Building Methods
  // ========================================

  /// Build date cell
  ///
  /// [context] Build context
  /// [date] Date, may be null (empty cell)
  /// [index] Cell index
  ///
  /// Returns built date cell Widget
  Widget _dayBuilder(BuildContext context, DateTime? date, int index) {
    // Handle empty cells
    if (date == null) {
      return widget.dayBuilder != null
          ? widget.dayBuilder!(index, null)
          : SizedBox.shrink();
    }

    // Get date state
    final selected = _model.isContained(date);
    final isRangeStart = _model.inRange(date, 'start');
    final isRangeEnd = _model.inRange(date, 'end');
    final isInRange = _model.inRange(date, 'default');
    final isDisabled = widget.disabledDate?.call(date) == true;

    // Use custom builder if provided
    if (widget.dayBuilder != null) {
      final child = widget.dayBuilder!(
        index,
        date,
        selected: selected,
        disabled: isDisabled,
        isRangeEnd: isRangeEnd,
        isRangeStart: isRangeStart,
        isInRange: isInRange,
      );

      return Tappable(
        tappable: isDisabled == false,
        onTap: () => _model.change(date),
        child: child,
      );
    }

    // Default date cell styling
    bool highlight =
        widget.highlightToday == true &&
        selected == false &&
        _model.isToday(date);

    final theme = context.flickerTheme;
    final decoration = theme.getDayDecoration(
      selected: selected,
      disabled: isDisabled,
      highlight: highlight,
      inRange: isInRange,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
    );

    TextStyle textStyle = theme.getDayTextStyle(
      selected,
      isDisabled,
      highlight,
    );

    final container = Container(
      decoration: decoration,
      alignment: Alignment.center,
      child: Text(date.day.toString(), style: textStyle),
    );

    return Tappable(
      tappable: isDisabled == false,
      onTap: () => _model.change(date),
      child: container,
    );
  }

  // ========================================
  // Swipe View Building Methods
  // ========================================

  /// Build swipe view content
  ///
  /// [context] Build context
  /// [current] Currently displayed date
  ///
  /// Returns built swipe view content
  Widget _swipableBuilder(BuildContext context, DateTime current) {
    // Generate grid data
    List<List<DateTime?>> grids = DateHelpers.generateGrid(
      current,
      context.getFirstDayOfWeek(widget.firstDayOfWeek),
      widget.viewCount,
    );

    // Build grid child components
    final children = grids.map((data) {
      int index = grids.indexOf(data);
      final cells = data.map(
        (date) => _dayBuilder(context, date, data.indexOf(date)),
      );

      Widget child = SizedBox(
        width: gridViewWidth,
        height: gridViewHeight,
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7, // 7 days a week
          childAspectRatio: 1, // Square cells
          children: List.from(cells),
        ),
      );

      // Add date title for vertical scrolling
      if (widget.scrollDirection == Axis.vertical) {
        if (index == 0) return [FlickerDateTitle(date: _display), child];
        if (index == grids.length - 1) {
          final title = DateHelpers.nextMonth(_display);
          return [FlickerDateTitle(date: title), child];
        }
      }
      return [child];
    });

    return Flex(
      direction: widget.scrollDirection,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.from(children.expand((x) => x)),
    );
  }

  // ========================================
  // Component Building Methods
  // ========================================

  /// Build swipe view component
  Widget _buildSwipableView() {
    return SizedBox.fromSize(
      size: widget.size,
      child: SwipableView<DateTime>(
        items: _gridGenerator.grid,
        initialIndex: _gridGenerator.findIndex(_display),
        scrollDirection: widget.scrollDirection,
        controller: _controller,
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
    // Don't show controller for vertical scrolling
    if (widget.scrollDirection == Axis.vertical) return SizedBox.shrink();

    DateTime? startDate = widget.startDate;
    DateTime? endDate = widget.endDate;
    bool noRange = startDate == null && endDate == null;
    bool showTriangle = noRange == false && startDate!.year != endDate!.year;

    return FlickerMonthControllerView(
      date: _display,
      viewCount: widget.viewCount,
      onTap: _controller.slide,
      onTitleTap: () => widget.onShowYearView(_display),
      canTap: _canTap,
      showTriangle: showTriangle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthControllerView(),
        _buildWeekView(),
        _buildSwipableView(),
      ],
    );
  }
}
