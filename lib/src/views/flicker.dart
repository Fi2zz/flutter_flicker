import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/l10n/i10n.dart';
import 'package:flutter_flicker/src/store/store.dart' show FirstDayOfWeek;
import 'package:flutter_flicker/src/store/store.dart' show FlickerProps;
import 'package:flutter_flicker/src/store/store.dart' show SelectionMode;
import 'package:flutter_flicker/src/theme/theme.dart';

import 'core.dart' show Core;
import 'day_view.dart' show DayBuilder;

// Export core types for external use
export 'package:flutter_flicker/src/store/store.dart' show FirstDayOfWeek;
export 'package:flutter_flicker/src/store/store.dart' show SelectionMode;

export 'day_view.dart' show DayBuilder;

/// Flicker Date Picker Widget
///
/// A highly customizable and performant date picker widget that supports multiple
/// selection modes, custom styling, and flexible layouts.
///
/// ## Features
///
/// ### Selection Modes
/// - **Single**: Select one date at a time
/// - **Range**: Select a continuous date range
/// - **Multiple**: Select multiple individual dates
///
/// ### Customization
/// - Custom day cell builders for complete UI control
/// - Comprehensive theme system with light/dark modes
/// - Disabled date support with validation callbacks
/// - Flexible layout options (horizontal/vertical scrolling)
/// - Multi-month display (1 or 2 months simultaneously)
///
/// ### Internationalization
/// - Locale-aware date formatting
/// - Configurable first day of week
///
/// ## Example Usage
///
/// ### Basic Single Date Selection
/// ```dart
/// Flicker(
///   mode: SelectionMode.single,
///   value: [DateTime.now()],
///   onValueChange: (dates) {
///     print('Selected date: ${dates.first}');
///   },
/// )
/// ```
///
/// ### Date Range Selection with Constraints
/// ```dart
/// Flicker(
///   mode: SelectionMode.range,
///   startDate: DateTime.now(),
///   endDate: DateTime.now().add(Duration(days: 365)),
///   disabledDate: (date) => date.weekday == DateTime.sunday,
///   onValueChange: (dates) {
///     if (dates.length == 2) {
///       print('Range: ${dates.first} to ${dates.last}');
///     }
///   },
/// )
/// ```
///
/// ### Custom Themed Multi-Month View
/// ```dart
/// Flicker(
///   mode: SelectionMode.multiple,
///   theme: FlickerTheme.dark(),
///   viewCount: 2,
///   scrollDirection: Axis.vertical,
///   firstDayOfWeek: FirstDayOfWeek.monday,
/// )
/// ```
class Flicker extends StatelessWidget {
  /// Callback function to determine if a specific date should be disabled
  ///
  /// This function is called for each date in the calendar view. Return `true`
  /// to disable the date (making it non-selectable), or `false` to allow selection.
  ///
  /// Example:
  /// ```dart
  /// disabledDate: (date) {
  ///   // Disable weekends
  ///   return date.weekday == DateTime.saturday ||
  ///          date.weekday == DateTime.sunday;
  /// }
  /// ```
  final bool Function(DateTime)? disabledDate;

  /// Callback invoked when the selected dates change
  ///
  /// The callback receives a list of selected dates. The list contents depend
  /// on the selection mode:
  /// - **Single mode**: List contains 0 or 1 date
  /// - **Range mode**: List contains 0, 1, or 2 dates (start and end)
  /// - **Multiple mode**: List contains 0 or more dates
  ///
  /// Example:
  /// ```dart
  /// onValueChange: (selectedDates) {
  ///   setState(() {
  ///     _selectedDates = selectedDates;
  ///   });
  /// }
  /// ```
  final Function(List<DateTime>)? onValueChange;

  final int? selectionCount;

  /// Selection mode that determines how users can interact with dates
  ///
  /// Available modes:
  /// - [SelectionMode.single]: Select one date at a time
  /// - [SelectionMode.range]: Select a continuous date range
  /// - [SelectionMode.many]: Select multiple individual dates
  ///
  /// Defaults to [SelectionMode.single] if not specified.
  final SelectionMode? mode;

  /// List of currently selected dates
  ///
  /// The interpretation of this list depends on the selection mode:
  /// - **Single mode**: Should contain at most one date
  /// - **Range mode**: Should contain 0, 1, or 2 dates representing range bounds
  /// - **Multiple mode**: Can contain any number of dates
  ///
  /// Defaults to an empty list if not specified.
  final List<DateTime> value;

  /// Minimum selectable date (inclusive)
  ///
  /// Dates before this date will be disabled and non-selectable.
  /// If null, there is no minimum date constraint.
  ///
  /// Example:
  /// ```dart
  /// startDate: DateTime.now(), // Only allow future dates
  /// ```
  final DateTime? startDate;

  /// Maximum selectable date (inclusive)
  ///
  /// Dates after this date will be disabled and non-selectable.
  /// If null, there is no maximum date constraint.
  ///
  /// Example:
  /// ```dart
  /// endDate: DateTime.now().add(Duration(days: 365)), // One year limit
  /// ```
  final DateTime? endDate;

  /// Custom day cell builder for complete UI customization
  ///
  /// This builder allows you to completely customize the appearance and behavior
  /// of individual day cells. If provided, it overrides the default day cell
  /// rendering.
  ///
  /// The builder receives context about the date being rendered and should
  /// return a widget to display for that day.
  ///
  /// Example:
  /// ```dart
  /// dayBuilder: (context, date, isSelected, isDisabled) {
  ///   return Container(
  ///     decoration: BoxDecoration(
  ///       color: isSelected ? Colors.blue : Colors.transparent,
  ///       shape: BoxShape.circle,
  ///     ),
  ///     child: Text('${date.day}'),
  ///   );
  /// }
  /// ```
  final DayBuilder? dayBuilder;

  /// Configuration for which day appears as the first column
  ///
  /// Options:
  /// - [FirstDayOfWeek.monday]: Week starts on Monday
  /// - [FirstDayOfWeek.sunday]: Week starts on Sunday
  /// - [FirstDayOfWeek.saturday]: Week starts on Saturday
  /// - [FirstDayOfWeek.locale]: Use system locale setting
  ///
  /// Defaults to [FirstDayOfWeek.monday] if not specified.
  final FirstDayOfWeek? firstDayOfWeek;

  /// Custom theme configuration for styling the date picker
  ///
  /// If provided, this theme will override the default theme. You can use
  /// predefined themes like [FlickerTheme.light()] and [FlickerTheme.dark()],
  /// or create a completely custom theme.
  ///
  /// If null, the widget will use the default theme or inherit from the
  /// nearest [FlickerTheme] widget in the widget tree.
  final FlickerTheme? theme;

  /// Number of months to display simultaneously
  ///
  /// Supported values:
  /// - `1`: Single month view (default)
  /// - `2`: Two months side by side
  ///
  /// When set to 2, the layout adapts based on [scrollDirection]:
  /// - Horizontal: Months appear side by side
  /// - Vertical: Months appear stacked vertically
  final int? viewCount;

  /// Scroll direction for navigating between months
  ///
  /// Options:
  /// - [Axis.horizontal]: Swipe left/right to change months (default)
  /// - [Axis.vertical]: Swipe up/down to change months
  ///
  /// This affects both single and multi-month views.
  final Axis? scrollDirection;

  /// Creates a Flicker date picker widget
  ///
  /// All parameters are optional and have sensible defaults:
  /// - [mode]: Selection behavior (defaults to single selection)
  /// - [value]: Initially selected dates (defaults to empty)
  /// - [startDate]: Minimum selectable date (defaults to no limit)
  /// - [endDate]: Maximum selectable date (defaults to no limit)
  /// - [disabledDate]: Custom date validation (defaults to no restrictions)
  /// - [onValueChange]: Selection change callback (defaults to no action)
  /// - [dayBuilder]: Custom day cell builder (defaults to built-in styling)
  /// - [firstDayOfWeek]: Week start day (defaults to Monday)
  /// - [theme]: Custom theme (defaults to system theme)
  /// - [viewCount]: Number of months shown (defaults to 1)
  /// - [scrollDirection]: Navigation direction (defaults to horizontal)
  ///
  /// ## Example
  /// ```dart
  /// Flicker(
  ///   mode: SelectionMode.range,
  ///   value: [DateTime.now()],
  ///   startDate: DateTime.now(),
  ///   endDate: DateTime.now().add(Duration(days: 365)),
  ///   onValueChange: (dates) => print('Selected: $dates'),
  ///   theme: FlickerTheme.dark(),
  ///   viewCount: 2,
  ///   scrollDirection: Axis.vertical,
  /// )
  /// ```
  const Flicker({
    super.key,
    this.mode = SelectionMode.single,
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
    this.selectionCount,
  });

  /// Converts the [FirstDayOfWeek] enum to an integer value
  ///
  /// This method handles the conversion from the enum to the integer values
  /// expected by the underlying calendar implementation:
  /// - 0: Sunday
  /// - 1: Monday
  /// - 6: Saturday
  /// - Locale-specific: Uses system locale settings
  ///
  /// [context] is used to access localization data when [FirstDayOfWeek.locale]
  /// is specified.
  int _getFirstDayOfWeek(BuildContext context) {
    return switch (firstDayOfWeek) {
      FirstDayOfWeek.monday => 1,
      FirstDayOfWeek.saturday => 6,
      FirstDayOfWeek.locale => FlickerL10n.of(context).firstDayOfWeek,
      FirstDayOfWeek.sunday => 0,
      null => 0, // Default to Sunday if null
    };
  }

  /// Builds the Flicker date picker widget
  ///
  /// This method constructs the complete date picker by:
  /// 1. Converting widget properties into a [FlickerProps] configuration object
  /// 2. Resolving the first day of week based on locale if needed
  /// 3. Delegating to the [Core] widget for actual rendering
  ///
  /// The build process ensures all user-provided configuration is properly
  /// formatted and passed to the underlying calendar implementation.
  ///
  /// Returns a [Widget] representing the complete date picker interface
  @override
  Widget build(BuildContext context) {
    // Create props object with all configuration
    FlickerProps props = FlickerProps(
      mode: mode, // Selection behavior (single, range, multiple)
      value: value, // Currently selected dates
      startDate: startDate, // Minimum selectable date
      endDate: endDate, // Maximum selectable date
      viewCount: viewCount, // Number of months to display
      scrollDirection: scrollDirection, // Navigation direction
      firstDayOfWeek: _getFirstDayOfWeek(context), // Week start day (localized)
      disabledDate: disabledDate, // Custom date validation function
      selectionCount: selectionCount, //  selection count
      onValueChange: onValueChange, // Selection change callback
      dayBuilder: dayBuilder, // Custom day cell builder
    );

    // Build the actual calendar widget using FlickerBuilder
    return Core(props: props, theme: theme);
  }
}
