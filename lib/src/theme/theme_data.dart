import 'package:flutter/material.dart';
import 'theme_constants.dart';

/// Theme data class containing all styling information for Flicker components
///
/// This class defines the visual appearance of date picker components including
/// colors, decorations, text styles, and other visual properties for different
/// states (normal, selected, disabled, highlighted).
class FlickThemeData {
  /// Main container decoration for the date picker widget
  final BoxDecoration? decoration;

  /// Default decoration for individual date containers
  final BoxDecoration? dayDecoration;

  /// Decoration for disabled date containers
  final BoxDecoration? dayDisabledDecoration;

  /// Decoration for date containers in the range
  // @override
  // final BoxDecoration? dayRangeDecoration;

  /// Decoration for the start date of the range
  // @override
  // final BoxDecoration? dayRangeStartDecoration;

  /// Decoration for the end date of the range
  // @override
  // final BoxDecoration? dayRangeEndDecoration;

  /// Decoration for selected date containers
  final BoxDecoration? daySelectedDecoration;

  /// Decoratio
  final BoxDecoration? dayHighlightDecoration;

  /// Text style for regular date numbers
  final TextStyle dayTextStyle;

  /// Text style for weekday labels (Mon, Tue, etc.)
  final TextStyle weekDayTextStyle;

  /// Text style for disabled date numbers
  final TextStyle dayDisabledTextStyle;

  /// Text style for selected date numbers
  final TextStyle daySelectedTextStyle;

  /// Text style for today's date highlight
  final TextStyle dayHighlightTextStyle;

  /// Text style for title/header text
  final TextStyle titleTextStyle;

  /// Whether to highlight today's date
  final bool highlightToday;

  /// Theme identifier name (e.g., 'light', 'dark')
  final String name;

  /// Theme brightness setting (light or dark)
  final Brightness brightness;

  /// Creates a copy of this theme data with specified properties overridden
  ///
  /// This method allows for theme customization by creating a new instance
  /// with modified properties while keeping unchanged properties from the
  /// original theme.
  ///
  /// All parameters are optional - only provide values for properties you
  /// want to change. Null values will use the current theme's values.
  ///
  /// Returns a new [FlickThemeData] instance with the specified changes.
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
    bool? highlightToday,
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
      highlightToday: highlightToday ?? this.highlightToday,
      name: name ?? this.name,
      brightness: brightness ?? this.brightness,
    );
  }

  /// Creates a new FlickerThemeData instance
  ///
  /// All text style parameters are required to ensure consistent theming.
  /// Decoration parameters are optional and can be null for default styling.
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
    this.highlightToday = true,
    required this.name,
    required this.brightness,
  });

  /// Creates a light theme with predefined light color scheme
  ///
  /// Uses light background colors, dark text, and blue accent colors
  /// for selection and highlighting. Suitable for light mode interfaces.
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
      highlightToday: true,
      name: 'light',
      brightness: Brightness.light,
    );
  }

  /// Creates a dark theme with predefined dark color scheme
  ///
  /// Uses dark background colors, light text, and blue accent colors
  /// for selection and highlighting. Suitable for dark mode interfaces.
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
      highlightToday: true,
      name: 'dark',
      brightness: Brightness.dark,
    );
  }

  /// Get appropriate text style for a day based on its state
  TextStyle getDayTextStyle( {
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
      isHighlighted: isHighlighted,
      isInRange: isInRange,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
    );
    
    return _getTextStyleForState(dayState);
  }
  
  /// Get text style based on day state priority
  TextStyle _getTextStyleForState(_DayState state) {
    if (state.isDisabled) {
      return dayDisabledTextStyle;
    }
    
    if (_isSelectedState(state)) {
      return daySelectedTextStyle;
    }
    
    if (state.isHighlighted) {
      return dayHighlightTextStyle;
    }
    
    if (state.isInRange) {
      return dayTextStyle;
    }
    
    return dayTextStyle;
  }
  
  /// Check if the day is in a selected state (selected, range start, or range end)
  bool _isSelectedState(_DayState state) {
    return state.isSelected || state.isRangeStart || state.isRangeEnd;
  }

  /// Get appropriate decoration for a day based on its state
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
      isHighlighted: isHighlighted,
      isInRange: isInRange,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
    );
    
    return _getDecorationForState(dayState);
  }
  
  /// Get decoration based on day state priority
  BoxDecoration? _getDecorationForState(_DayState state) {
    if (state.isDisabled) {
      return dayDisabledDecoration;
    }
    
    if (_isSelectedState(state)) {
      return daySelectedDecoration;
    }
    
    if (state.isHighlighted) {
      return dayHighlightDecoration;
    }
    
    if (state.isInRange) {
      return dayDecoration;
    }
    
    return dayDecoration;
  }
}

/// Helper class to represent the state of a day
class _DayState {
  final bool isSelected;
  final bool isDisabled;
  final bool isHighlighted;
  final bool isInRange;
  final bool isRangeStart;
  final bool isRangeEnd;
  
  const _DayState({
    required this.isSelected,
    required this.isDisabled,
    required this.isHighlighted,
    required this.isInRange,
    required this.isRangeStart,
    required this.isRangeEnd,
  });
}
