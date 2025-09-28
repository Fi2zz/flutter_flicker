import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/store/enums.dart';
import 'package:flutter_flicker/src/views/day_view.dart' show DayBuilder;

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
///
/// ## Usage Examples
///
/// ### Basic single date selection:
/// ```dart
/// final props = Props(
///   mode: SelectionMode.single,
///   value: [DateTime.now()],
///   onValueChange: (dates) {
///     print('Selected date: ${dates.first}');
///   },
/// );
/// ```
///
/// ### Date range selection with restrictions:
/// ```dart
/// final props = Props(
///   mode: SelectionMode.range,
///   startDate: DateTime(2024, 1, 1),
///   endDate: DateTime(2024, 12, 31),
///   disabledDate: (date) {
///     // Disable weekends
///     return date.weekday == DateTime.saturday ||
///            date.weekday == DateTime.sunday;
///   },
///   onValueChange: (dates) {
///     if (dates.length == 2) {
///       print('Range: ${dates.first} to ${dates.last}');
///     }
///   },
/// );
/// ```
///
/// ### Multiple date selection with custom day builder:
/// ```dart
/// final props = Props(
///   mode: SelectionMode.many,
///   selectionCount: 5, // Maximum 5 dates
///   firstDayOfWeek: 1, // Monday first
///   viewCount: 2, // Show two months
///   scrollDirection: Axis.vertical,
///   dayBuilder: (context, date, isSelected, isDisabled) {
///     return Container(
///       decoration: BoxDecoration(
///         color: isSelected ? Colors.blue : Colors.transparent,
///         borderRadius: BorderRadius.circular(8),
///       ),
///       child: Center(
///         child: Text(
///           '${date.day}',
///           style: TextStyle(
///             color: isDisabled ? Colors.grey : Colors.black,
///           ),
///         ),
///       ),
///     );
///   },
///   onValueChange: (dates) {
///     print('Selected ${dates.length} dates: $dates');
///   },
/// );
/// ```
///
/// ### Advanced configuration with all options:
/// ```dart
/// final props = Props(
///   mode: SelectionMode.range,
///   value: [DateTime(2024, 6, 15), DateTime(2024, 6, 20)],
///   startDate: DateTime(2024, 1, 1),
///   endDate: DateTime(2025, 12, 31),
///   firstDayOfWeek: 1, // Monday first
///   viewCount: 2,
///   scrollDirection: Axis.horizontal,
///   disabledDate: (date) {
///     // Disable past dates and specific holidays
///     if (date.isBefore(DateTime.now())) return true;
///
///     // Disable Christmas and New Year
///     if (date.month == 12 && date.day == 25) return true;
///     if (date.month == 1 && date.day == 1) return true;
///
///     return false;
///   },
///   onValueChange: (dates) {
///     // Handle selection changes
///     if (dates.isEmpty) {
///       print('No dates selected');
///     } else if (dates.length == 1) {
///       print('Start date selected: ${dates.first}');
///     } else {
///       print('Range selected: ${dates.first} to ${dates.last}');
///     }
///   },
/// );
/// ```
@immutable
class Props {
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
  const Props({
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
    return other is Props &&
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
    disabledDate,
    onValueChange,
    selectionCount,
  );

  int get changeHashCode => Object.hash(
    mode,
    value,
    startDate,
    endDate,
    firstDayOfWeek,
    selectionCount,
  );
}
