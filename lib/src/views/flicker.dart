import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/theme/theme.dart';
import 'package:flutter_flicker/src/utils/constants.dart';
import 'package:flutter_flicker/src/views/flicker_month_controller_view.dart';
import 'package:flutter_flicker/src/views/flicker_selection.dart';
import 'package:flutter_flicker/src/views/flicker_date_title.dart';
import 'package:flutter_flicker/src/views/flicker_fade_view.dart';
import 'package:flutter_flicker/src/views/flicker_swipable_month_view.dart';
import 'package:flutter_flicker/src/views/flicker_week_view.dart';
import 'package:flutter_flicker/src/views/flicker_years_view.dart';
import 'package:flutter_flicker/src/views/shared.dart';
import 'flicker_extensions.dart';
export './flicker_selection.dart' show FlickerSelectionMode;

/// View type enumeration
///
/// Defines the different view modes supported by the date picker
enum _FlickerViewType {
  /// Month view - displays a single month's date grid
  month,

  /// Year view - displays a single year's month grid
  year,

  /// Decade view - displays a decade's year grid (currently commented out)
  // decade,
}

/// Custom day cell builder type
///
/// Allows complete customization of individual day cells in the calendar
/// Provides all necessary state information for custom rendering
typedef FlickerDayBuilder =
    Widget Function(
      int index,
      DateTime? date, {
      bool? selected, // Whether this date is selected
      bool? disabled, // Whether this date is disabled
      bool? isInRange, // For range mode, whether date is within selected range
      bool? isRangeStart, // Whether this date is the start of a range
      bool? isRangeEnd, // Whether this date is the end of a range
      bool? isToday, // Whether this date is today's date
    });

/// Flicker Date Picker Widget
///
/// A highly customizable date picker widget that supports multiple selection modes,
/// custom styling, and flexible layouts.
///
/// Features:
/// - Single, range, and multiple date selection
/// - Custom date builders for full UI control
/// - Disabled date support
/// - Theme customization
/// - Horizontal/vertical scrolling
/// - Multi-month display
/// - Internationalization support
class Flicker extends StatefulWidget {
  /// Selection mode - determines how users can select dates
  final FlickerSelectionMode? mode;

  /// Currently selected dates
  final List<DateTime> value;

  /// Minimum selectable date
  final DateTime? startDate;

  /// Maximum selectable date
  final DateTime? endDate;

  /// Callback to determine if a date should be disabled
  final bool Function(DateTime)? disabledDate;

  /// Called when selected dates change
  final Function(List<DateTime>)? onValueChange;

  /// Custom day cell builder for complete UI customization
  final FlickerDayBuilder? dayBuilder;

  /// First day of week configuration
  final FirstDayOfWeek? firstDayOfWeek;

  /// Custom theme configuration
  final FlickTheme? theme;

  /// Number of months to display simultaneously (1 or 2)
  final int? viewCount;

  /// Whether to highlight today's date
  final bool? highlightToday;

  /// Scroll direction - horizontal or vertical
  final Axis? scrollDirection;

  /// Creates a Flicker date picker
  ///
  /// [mode] - The selection mode (single, range, or multiple)
  /// [value] - Initially selected dates
  /// [startDate] - Minimum selectable date (inclusive)
  /// [endDate] - Maximum selectable date (inclusive)
  /// [disabledDate] - Callback to disable specific dates
  /// [onValueChange] - Called when selection changes
  /// [dayBuilder] - Custom widget builder for day cells
  /// [firstDayOfWeek] - Which day appears as first column
  /// [theme] - Custom theme configuration
  /// [viewCount] - Number of months to display (1 or 2)
  /// [highlightToday] - Whether to highlight today's date
  /// [scrollDirection] - Horizontal or vertical scrolling
  const Flicker({
    super.key,
    this.mode = FlickerSelectionMode.single,
    this.value = const [],
    this.startDate,
    this.endDate,
    this.disabledDate,
    this.onValueChange,
    this.dayBuilder,
    this.firstDayOfWeek = FirstDayOfWeek.monday,
    this.theme,
    this.viewCount = 1,
    this.highlightToday,
    this.scrollDirection = Axis.horizontal,
  }) : assert(
         viewCount == null || viewCount == 1 || viewCount == 2,
         'viewCount must be 1 or 2',
       ),
       assert(
         scrollDirection != Axis.vertical || viewCount == 2,
         'When scrollDirection is Axis.vertical, viewCount must be 2',
       );

  @override
  State<Flicker> createState() => _FlickerState();
}

/// State class for the Flicker date picker
///
/// Manages the internal state including selected dates, current view type,
/// display date, and handles all user interactions
class _FlickerState extends State<Flicker> {
  final SwipableController _controller = SwipableController();
  late FlickerModel model;
  late _FlickerViewType _viewType = _FlickerViewType.month;
  late DateTime _display = DateHelpers.maybeToday(null);
  bool _reachEnd(DateTime date) {
    if (widget.endDate == null) return true;
    DateTime endDate = widget.endDate!;
    return DateHelpers.isSameMonth(date, endDate);
  }

  bool _reachStart(DateTime date) {
    if (widget.startDate == null) return false;
    DateTime startDate = widget.startDate!;
    return DateHelpers.isSameMonth(date, startDate);
  }

  bool _canSwipe(DateTime date, SwipeDirection direction) {
    if (widget.startDate == null && widget.endDate == null) return true;
    if (direction == SwipeDirection.backward) return !_reachStart(date);
    if (direction == SwipeDirection.forward) return !_reachEnd(date);
    return true;
  }

  void _syncDisplay() {
    if (model.isEmpty) return;
    _display = model.first!;
  }

  void _onSelectYear(int year) => setState(() {
    _display = _display.copyWith(year: year);
    _viewType = _FlickerViewType.month;
  });
  void _switchToMonthView() =>
      setState(() => _viewType = _FlickerViewType.month);
  void _switchToYearView() => setState(() => _viewType = _FlickerViewType.year);
  void _onViewChange(DateTime date) => setState(() => _display = date);

  @override
  void initState() {
    super.initState();
    model = FlickerModel(
      disabled: widget.disabledDate,
      rebuild: () => setState(() {}),
      sync: (value) => widget.onValueChange?.call(value),
    );
    model.onWidgetUpdate(widget.value, widget.mode);
    _syncDisplay();
  }

  @override
  void didUpdateWidget(covariant Flicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode || oldWidget.value != widget.value) {
      model.onWidgetUpdate(widget.value, widget.mode);
      _syncDisplay();
    }
  }

  Size get _size {
    return Size(
      maxWidth(widget.scrollDirection!, widget.viewCount!),
      maxHeight(widget.scrollDirection!, widget.viewCount!),
    );
  }

  Widget _dayBuilder(BuildContext context, DateTime? date, int index) {
    if (date == null) {
      return widget.dayBuilder != null
          ? widget.dayBuilder!(index, null)
          : SizedBox.shrink();
    }
    final selected = model.isContained(date);
    final isRangeStart = model.inRange(date, 'start');
    final isRangeEnd = model.inRange(date, 'end');
    final isInRange = model.inRange(date, 'default');
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
        onTap: () => model.change(date),
        child: child,
      );
    }

    // Default day cell styling
    bool highlight =
        widget.highlightToday == true &&
        selected == false &&
        model.isToday(date);
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
      onTap: () => model.change(date),
      child: container,
    );
  }

  Widget _swipableBuilder(BuildContext context, DateTime current) {
    List<List<DateTime?>> grids = DateHelpers.generateGrid(
      current,
      context.getFirstDayOfWeek(widget.firstDayOfWeek),
      widget.viewCount!,
    );

    final children = grids.map((data) {
      int index = grids.indexOf(data);
      final cells = data.map(
        (date) => _dayBuilder(context, date, data.indexOf(date)),
      );
      Widget child = FlickerMonthGridView(children: List.from(cells));
      if (widget.scrollDirection == Axis.vertical) {
        if (index == 0) return [FlickerDateTitle(date: (_display)), child];
        if (index == grids.length - 1) {
          final title = DateHelpers.nextMonth(_display);
          return [title, child];
        }
      }
      return [child];
    });
    // .expand((x) => x))
    return Flex(
      direction: widget.scrollDirection!,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.from(children.expand((x) => x)),
    );
  }

  Widget _buildSwipableView() {
    return SizedBox.fromSize(
      size: _size,
      child: FlickerSwipableView(
        startDate: DateHelpers.maybe6monthFromNow(widget.startDate, 1),
        endDate: DateHelpers.maybe6monthFromNow(widget.endDate, -1),
        value: _display,
        scrollDirection: widget.scrollDirection!,
        controller: _controller,
        canSwipe: _canSwipe,
        onViewChange: _onViewChange,
        builder: (context, date) => _swipableBuilder(context, date),
      ),
    );
  }

  Widget _buildSwipableMonthView() {
    return Column(
      children: [
        _buildMonthControllerView(),
        _buildWeekView(),
        _buildSwipableView(),
      ],
    );
  }

  Widget _buildWeekView() {
    return FlickerWeekView.count(
      direction: widget.scrollDirection!,
      viewCount: widget.viewCount!,
      firstDayOfWeek: widget.firstDayOfWeek!,
    );
  }

  Widget _buildMonthControllerView() {
    if (widget.scrollDirection == Axis.vertical) return SizedBox.shrink();
    bool canTap(int step) {
      if (widget.startDate == null && widget.endDate == null) return true;
      if (step == 1) return !_reachEnd(_display);
      if (step == -1) return !_reachStart(_display);
      return true;
    }

    return FlickerMonthControllerView(
      date: _display,
      viewCount: widget.viewCount!,
      onTap: (int count) => _controller.slide(count),
      onTitleTap: _switchToYearView,
      canTap: canTap,
    );
  }

  Widget _buildYearsView() {
    return FlickerYearsView(
      date: _display,
      onSelect: _onSelectYear,
      onTapTitle: _switchToMonthView,
    );
  }

  Widget _buildStack() {
    return Stack(
      children: [
        FlickerFadeView(
          visible: _viewType == _FlickerViewType.month,
          child: _buildSwipableMonthView(),
        ),
        FlickerFadeView(
          visible: _viewType == _FlickerViewType.year,
          child: _buildYearsView(),
        ),
      ],
    );
  }

  Widget _builder(BuildContext context) {
    final theme = context.flickerTheme;
    return Container(
      decoration: theme.decoration,
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: SizedBox(width: _size.width, child: _buildStack()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlickThemeProvider(
      theme: widget.theme?.data,
      child: Builder(builder: (context) => _builder(context)),
    );
  }
}
