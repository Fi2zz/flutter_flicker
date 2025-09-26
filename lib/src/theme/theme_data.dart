import 'package:flutter/widgets.dart';
import 'theme_constants.dart';

/// Comprehensive theme data class for Flicker date picker components
///
/// [FlickThemeData] defines the complete visual styling system for the Flicker
/// date picker, including colors, decorations, text styles, and visual states.
/// This class provides a flexible theming system that supports both light and
/// dark modes, as well as custom theme creation.
///
/// ## Theme Structure
///
/// The theme system is organized into several categories:
/// - **Container Decorations**: Background styling for the picker and date cells
/// - **Text Styles**: Typography for different text elements and states
/// - **State Management**: Visual styling for different date states
/// - **Brightness Support**: Light and dark mode compatibility
///
/// ## Usage Examples
///
/// ### Using Predefined Themes
/// ```dart
/// // Light theme
/// final lightTheme = FlickThemeData.light();
///
/// // Dark theme
/// final darkTheme = FlickThemeData.dark();
/// ```
///
/// ### Creating Custom Themes
/// ```dart
/// final customTheme = FlickThemeData(
///   decoration: BoxDecoration(
///     color: Colors.white,
///     borderRadius: BorderRadius.circular(12),
///   ),
///   dayTextStyle: TextStyle(
///     fontSize: 16,
///     color: Colors.black87,
///   ),
///   // ... other properties
/// );
/// ```
///
/// ### Theme Customization
/// ```dart
/// final modifiedTheme = FlickThemeData.light().copyWith(
///   daySelectedDecoration: BoxDecoration(
///     color: Colors.purple,
///     shape: BoxShape.circle,
///   ),
///   daySelectedTextStyle: TextStyle(
///     color: Colors.white,
///     fontWeight: FontWeight.bold,
///   ),
/// );
/// ```
class FlickThemeData {
  /// Main container decoration for the entire date picker widget
  ///
  /// This decoration is applied to the outermost container of the date picker.
  /// It typically includes background color, border radius, shadows, and other
  /// container-level styling properties.
  final BoxDecoration? decoration;

  /// Default decoration for individual date cell containers
  ///
  /// Applied to date cells in their normal, unselected state. This provides
  /// the base styling for date cells when they are not selected, disabled,
  /// or highlighted.
  final BoxDecoration? dayDecoration;

  /// Decoration for disabled date cell containers
  ///
  /// Applied to date cells that are disabled and cannot be selected.
  /// Typically uses muted colors or reduced opacity to indicate the
  /// disabled state visually.
  final BoxDecoration? dayDisabledDecoration;

  /// Decoration for date cells in a selected range
  ///
  /// Used for date range selection mode to style dates that fall between
  /// the start and end dates of a selected range.
  // @override
  // final BoxDecoration? dayRangeDecoration;

  /// Decoration for the start date of a selected range
  ///
  /// Special styling for the first date in a range selection, typically
  /// with rounded corners on the left side only.
  // @override
  // final BoxDecoration? dayRangeStartDecoration;

  /// Decoration for the end date of a selected range
  ///
  /// Special styling for the last date in a range selection, typically
  /// with rounded corners on the right side only.
  // @override
  // final BoxDecoration? dayRangeEndDecoration;

  /// Decoration for selected date cell containers
  ///
  /// Applied to date cells that are currently selected. This decoration
  /// should provide clear visual feedback to indicate selection state,
  /// typically using accent colors or distinctive styling.
  final BoxDecoration? daySelectedDecoration;

  /// Decoration for highlighted date cells (typically today's date)
  ///
  /// Used to highlight special dates, most commonly today's date.
  /// This decoration should be subtle but noticeable to draw attention
  /// without overwhelming the selected state styling.
  final BoxDecoration? dayHighlightDecoration;

  /// Text style for regular date numbers
  ///
  /// The default text styling for date numbers in their normal state.
  /// This includes font size, color, weight, and other typography properties
  /// for unselected, enabled dates.
  final TextStyle dayTextStyle;

  /// Text style for weekday labels (Mon, Tue, Wed, etc.)
  ///
  /// Typography styling for the weekday header labels displayed above
  /// the date grid. These labels typically use smaller, lighter text
  /// to distinguish them from date numbers.
  final TextStyle weekDayTextStyle;

  /// Text style for disabled date numbers
  ///
  /// Typography for dates that are disabled and cannot be selected.
  /// Usually features muted colors or reduced opacity to indicate
  /// the disabled state.
  final TextStyle dayDisabledTextStyle;

  /// Text style for selected date numbers
  ///
  /// Typography for dates that are currently selected. This style
  /// should provide high contrast against the selected decoration
  /// background for optimal readability.
  final TextStyle daySelectedTextStyle;

  /// Text style for highlighted date numbers (typically today's date)
  ///
  /// Typography for special highlighted dates, most commonly today's date.
  /// This style should be distinctive but not as prominent as the
  /// selected state styling.
  final TextStyle dayHighlightTextStyle;

  /// Text style for title and header text elements
  ///
  /// Typography for month/year titles and other header elements in
  /// the date picker interface. Usually larger and bolder than
  /// regular date text.
  final TextStyle titleTextStyle;

  /// Theme identifier name for debugging and reference
  ///
  /// A human-readable name for this theme (e.g., 'light', 'dark', 'custom').
  /// Useful for debugging, logging, and theme management.
  final String name;

  /// Theme brightness setting indicating light or dark mode
  ///
  /// Determines whether this theme is designed for light or dark interfaces.
  /// This affects automatic color adjustments and system integration.
  final Brightness brightness;

  /// Creates a customized copy of this theme with specified properties overridden
  ///
  /// This method enables theme customization by creating a new [FlickThemeData]
  /// instance with modified properties while preserving unchanged properties
  /// from the original theme.
  ///
  /// ## Parameters
  ///
  /// All parameters are optional. Only provide values for properties you want
  /// to change. Properties with `null` values will inherit from the current theme.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final customTheme = FlickThemeData.light().copyWith(
  ///   daySelectedDecoration: BoxDecoration(
  ///     color: Colors.red,
  ///     shape: BoxShape.circle,
  ///   ),
  ///   daySelectedTextStyle: TextStyle(
  ///     color: Colors.white,
  ///     fontWeight: FontWeight.bold,
  ///   ),
  /// );
  /// ```
  ///
  /// Returns a new [FlickThemeData] instance with the specified modifications.
  FlickThemeData copyWith({
    BoxDecoration? decoration,
    BoxDecoration? dayDecoration,
    BoxDecoration? dayDisabledDecoration,
    BoxDecoration? daySelectedDecoration,
    BoxDecoration? dayHighlightDecoration,
    TextStyle? dayTextStyle,
    TextStyle? weekDayTextStyle,
    TextStyle? dayDisabledTextStyle,
    TextStyle? daySelectedTextStyle,
    TextStyle? dayHighlightTextStyle,
    TextStyle? titleTextStyle,
    String? name,
    Brightness? brightness,
  }) {
    return FlickThemeData(
      decoration: decoration ?? this.decoration,
      dayDecoration: dayDecoration ?? this.dayDecoration,
      dayDisabledDecoration:
          dayDisabledDecoration ?? this.dayDisabledDecoration,
      daySelectedDecoration:
          daySelectedDecoration ?? this.daySelectedDecoration,
      dayHighlightDecoration:
          dayHighlightDecoration ?? this.dayHighlightDecoration,
      dayTextStyle: dayTextStyle ?? this.dayTextStyle,
      weekDayTextStyle: weekDayTextStyle ?? this.weekDayTextStyle,
      dayDisabledTextStyle: dayDisabledTextStyle ?? this.dayDisabledTextStyle,
      daySelectedTextStyle: daySelectedTextStyle ?? this.daySelectedTextStyle,
      dayHighlightTextStyle:
          dayHighlightTextStyle ?? this.dayHighlightTextStyle,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      name: name ?? this.name,
      brightness: brightness ?? this.brightness,
    );
  }

  /// Creates a new FlickThemeData instance with comprehensive styling options
  ///
  /// ## Required Parameters
  ///
  /// All text style parameters are required to ensure consistent typography
  /// throughout the date picker interface. This prevents styling inconsistencies
  /// and ensures proper visual hierarchy.
  ///
  /// ## Optional Parameters
  ///
  /// Decoration parameters are optional and can be `null` for minimal styling.
  /// When `null`, the date picker will use default Flutter styling or no
  /// decoration as appropriate.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final theme = FlickThemeData(
  ///   decoration: BoxDecoration(
  ///     color: Colors.white,
  ///     borderRadius: BorderRadius.circular(8),
  ///   ),
  ///   dayTextStyle: TextStyle(fontSize: 16, color: Colors.black),
  ///   weekDayTextStyle: TextStyle(fontSize: 12, color: Colors.grey),
  ///   // ... other required styles
  ///   name: 'custom',
  ///   brightness: Brightness.light,
  /// );
  /// ```
  const FlickThemeData({
    this.decoration,
    this.dayDecoration,
    this.dayDisabledDecoration,
    this.daySelectedDecoration,
    this.dayHighlightDecoration,
    required this.titleTextStyle,
    required this.dayTextStyle,
    required this.weekDayTextStyle,
    required this.dayDisabledTextStyle,
    required this.daySelectedTextStyle,
    required this.dayHighlightTextStyle,
    required this.name,
    required this.brightness,
  });

  /// Creates a predefined light theme with optimized light mode styling
  ///
  /// This factory constructor provides a complete light theme with carefully
  /// chosen colors and styling that work well in light mode interfaces.
  ///
  /// ## Theme Characteristics
  /// - Light background colors with dark text for optimal readability
  /// - Blue accent colors for selection and highlighting
  /// - Subtle shadows and borders for depth and definition
  ///
  /// ## Usage
  /// ```dart
  /// final lightTheme = FlickThemeData.light();
  ///
  /// FlickerTheme(
  ///   data: lightTheme,
  ///   child: Flicker(...),
  /// )
  /// ```
  ///
  /// Returns a [FlickThemeData] instance configured for light mode.
  factory FlickThemeData.light() {
    return FlickThemeData(
      decoration: ThemeConstants.lightDecoration,
      daySelectedDecoration: ThemeConstants.lightSelectedDecoration,
      dayTextStyle: ThemeConstants.lightDayStyle,
      weekDayTextStyle: ThemeConstants.lightWeekDayStyle,
      dayDisabledTextStyle: ThemeConstants.lightDayDisabledStyle,
      daySelectedTextStyle: ThemeConstants.lightDaySelectedStyle,
      dayHighlightTextStyle: ThemeConstants.lightDayHighlightStyle,
      titleTextStyle: ThemeConstants.lightTitleStyle,
      name: 'light',
      brightness: Brightness.light,
    );
  }

  /// Creates a predefined dark theme with optimized dark mode styling
  ///
  /// This factory constructor provides a complete dark theme with carefully
  /// chosen colors and styling that work well in dark mode interfaces.
  ///
  /// ## Theme Characteristics
  /// - Dark background colors with light text for reduced eye strain
  /// - Blue accent colors adapted for dark backgrounds
  /// - Subtle highlights and borders optimized for dark themes
  ///
  /// ## Usage
  /// ```dart
  /// final darkTheme = FlickThemeData.dark();
  ///
  /// FlickerTheme(
  ///   data: darkTheme,
  ///   child: Flicker(...),
  /// )
  /// ```
  ///
  /// Returns a [FlickThemeData] instance configured for dark mode.
  factory FlickThemeData.dark() {
    return FlickThemeData(
      decoration: ThemeConstants.darkDecoration,
      daySelectedDecoration: ThemeConstants.darkSelectedDecoration,
      dayTextStyle: ThemeConstants.darkDayTextStyle,
      weekDayTextStyle: ThemeConstants.darkWeekDayTextStyle,
      dayDisabledTextStyle: ThemeConstants.darkDayDisabledTextStyle,
      daySelectedTextStyle: ThemeConstants.darkDaySelectedStyle,
      dayHighlightTextStyle: ThemeConstants.darkDayHighlightStyle,
      titleTextStyle: ThemeConstants.darkTitleStyle,
      name: 'dark',
      brightness: Brightness.dark,
    );
  }

  /// Determines the appropriate text style for a date based on its current state
  ///
  /// This method evaluates multiple state flags to determine the most appropriate
  /// text style for a date cell. The evaluation follows a priority system where
  /// certain states take precedence over others.
  ///
  /// ## State Priority (highest to lowest)
  /// 1. **Disabled**: Always takes precedence
  /// 2. **Selected**: High priority for user feedback
  /// 3. **Highlighted**: Medium priority (e.g., today's date)
  /// 4. **In Range**: Lower priority for range selections
  /// 5. **Default**: Fallback for normal dates
  ///
  /// ## Parameters
  /// - [isSelected]: Whether the date is currently selected
  /// - [isDisabled]: Whether the date is disabled and cannot be selected
  /// - [isHighlighted]: Whether the date should be highlighted (e.g., today)
  /// - [isInRange]: Whether the date is within a selected range
  /// - [isRangeStart]: Whether the date is the start of a range
  /// - [isRangeEnd]: Whether the date is the end of a range
  ///
  /// ## Example
  /// ```dart
  /// final textStyle = theme.getDayTextStyle(
  ///   isSelected: true,
  ///   isDisabled: false,
  ///   isHighlighted: false,
  ///   isInRange: false,
  ///   isRangeStart: false,
  ///   isRangeEnd: false,
  /// ); // Returns daySelectedTextStyle
  /// ```
  ///
  /// Returns the [TextStyle] that should be applied to the date cell.
  TextStyle getDayTextStyle({
    required bool isSelected,
    required bool isDisabled,
    required bool isHighlighted,
    required bool isInRange,
    required bool isRangeStart,
    required bool isRangeEnd,
  }) {
    final dayState = _DayState(
      isSelected: isSelected,
      isDisabled: isDisabled,
      isToday: isHighlighted,
      isInRange: isInRange,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
    );

    return _getTextStyleForState(dayState);
  }

  /// Internal method to determine text style based on day state priority
  ///
  /// Implements the state priority logic for text style selection.
  /// This method is called internally by [getDayTextStyle] and follows
  /// a specific priority order to ensure consistent styling.
  TextStyle _getTextStyleForState(_DayState state) {
    // Disabled state has highest priority
    if (state.isDisabled) {
      return dayDisabledTextStyle;
    }

    bool selected = state.isSelected;

    // Selected state has second highest priority
    if (selected) {
      return daySelectedTextStyle;
    }

    // Highlighted state (e.g., today) has medium priority
    if (state.isToday) {
      return dayHighlightTextStyle;
    }

    // In-range state has lower priority
    if (state.isInRange) {
      return daySelectedTextStyle;
    }

    // Default state for normal dates
    return dayTextStyle;
  }

  /// Determines the appropriate decoration for a date based on its current state
  ///
  /// This method evaluates multiple state flags to determine the most appropriate
  /// decoration for a date cell. It handles special cases like range selections
  /// where different border radius configurations are needed for start, middle,
  /// and end dates.
  ///
  /// ## State Priority (highest to lowest)
  /// 1. **Disabled**: Always takes precedence
  /// 2. **Range Positioning**: Special handling for range start/middle/end
  /// 3. **Selected**: High priority for user feedback
  /// 4. **Highlighted**: Medium priority (e.g., today's date)
  /// 5. **Default**: Fallback for normal dates
  ///
  /// ## Range Selection Handling
  /// - **Range Start**: Rounded corners on the left side only
  /// - **Range Middle**: No rounded corners for continuous appearance
  /// - **Range End**: Rounded corners on the right side only
  ///
  /// ## Parameters
  /// - [isSelected]: Whether the date is currently selected
  /// - [isDisabled]: Whether the date is disabled and cannot be selected
  /// - [isHighlighted]: Whether the date should be highlighted (e.g., today)
  /// - [isInRange]: Whether the date is within a selected range
  /// - [isRangeStart]: Whether the date is the start of a range
  /// - [isRangeEnd]: Whether the date is the end of a range
  ///
  /// ## Example
  /// ```dart
  /// final decoration = theme.getDayDecoration(
  ///   isSelected: true,
  ///   isDisabled: false,
  ///   isHighlighted: false,
  ///   isInRange: true,
  ///   isRangeStart: true,
  ///   isRangeEnd: false,
  /// ); // Returns daySelectedDecoration with left-only border radius
  /// ```
  ///
  /// Returns the [BoxDecoration] that should be applied to the date cell,
  /// or `null` if no decoration is needed.
  BoxDecoration? getDayDecoration({
    required bool isSelected,
    required bool isDisabled,
    required bool isHighlighted,
    required bool isInRange,
    required bool isRangeStart,
    required bool isRangeEnd,
  }) {
    final dayState = _DayState(
      isSelected: isSelected,
      isDisabled: isDisabled,
      isToday: isHighlighted,
      isInRange: isInRange,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
    );

    return _getDecorationForState(dayState);
  }

  /// Internal method to determine decoration based on day state priority
  ///
  /// Implements the state priority logic for decoration selection, including
  /// special handling for range selections with custom border radius configurations.
  BoxDecoration? _getDecorationForState(_DayState state) {
    // Disabled state has highest priority
    if (state.isDisabled) {
      return dayDisabledDecoration;
    }

    bool selected = state.isSelected;
    BorderRadius? radius;

    // Handle range selection border radius
    if (state.isRangeStart == true && selected == true) {
      radius = onlyLeftBorderRadius;
    } else if (state.isRangeEnd == true && selected == true) {
      radius = onlyRightBorderRadius;
    } else if (state.isInRange == true) {
      radius = noBorderRadius;
    }

    // Apply custom border radius for range selections
    if (radius != null) {
      return daySelectedDecoration!.copyWith(borderRadius: radius);
    }

    // Standard state handling
    if (selected) return daySelectedDecoration;
    if (state.isToday) return dayHighlightDecoration;
    return dayDecoration;
  }
}

/// Internal helper class representing the complete state of a date cell
///
/// This private class encapsulates all possible states that a date cell can have,
/// providing a clean interface for state-based styling decisions. It's used
/// internally by the theme system to determine appropriate styling.
///
/// ## State Properties
/// - [isSelected]: Date is currently selected by the user
/// - [isDisabled]: Date cannot be selected (e.g., outside valid range)
/// - [isToday]: Date represents today's date
/// - [isInRange]: Date falls within a selected date range
/// - [isRangeStart]: Date is the first date in a selected range
/// - [isRangeEnd]: Date is the last date in a selected range
class _DayState {
  /// Whether this date is currently selected
  final bool isSelected;

  /// Whether this date is disabled and cannot be selected
  final bool isDisabled;

  /// Whether this date represents today's date
  final bool isToday;

  /// Whether this date falls within a selected range
  final bool isInRange;

  /// Whether this date is the start of a selected range
  final bool isRangeStart;

  /// Whether this date is the end of a selected range
  final bool isRangeEnd;

  /// Creates a new day state with the specified properties
  ///
  /// All parameters are required to ensure complete state representation.
  const _DayState({
    required this.isSelected,
    required this.isDisabled,
    required this.isToday,
    required this.isInRange,
    required this.isRangeStart,
    required this.isRangeEnd,
  });
}
