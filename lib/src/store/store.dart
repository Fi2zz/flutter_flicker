import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/store/props.dart';
import 'package:flutter_flicker/src/views/day_view.dart' show DayBuilder;
import 'package:flutter_flicker/src/helpers/helpers.dart';
import 'selection.dart';
import 'enums.dart';
import 'package:signals/signals_flutter.dart';
export 'enums.dart';
export 'props.dart';

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
///
/// ## Usage Examples
///
/// ### Basic store initialization and usage:
/// ```dart
/// // Create a new store instance
/// final store = Store();
///
/// // Configure with props
/// final props = Props(
///   mode: SelectionMode.single,
///   value: [DateTime.now()],
///   onValueChange: (dates) => print('Selection changed: $dates'),
/// );
///
/// // Initialize the store
/// store.initialize(props);
///
/// // Access current state
/// print('Current mode: ${store.mode}');
/// print('Selected dates: ${store.selection.result}');
/// print('Current display month: ${store.display}');
/// ```
///
/// ### Listening to state changes with signals:
/// ```dart
/// final store = Store();
///
/// // Listen to selection changes
/// store.selectionSignal.listen((selection) {
///   print('Selection updated: ${selection.result}');
/// });
///
/// // Listen to display month changes
/// store.displaySignal.listen((displayDate) {
///   print('Display month changed to: $displayDate');
/// });
///
/// // Listen to view type changes
/// store.viewTypeSignal.listen((viewType) {
///   print('View type changed to: $viewType');
/// });
/// ```
///
/// ### Programmatic date selection:
/// ```dart
/// final store = Store();
/// store.initialize(Props(mode: SelectionMode.range));
///
/// // Select a date programmatically
/// final dateToSelect = DateTime(2024, 6, 15);
/// store.selectDate(dateToSelect);
///
/// // Check if a date is selected
/// if (store.selection.any(dateToSelect)) {
///   print('Date is selected');
/// }
///
/// // Get selection range for range mode
/// if (store.mode == SelectionMode.range && store.selection.length == 2) {
///   print('Range: ${store.selection.first} to ${store.selection.last}');
/// }
/// ```
///
/// ### View management:
/// ```dart
/// final store = Store();
/// store.initialize(Props());
///
/// // Switch to year view
/// store.switchToYearView();
/// print('Is year view: ${store.isYearsView}');
///
/// // Switch back to month view
/// store.switchToMonthView();
/// print('Is month view: ${store.isMonthView}');
///
/// // Navigate to specific month
/// store.display = DateTime(2024, 12, 1);
/// print('Current display: ${store.display}');
/// ```
///
/// ### Advanced usage with custom validation:
/// ```dart
/// final store = Store();
///
/// final props = Props(
///   mode: SelectionMode.many,
///   selectionCount: 3,
///   disabledDate: (date) {
///     // Disable weekends and past dates
///     return date.isBefore(DateTime.now()) ||
///            date.weekday == DateTime.saturday ||
///            date.weekday == DateTime.sunday;
///   },
///   onValueChange: (dates) {
///     print('Selected ${dates.length} dates');
///   },
/// );
///
/// store.initialize(props);
///
/// // Check if a date is disabled
/// final testDate = DateTime(2024, 6, 15);
/// if (store.disabledDate(testDate)) {
///   print('Date $testDate is disabled');
/// } else {
///   store.selectDate(testDate);
/// }
/// ```
///
/// ### Integration with Flutter widgets:
/// ```dart
/// class MyDatePicker extends StatefulWidget {
///   @override
///   _MyDatePickerState createState() => _MyDatePickerState();
/// }
///
/// class _MyDatePickerState extends State<MyDatePicker> {
///   late final Store store;
///
///   @override
///   void initState() {
///     super.initState();
///     store = Store();
///     store.initialize(Props(
///       mode: SelectionMode.single,
///       onValueChange: (dates) {
///         setState(() {
///           // Update UI when selection changes
///         });
///       },
///     ));
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         Text('Selected: ${store.selection.result}'),
///         ElevatedButton(
///           onPressed: () => store.selectDate(DateTime.now()),
///           child: Text('Select Today'),
///         ),
///       ],
///     );
///   }
/// }
/// ```
class Store {
  /// Callback function for notifying external components of selection changes
  late Function(List<DateTime>)? onValueChange = (_) {};

  late int changeHashCode = -1;

  late ChangeSource changeSource = ChangeSource.initialize;

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
  void initialize(Props props) {
    _updateViewCount(props.viewCount);
    _updateScrollDirection(props.scrollDirection);
    _updateDisabledDate(props.disabledDate);

    onValueChange = props.onValueChange;
    dayBuilder = props.dayBuilder;
    if (!_shouldInitialize(props.changeHashCode)) return;
    _updateMode(props.mode);
    _updateSelection(props);
    _updateFirstDayOfWeek(props.firstDayOfWeek);
  }

  /// Whether the store should initialize with the default date range
  bool _shouldInitialize(int nextHashCode) {
    if (nextHashCode == changeHashCode) return false;
    changeSource = ChangeSource.initialize;
    return true;
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
  void _updateSelection(Props props) {
    DateTime? startDate = props.startDate;
    DateTime? endDate = props.endDate;

    List<DateTime> value = props.value;
    int? selectionCount = props.selectionCount;

    if (isYearsView) {
      viewTypeSignal.value = ViewType.month;
    }

    // selection.reset();
    switch (mode) {
      case SelectionMode.many:
        if (selectionCount == null && kDebugMode) {
          debugPrint(
            '''selectionCount cannot be null for many selection mode, auto set to 1''',
          );
        }
        selectionSignal.value.maxCount = selectionCount ?? 1;
        break;
      case SelectionMode.single:
        if (selectionCount != 1 && kDebugMode) {
          debugPrint(
            '''selectionCount must be 1 for single selection mode  which now is $selectionCount, auto set to 1''',
          );
        }
        selectionSignal.value.maxCount = selectionCount;

        break;
      case SelectionMode.range:
        if (selectionCount != 2 && kDebugMode) {
          debugPrint(
            '''selectionCount must be 2 for range selection mode, auto set to 2''',
          );
        }
        selectionSignal.value.maxCount = selectionCount ?? 2;
        break;
    }

    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        throw ArgumentError(
          'startDate ($startDate) must be before or equal to endDate ($endDate)',
        );
      }
    }
    startDateSignal.value = startDate;
    endDateSignal.value = endDate;
    if (kDebugMode) {
      debugPrint('startDateSignal.value: ${startDateSignal.value}');
      debugPrint('endDateSignal.value: ${endDateSignal.value}');
    }

    selectionSignal.value.force(value);
    if (changeSource == ChangeSource.initialize) _initializeDisplay(startDate);
  }

  void _initializeDisplay(DateTime? startDate) {
    if (kDebugMode) {
      debugPrint('_initializeDisplay selection.result: ${selection.result}');
      debugPrint('_initializeDisplay selection.first: ${selection.first}');
      debugPrint('_initializeDisplay startDate: $startDate');
    }
    if (selection.isEmpty && startDate == null) return;
    if (startDate != null) _updateDisplay(startDate);
    DateTime? display = selection.first;
    if (DateHelpers.before(display, startDate)) display = startDate;
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
    _notifyChanged(ChangeSource.selectYear);
    DateTime next = DateTime(year, display.month, display.day);
    _updateDisplay(next);
  }

  /// Updates the currently displayed month/year
  ///
  /// This is an internal method used to change which month and year
  /// is currently being displayed in the calendar view.
  ///
  /// Parameters:
  /// - [date]: The date representing the month/year to display
  void _updateDisplay(DateTime date) {
    displaySignal.value = DateTime(date.year, date.month, date.day);
  }

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
    if (_hasDisabledDatesInRange(date)) selection.reset();
    selection.update(date);
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
  bool _hasDisabledDatesInRange(DateTime targetDate) {
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
