import 'package:flutter/material.dart';
import 'theme_data.dart';

// 导出所有主题相关的类和常量
export './theme_data.dart' show FlickThemeData;
export './theme_constants.dart';

/// Theme provider for passing theme data through the Widget tree
///
/// This InheritedWidget allows theme data to be accessed by descendant widgets
/// without explicitly passing it through constructor parameters.
class FlickThemeProvider extends InheritedWidget {
  /// Current theme configuration
  final FlickThemeData? theme;

  const FlickThemeProvider({super.key, this.theme, required super.child});

  /// Get the nearest FlickerThemeProvider
  static FlickThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FlickThemeProvider>();
  }

  /// Determines whether dependent widgets should be notified when theme data changes
  @override
  bool updateShouldNotify(FlickThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}

/// Theme context utility for accessing theme data from the widget tree
///
/// Provides static methods to retrieve theme data from the current BuildContext.
class FlickThemeContext {
  /// Retrieves theme data from the current context
  ///
  /// Returns the [FlickThemeData] from the nearest [FlickThemeProvider]
  /// ancestor, or null if no provider is found.
  static FlickThemeData? of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<FlickThemeProvider>();

    return provider?.theme;
  }
}

/// Theme manager for Flicker components
///
/// Provides utilities for creating themed widgets and accessing theme properties
/// throughout the application.
class FlickTheme {
  /// Whether to use dark theme, null means follow system
  final bool? useDarkMode;

  /// Custom theme data (optional)
  final FlickThemeData? custom;

  const FlickTheme({this.useDarkMode, this.custom});

  /// Get current theme data
  FlickThemeData get data {
    if (custom != null) return custom!;
    final bool darkMode = useDarkMode ?? _getSystemBrightness();
    // debugPrint('darkMode $darkMode');
    return darkMode ? FlickThemeData.dark() : FlickThemeData.light();
  }

  /// Get system brightness
  bool _getSystemBrightness() {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  /// Get date text style
  TextStyle getDayStyle({
    required bool selected,
    bool? enabled,
    bool? highlightToday,
  }) {
    return data.getDayTextStyle(selected, enabled, highlightToday);
  }

  /// Get date container decoration
  BoxDecoration? getDayDecoration({
    bool? selected,
    bool? enabled,
    bool? highlightToday,
    bool? inRange,
    bool? isRangeStart,
    bool? isRangeEnd,
  }) {
    return data.getDayDecoration(
      selected: selected,
      disabled: enabled,
      highlight: highlightToday,
      inRange: inRange,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
    );
  }

  /// Get theme name
  String get name => data.name;

  /// Get theme brightness
  Brightness get brightness => data.brightness;
}
