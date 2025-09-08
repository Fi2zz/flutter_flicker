import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/views/flicker_controller.dart';
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

/// View type enumeration
///
/// Defines the different view modes supported by the date picker
enum ViewType {
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
    this.scrollDirection = Axis.horizontal,
  });

  @override
  State<Flicker> createState() => _FlickerState();
}

/// State class for the Flicker date picker
///
/// Manages the internal state including selected dates, current view type,
/// display date, and handles all user interactions
class _FlickerState extends State<Flicker> {
  late FlickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlickerController();
    _controller.initialize(
      startDate: widget.startDate,
      endDate: widget.endDate,
      viewCount: widget.viewCount,
      scrollDirection: widget.scrollDirection,
    );
  }

  @override
  void didUpdateWidget(covariant Flicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if any parameters that affect the controller have changed
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.viewCount != widget.viewCount ||
        oldWidget.scrollDirection != widget.scrollDirection) {
      _controller.initialize(
        startDate: widget.startDate,
        endDate: widget.endDate,
        viewCount: widget.viewCount,
        scrollDirection: widget.scrollDirection,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMonthView() {
    return FlickerMonthView(
      value: widget.value,
      mode: widget.mode,
      startDate: _controller.startDate,
      endDate: _controller.endDate,
      disabledDate: widget.disabledDate,
      dayBuilder: widget.dayBuilder,
      scrollDirection: _controller.scrollDirection,
      viewCount: _controller.viewCount,
      firstDayOfWeek: widget.firstDayOfWeek!,
      size: _controller.size,
      onValueChange: widget.onValueChange,
      onShowYearView: _controller.showYearView,
    );
  }

  Widget _buildYearsView() {
    if (_controller.viewType != ViewType.year) return SizedBox.shrink();

    Widget yearView = FlickerYearsView(
      value: _controller.display.year,
      onTapYear: _controller.selectYear,
      startYear: _controller.startYear,
      endYear: _controller.endYear,
      itemHeight: baseSize,
    );
    Widget title = BaseBox(
      child: FlickerViewTitle(
        date: _controller.display,
        onTap: _controller.showMonthView,
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
          visible: _controller.viewType == ViewType.month,
          child: _buildMonthView(),
        ),
        FlickerFadeView(
          visible: _controller.viewType == ViewType.year,
          child: _buildYearsView(),
        ),
      ],
    );
  }

  Widget _builder(BuildContext context) {
    return Container(
      decoration: context.flickerTheme.decoration,
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: SizedBox(width: _controller.size.width, child: _buildStack()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlickThemeProvider(
      theme: widget.theme?.data,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) => _builder(context),
      ),
    );
  }
}
