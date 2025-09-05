import 'package:flutter/widgets.dart';
import '../theme/theme.dart';
import 'flicker_view_title.dart';
import 'flicker_month_view.dart';
import 'flicker_month_controller.dart';
import 'flicker_fade_view.dart';
import 'flicker_years_view.dart';
import 'flicker_extensions.dart';
import 'flicker_size_helper.dart';
export 'flicker_month_controller.dart' show FlickerSelectionMode;
export './flicker_month_view.dart' show FlickerDayBuilder;
import 'date_helpers.dart';

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

  /// [scrollDirection] - Horizontal or vertical scrolling
  Flicker({
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
    int? viewCount = 1,

    Axis? scrollDirection = Axis.horizontal,
  }) : viewCount = _normalizeViewCount(viewCount, scrollDirection),
       scrollDirection = scrollDirection ?? Axis.horizontal;

  /// Normalize viewCount based on scrollDirection
  static int _normalizeViewCount(int? viewCount, Axis? scrollDirection) {
    // If scrollDirection is vertical, viewCount must be 2
    if (scrollDirection == Axis.vertical) {
      return 2;
    }
    // If viewCount is not 1 or 2, convert to 1
    if (viewCount != 1 && viewCount != 2) {
      return 1;
    }
    return viewCount ?? 1;
  }

  @override
  State<Flicker> createState() => _FlickerState();
}

/// State class for the Flicker date picker
///
/// Manages the internal state including selected dates, current view type,
/// display date, and handles all user interactions
class _FlickerState extends State<Flicker> {
  late _FlickerViewType _viewType = _FlickerViewType.month;
  late DateTime _display = DateHelpers.maybeToday(null);
  late GlobalKey<FlickerMonthViewState> _monthViewKey = GlobalKey();

  int get _startYear {
    int start = DateHelpers.maybe100yearsAgo(widget.startDate).year;
    return (_endYear - start == 1) ? start - 1 : start;
  }

  int get _endYear {
    return DateHelpers.maybe100yearsAfter(widget.endDate).year;
  }

  @override
  void didUpdateWidget(covariant Flicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    //  update month view key
    if (oldWidget.mode != widget.mode ||
        oldWidget.viewCount != widget.viewCount ||
        oldWidget.scrollDirection != widget.scrollDirection) {
      _monthViewKey = GlobalKey();
    }
  }

  void _onSelectYear(int year) => setState(() {
    _display = _display.copyWith(year: year);
    _viewType = _FlickerViewType.month;
    _monthViewKey.currentState?.updateDisplay(_display);
  });
  void _showMonthView() => setState(() => _viewType = _FlickerViewType.month);
  void _showYearView(DateTime date) => setState(() {
    _display = date;
    _viewType = _FlickerViewType.year;
  });
  Size get _size => computeSize(widget.viewCount!, widget.scrollDirection!);
  Widget _buildSwipableMonthView() {
    return FlickerMonthView(
      key: _monthViewKey,
      value: widget.value,
      mode: widget.mode,
      startDate: widget.startDate,
      endDate: widget.endDate,
      disabledDate: widget.disabledDate,
      dayBuilder: widget.dayBuilder,
      scrollDirection: widget.scrollDirection!,
      viewCount: widget.viewCount!,
      firstDayOfWeek: widget.firstDayOfWeek!,
      size: _size,
      onValueChange: widget.onValueChange,
      onShowYearView: _showYearView,
    );
  }

  Widget _buildYearsView() {
    if (_viewType != _FlickerViewType.year) return SizedBox.shrink();

    Widget yearView = FlickerYearsView(
      value: _display.year,
      onTapYear: _onSelectYear,
      startYear: _startYear,
      endYear: _endYear,
      itemHeight: baseSize,
    );
    Widget title = BaseBox(
      child: FlickerViewTitle(
        date: _display,
        onTap: _showMonthView,
        roate: true,
        showTriangle: true,
      ),
    );
    return Column(children: [title, yearView]);
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
    return Container(
      decoration: context.flickerTheme.decoration,
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
