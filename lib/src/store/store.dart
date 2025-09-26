import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/views/day_view.dart' show DayBuilder;
import 'package:flutter_flicker/src/helpers/helpers.dart';
import 'selection.dart';
import 'package:signals/signals_flutter.dart';

/// Defines the first day of the week for calendar display
///
/// This enum provides options for configuring which day should appear
/// as the first column in the calendar grid.
enum FirstDayOfWeek {
  /// Sunday as the first day of the week
  sunday,

  /// Monday as the first day of the week
  monday,

  /// Saturday as the first day of the week
  saturday,

  /// Use the locale's default first day of the week
  locale,
}

/// Immutable configuration object for Flicker date picker properties
///
/// This class encapsulates all the configuration options that can be passed
/// to the Flicker date picker widget. It provides a clean interface for
/// customizing the behavior, appearance, and functionality of the calendar.
///
/// Key features:
/// - Immutable design for predictable state management
/// - Comprehensive configuration options
/// - Built-in equality and hash code implementation
/// - Support for various selection modes and customizations
@immutable
class FlickerProps {
  /// The selection mode for the date picker (single, range, or multiple)
  final SelectionMode? mode;

  /// Maximum number of dates that can be selected (used with 'many' mode)
  final int? selectionCount;

  /// Function to determine if a specific date should be disabled
  final bool Function(DateTime date)? disabledDate;

  /// List of initially selected dates
  final List<DateTime> value;

  /// The earliest selectable date (null for no restriction)
  final DateTime? startDate;

  /// The latest selectable date (null for no restriction)
  final DateTime? endDate;

  /// First day of the week (0 = Sunday, 1 = Monday, etc.)
  final int? firstDayOfWeek;

  /// Number of calendar views to display (1 or 2)
  final int? viewCount;

  /// Scroll direction for the calendar (horizontal or vertical)
  final Axis? scrollDirection;

  /// Callback function called when the selection changes
  final Function(List<DateTime>)? onValueChange;

  /// Custom builder function for rendering individual day cells
  final DayBuilder? dayBuilder;

  /// Creates a new FlickerProps configuration object
  ///
  /// All parameters are optional and have sensible defaults.
  /// The [value] parameter defaults to an empty list if not provided.
  const FlickerProps({
    this.mode,
    this.value = const [],
    this.startDate,
    this.endDate,
    this.firstDayOfWeek,
    this.viewCount,
    this.scrollDirection,
    this.disabledDate,
    this.onValueChange,
    this.dayBuilder,
    this.selectionCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FlickerProps &&
        other.mode == mode &&
        other.value == value &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.firstDayOfWeek == firstDayOfWeek &&
        other.viewCount == viewCount &&
        other.firstDayOfWeek == firstDayOfWeek &&
        other.disabledDate == disabledDate &&
        other.onValueChange == onValueChange &&
        other.selectionCount == selectionCount &&
        other.scrollDirection == scrollDirection;
  }

  /// Generates a hash code for this FlickerProps instance
  ///
  /// Uses Object.hash to combine all property values into a single
  /// hash code for efficient equality comparisons and collection usage.
  @override
  int get hashCode => Object.hash(
    mode,
    value,
    startDate,
    endDate,
    firstDayOfWeek,
    viewCount,
    scrollDirection,
    firstDayOfWeek,
    disabledDate,
    onValueChange,
    selectionCount,
  );
}

/// Defines the current view type of the calendar
///
/// This enum determines whether the calendar is showing a detailed
/// month view with individual days or a year overview for navigation.
enum ViewType {
  /// Detailed month view showing individual days
  month,

  /// Year overview for quick navigation between months
  year,
}

/// Defines the selection behavior of the date picker
///
/// This enum controls how users can select dates and how many
/// dates can be selected simultaneously.
enum SelectionMode {
  /// Allow selection of only one date at a time
  single,

  /// Allow selection of a date range (start and end date)
  range,

  /// Allow selection of multiple individual dates
  many,
}

/// Tracks the source of selection changes for proper event handling
///
/// This enum helps distinguish between different types of changes
/// to ensure appropriate responses and state updates.
enum ChangeSource {
  /// Change triggered by year selection in year view
  selectYear,

  /// Change triggered by date selection in month view
  selectDate,

  /// Change triggered during initial setup/configuration
  initialize,
}

/// Central state management store for the Flicker date picker
///
/// This class manages all the state and business logic for the date picker,
/// using reactive signals for efficient UI updates. It handles selection
/// logic, view management, date validation, and configuration updates.
///
/// Key responsibilities:
/// - Managing selected dates and selection modes
/// - Handling view state (month/year view, display dates)
/// - Validating date selections and disabled dates
/// - Coordinating between different components
/// - Providing reactive state updates through signals
class Store {
  /// Callback function for notifying external components of selection changes
  late Function(List<DateTime>)? onValueChange = (_) {};

  /// Tracks the source of the most recent change for proper event handling
  ChangeSource changeSource = ChangeSource.initialize;

  /// Reactive signal for the maximum number of selectable dates
  final Signal<int> selectionCountSignal = signal(1);

  /// Gets the current selection count limit
  int get selectionCount => selectionCountSignal.value;

  /// Custom day builder function for rendering individual calendar cells
  late DayBuilder? dayBuilder;

  /// Reactive signal for the current selection mode
  final Signal<SelectionMode> modeSignal = signal(SelectionMode.single);

  /// Gets the current selection mode (single, range, or many)
  SelectionMode get mode => modeSignal.value;

  /// Reactive signal for the earliest selectable date
  final Signal<DateTime?> startDateSignal = signal(null);

  /// Reactive signal for the latest selectable date
  final Signal<DateTime?> endDateSignal = signal(null);

  /// Reactive signal for the first day of the week configuration
  final Signal<int> firstDayOfWeekSignal = signal(0);

  /// Reactive signal for the number of calendar views to display
  final Signal<int?> viewCountSignal = signal(1);

  /// Reactive signal for the scroll direction of the calendar
  final Signal<Axis?> scrollDirectionSignal = signal(Axis.horizontal);

  /// Reactive signal for the current view type (month or year)
  final Signal<ViewType> viewTypeSignal = signal(ViewType.month);

  /// Reactive signal for the currently displayed month/year
  final Signal<DateTime> displaySignal = signal(DateHelpers.maybeToday(null));

  /// Reactive signal for the current date selection state
  final Signal<Selection> selectionSignal = signal(Selection());

  /// Gets the earliest selectable date
  DateTime? get startDate => startDateSignal.value;

  /// Gets the latest selectable date
  DateTime? get endDate => endDateSignal.value;

  /// Gets the first day of the week (0 = Sunday, 1 = Monday, etc.)
  int get firstDayOfWeek => firstDayOfWeekSignal.value;

  /// Gets the scroll direction, defaulting to horizontal if not set
  Axis get scrollDirection => scrollDirectionSignal.value ?? Axis.horizontal;

  /// Whether the calendar scrolls horizontally
  bool get isHorizontal => scrollDirection == Axis.horizontal;

  /// Whether the calendar scrolls vertically
  bool get isVertical => scrollDirection == Axis.vertical;

  /// Whether the calendar displays two views side by side
  bool get isDoubleViews => viewCount == 2;

  /// Whether the calendar displays a single view
  bool get isSingleView => viewCount == 1;

  int get viewCount {
    if (isYearsView) return 1;
    if (scrollDirection == Axis.vertical) return 2;
    int viewCount = viewCountSignal.value ?? 1;
    if (viewCount != 1 && viewCount != 2) return 1;
    return viewCount;
  }

  Selection get selection => selectionSignal.value;

  DateTime get display => displaySignal.value;
  DateTime get nextDisplay => DateHelpers.nextMonth(display);
  List<DateTime> get displays => [display, nextDisplay];

  set display(DateTime value) => displaySignal.value = value;

  bool get isMonthView => viewTypeSignal.value == ViewType.month;

  bool get isYearsView => viewTypeSignal.value == ViewType.year;

  int get startYear {
    int start = DateHelpers.maybe100yearsAgo(startDateSignal.value).year;
    return (endYear - start == 1) ? start - 1 : start;
  }

  int get endYear => DateHelpers.maybe100yearsAfter(endDateSignal.value).year;

  /// Function to determine if a specific date should be disabled
  late bool Function(DateTime date) disabledDate = (date) => false;

  /// Initializes the store with the provided configuration properties
  ///
  /// This method sets up all the reactive signals and state based on the
  /// FlickerProps configuration. It validates the configuration and applies
  /// appropriate defaults where necessary.
  ///
  /// Parameters:
  /// - [props]: The configuration object containing all date picker settings
  void initialize(FlickerProps props) {
    _updateChangeSource(props);

    _updateMode(props.mode);
    _updateDisabledDate(props.disabledDate);
    _updateSelectionCount(props.selectionCount);
    _updateDateRange(props);
    _updateSelection(props.value);
    _updateFirstDayOfWeek(props.firstDayOfWeek);
    _updateViewCount(props.viewCount);
    _updateScrollDirection(props.scrollDirection);
    onValueChange = props.onValueChange;
    dayBuilder = props.dayBuilder;
  }

  /// Updates the change source based on configuration differences
  ///
  /// This method determines if the current configuration differs from the
  /// previous one and sets the change source to 'initialize' if changes
  /// are detected. This helps track whether changes are from user interaction
  /// or configuration updates.
  ///
  /// Parameters:
  /// - [props]: The new configuration to compare against current state
  void _updateChangeSource(FlickerProps props) {
    if (modeSignal.value != props.mode ||
        firstDayOfWeekSignal.value != props.firstDayOfWeek ||
        selectionCount != props.selectionCount ||
        startDate != props.startDate ||
        endDate != props.endDate ||
        firstDayOfWeek != props.firstDayOfWeek ||
        viewCount != props.viewCount ||
        scrollDirection != props.scrollDirection) {
      changeSource = ChangeSource.initialize;
    }
  }

  /// Updates the selection count based on the current selection mode
  ///
  /// This method validates and sets the appropriate selection count for each
  /// selection mode. It provides debug warnings when invalid counts are provided
  /// and automatically corrects them to maintain consistency.
  ///
  /// Selection count rules:
  /// - Single mode: Always 1
  /// - Range mode: Always 2 (start and end dates)
  /// - Many mode: User-defined (defaults to 1 if null)
  ///
  /// Parameters:
  /// - [selectionCount]: The desired maximum number of selectable dates
  void _updateSelectionCount(int? selectionCount) {
    switch (mode) {
      case SelectionMode.many:
        if (selectionCount == null && kDebugMode) {
          debugPrint(
            '''selectionCount cannot be null for many selection mode, auto set to 1''',
          );
        }
        selectionCountSignal.value = selectionCount ?? 1;
        break;
      case SelectionMode.single:
        if (selectionCount != 1 && kDebugMode) {
          debugPrint(
            '''selectionCount must be 1 for single selection mode  which now is $selectionCount, auto set to 1''',
          );
        }
        selectionCountSignal.value = 1;
        break;
      case SelectionMode.range:
        if (selectionCount != 2 && kDebugMode) {
          debugPrint(
            '''selectionCount must be 2 for range selection mode, auto set to 2''',
          );
        }
        selectionCountSignal.value = selectionCount ?? 2;
        break;
    }
  }

  /// Updates the disabled date validation function
  ///
  /// This method sets the function used to determine if a specific date
  /// should be disabled in the calendar. If no function is provided,
  /// it defaults to allowing all dates.
  ///
  /// Parameters:
  /// - [disabledDate]: Function that returns true if a date should be disabled
  void _updateDisabledDate(bool Function(DateTime date)? disabledDate) {
    this.disabledDate = disabledDate ?? (date) => false;
  }

  /// Updates the scroll direction for the calendar
  ///
  /// This method sets the scroll direction for the calendar views.
  /// Defaults to horizontal scrolling if not specified.
  ///
  /// Parameters:
  /// - [scrollDirection]: The desired scroll direction (horizontal or vertical)
  void _updateScrollDirection(Axis? scrollDirection) {
    scrollDirectionSignal.value = scrollDirection ?? Axis.horizontal;
  }

  /// Updates the selectable date range for the calendar
  ///
  /// This method validates and sets the start and end date boundaries for
  /// the calendar. It ensures that the start date is not after the end date
  /// and provides default ranges if not specified.
  ///
  /// Default behavior:
  /// - Start date: 3 years before today if not provided
  /// - End date: 3 years after today if not provided
  /// - Updates display to start date if selection is empty
  ///
  /// Parameters:
  /// - [props]: Configuration object containing startDate and endDate
  ///
  /// Throws:
  /// - [ArgumentError]: If startDate is after endDate
  void _updateDateRange(FlickerProps props) {
    DateTime? startDate = props.startDate;
    DateTime? endDate = props.endDate;

    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        throw ArgumentError(
          'startDate ($startDate) must be before or equal to endDate ($endDate)',
        );
      }
    }
    startDateSignal.value = startDate ?? DateHelpers.offsetToday(startDate, -3);
    endDateSignal.value = endDate ?? DateHelpers.offsetToday(endDate, 3);
    if (kDebugMode) {
      debugPrint('dateRange: $startDate - $endDate');
    }
    if (changeSource == ChangeSource.initialize && startDate != null) {
      _updateDisplay(startDate);
    }
  }

  /// Updates the current selection with the provided dates
  ///
  /// This method initializes the selection state during configuration.
  /// It validates the selection count against the current limit and
  /// updates the display to show the first selected date.
  ///
  /// Behavior:
  /// - Only processes during initialization phase
  /// - Truncates selection if it exceeds the selection count limit
  /// - Updates display to first selected date if selection is not empty
  /// - Provides debug output for the first selected date
  ///
  /// Parameters:
  /// - [value]: List of initially selected dates
  void _updateSelection(List<DateTime> value) {
    if (changeSource == ChangeSource.initialize) {
      selectionSignal.value.selection = [];
      if (value.length > selectionCount) {
        value = value.sublist(0, selectionCount);
      }
      selectionSignal.value.force(value);
      _initializeDisplay();
    }
  }

  void _initializeDisplay() {
    if (kDebugMode) {
      debugPrint('_initializeDisplay selection.first: ${selection.first}');
      debugPrint('_initializeDisplay startDate: $startDate');
    }

    if (selection.isEmpty && startDate == null) {
      return;
    }
    DateTime? display = selection.first;
    if (DateHelpers.before(display, startDate)) display = startDate!;
    if (display == null) return;
    _updateDisplay(display);
  }

  /// Updates the first day of the week configuration
  ///
  /// This method sets which day should appear as the first column
  /// in the calendar grid. Defaults to Sunday (0) if not specified.
  ///
  /// Day values:
  /// - 0: Sunday
  /// - 1: Monday
  /// - 2: Tuesday
  /// - ... and so on
  ///
  /// Parameters:
  /// - [firstDayOfWeek]: The day of week to use as the first day (0-6)
  void _updateFirstDayOfWeek(int? firstDayOfWeek) {
    firstDayOfWeekSignal.value = firstDayOfWeek ?? 0;
  }

  /// Updates the selection mode for the date picker
  ///
  /// This method sets how users can select dates in the calendar.
  /// Defaults to single selection mode if not specified.
  ///
  /// Parameters:
  /// - [mode]: The desired selection mode (single, range, or many)
  void _updateMode(SelectionMode? mode) {
    modeSignal.value = mode ?? SelectionMode.single;
  }

  /// Updates the number of calendar views to display
  ///
  /// This method sets how many calendar views should be shown simultaneously.
  /// Only supports 1 or 2 views and validates the input accordingly.
  ///
  /// Parameters:
  /// - [viewCount]: Number of views to display (1 or 2)
  ///
  /// Throws:
  /// - [ArgumentError]: If viewCount is not 1 or 2
  void _updateViewCount(int? viewCount) {
    if (viewCount != null && ![1, 2].contains(viewCount)) {
      throw ArgumentError('viewCount must be 1 or 2, got $viewCount');
    }
    viewCountSignal.value = viewCount;
  }

  /// Toggles between month view and year view
  ///
  /// This method switches the calendar display between detailed month view
  /// (showing individual days) and year overview (for quick navigation).
  void onSwtichView() {
    viewTypeSignal.value = viewTypeSignal.value == ViewType.month
        ? ViewType.year
        : ViewType.month;
  }

  /// Handles year selection from the year view
  ///
  /// This method processes year selection, switches back to month view,
  /// and updates the display if the year has changed. It also resets
  /// the current selection and notifies listeners of the change.
  ///
  /// Parameters:
  /// - [year]: The selected year to navigate to
  void selectYear(int year) {
    viewTypeSignal.value = ViewType.month;

    if (display.year == year) return;
    selectionSignal.value.reset();
    _notifyChanged(ChangeSource.selectYear);
    _updateDisplay(displaySignal.value.copyWith(year: year));
  }

  /// Updates the currently displayed month/year
  ///
  /// This is an internal method used to change which month and year
  /// is currently being displayed in the calendar view.
  ///
  /// Parameters:
  /// - [date]: The date representing the month/year to display
  void _updateDisplay(DateTime date) =>
      displaySignal.value = DateTime(date.year, date.month, date.day);

  /// Handles date selection from the calendar
  ///
  /// This method processes user date selections based on the current selection mode.
  /// It handles toggling (deselecting already selected dates), validates selection
  /// limits, checks for disabled dates in ranges, and maintains proper sorting.
  ///
  /// Behavior by selection mode:
  /// - Single: Replaces current selection with new date
  /// - Range: Builds start-end date pairs, validates no disabled dates in between
  /// - Many: Adds dates up to the selection count limit
  ///
  /// Features:
  /// - Toggle selection (click selected date to deselect)
  /// - Automatic selection reset when limits exceeded
  /// - Disabled date validation for range selections
  /// - Automatic sorting for multi-date selections
  /// - Display update to show first selected date
  ///
  /// Parameters:
  /// - [date]: The date that was selected by the user
  void onSelectDate(DateTime date) {
    if (kDebugMode) {
      debugPrint('onSelectDate: $date');
    }
    if (selection.any((d) => DateHelpers.isSameDay(d, date))) {
      selection.drop(date);
    } else {
      if (selection.length + 1 > selectionCount ||
          hasDisabledDatesInRange(date)) {
        selection.reset();
      }
      selection.push(date);
    }
    if (mode != SelectionMode.single) selection.sort();
    _notifyChanged(ChangeSource.selectDate);
    if (selection.isNotEmpty) _updateDisplay(selection.first!);
  }

  /// Checks if there are any disabled dates in a potential date range
  ///
  /// This method validates whether a range selection would include any
  /// disabled dates. It's specifically used for range selection mode
  /// to prevent users from selecting ranges that span disabled dates.
  ///
  /// Validation logic:
  /// - Only applies to range selection mode
  /// - Requires exactly one date already selected
  /// - Checks every date between the existing selection and target date
  /// - Returns true if any date in the range is disabled
  ///
  /// Parameters:
  /// - [targetDate]: The date being considered for selection
  ///
  /// Returns:
  /// - true if the range would include disabled dates
  /// - false if the range is valid or validation doesn't apply
  bool hasDisabledDatesInRange(DateTime targetDate) {
    if (selection.length <= 0) return false;

    if (selection.length != 1 || mode != SelectionMode.range) {
      return false;
    }
    DateTime start = selection.first!;
    final startDate = start.isBefore(targetDate) ? start : targetDate;
    final endDate = start.isBefore(targetDate) ? targetDate : start;
    DateTime current = startDate;
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (disabledDate(current)) {
        return true;
      }
      current = current.add(const Duration(days: 1));
    }
    return false;
  }

  /// Notifies external listeners of selection changes
  ///
  /// This method calls the onValueChange callback with the current selection
  /// and updates the change source to track what triggered the change.
  ///
  /// Parameters:
  /// - [source]: The source of the change (selectYear, selectDate, initialize)
  void _notifyChanged(ChangeSource source) {
    onValueChange?.call(selection.take());
    changeSource = source;
  }

  /// Disposes of all reactive signals to prevent memory leaks
  ///
  /// This method should be called when the store is no longer needed
  /// to properly clean up all signal subscriptions and prevent memory leaks.
  /// It disposes of all the reactive signals used by the store.
  void dispose() {
    viewTypeSignal.dispose();
    displaySignal.dispose();
    modeSignal.dispose();
    startDateSignal.dispose();
    endDateSignal.dispose();
    firstDayOfWeekSignal.dispose();
    viewCountSignal.dispose();
    scrollDirectionSignal.dispose();
    selectionSignal.dispose();
  }

  /// Gets all reactive signals that components can depend on
  ///
  /// This getter provides a list of all the reactive signals in the store
  /// that UI components might want to listen to for rebuilds. It's useful
  /// for setting up comprehensive reactive dependencies.
  ///
  /// Returns:
  /// - List of all reactive signals in the store
  List<ReadonlySignal<dynamic>> get dependencies => [
    viewTypeSignal,
    displaySignal,
    modeSignal,
    startDateSignal,
    endDateSignal,
    firstDayOfWeekSignal,
    viewCountSignal,
    scrollDirectionSignal,
    selectionSignal,
  ];
}
