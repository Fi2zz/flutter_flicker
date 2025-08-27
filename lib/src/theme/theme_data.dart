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
      name: name ?? this.name,
      brightness: brightness ?? this.brightness,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
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
      name: 'dark',
      brightness: Brightness.dark,
    );
  }

  /// Returns the appropriate text style for a date based on its state
  ///
  /// Priority order: selected > highlighted today > disabled > default
  ///
  /// Parameters:
  /// - [selected]: Whether the date is currently selected
  /// - [disabled]: Whether the date is interactive/clickable
  /// - [highlight]: Whether this date represents today
  ///
  /// Returns the corresponding [TextStyle] for the date's current state.
  TextStyle getDayTextStyle(bool? selected, bool? disabled, bool? highlight) {
    if (selected == true) return daySelectedTextStyle;
    if (highlight == true) return dayHighlightTextStyle;
    if (disabled == true) return dayDisabledTextStyle;
    return dayTextStyle;
  }

  /// Returns the appropriate decoration for a date container based on its state
  ///
  /// Priority order: selected > highlighted today > disabled > default
  ///
  /// Parameters:
  /// - [selected]: Whether the date is currently selected
  /// - [disabled]: Whether the date is interactive/clickable
  /// - [highlight]: Whether this date represents today
  /// - [inRange]: Whether the date is within a selected range
  /// - [isRangeStart]: Whether the date is the start of a range
  /// - [isRangeEnd]: Whether the date is the end of a range
  ///
  /// Returns the corresponding [BoxDecoration] for the date's current state.
  BoxDecoration? getDayDecoration({
    bool? selected,
    bool? disabled,
    bool? highlight,
    bool? inRange,
    bool? isRangeStart,
    bool? isRangeEnd,
  }) {
    if (highlight == true) return dayHighlightDecoration;
    if (disabled == true) return dayDisabledDecoration;
    BorderRadius? borderRadius;
    if (isRangeStart == true && selected == true) {
      borderRadius = onlyLeftBorderRadius;
    } else if (isRangeEnd == true && selected == true) {
      borderRadius = onlyRightBorderRadius;
    } else if (inRange == true) {
      borderRadius = noBorderRadius;
    }
    if (borderRadius != null) {
      return daySelectedDecoration!.copyWith(borderRadius: borderRadius);
    }
    if (selected == true) return daySelectedDecoration;
    return dayDecoration;
  }
}
