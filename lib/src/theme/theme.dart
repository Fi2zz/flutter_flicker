import 'package:flutter/widgets.dart';
import 'theme_data.dart';

/// Export all theme-related classes and constants for external use
///
/// This provides a clean public API for theme management, allowing consumers
/// to access theme data and constants without importing internal files directly.
export 'theme_data.dart' show FlickThemeData;
export 'theme_constants.dart';

/// Comprehensive theme manager and provider for Flicker date picker components
///
/// [FlickerTheme] serves as the central theme management system for the Flicker
/// date picker library. It provides intelligent theme selection, system integration,
/// and convenient styling utilities for date picker components.
///
/// ## Key Features
///
/// ### Automatic Theme Detection
/// - **System Integration**: Automatically detects and follows system dark/light mode
/// - **Manual Override**: Allows explicit theme selection when needed
/// - **Custom Themes**: Supports completely custom theme data
///
/// ### Intelligent Styling
/// - **State-aware Styling**: Provides appropriate styles based on date states
/// - **Consistent API**: Unified interface for accessing theme properties
/// - **Performance Optimized**: Efficient theme resolution and caching
///
/// ## Usage Examples
///
/// ### Automatic System Theme
/// ```dart
/// final theme = FlickerTheme();
/// // Automatically follows system light/dark mode
/// ```
///
/// ### Explicit Theme Selection
/// ```dart
/// final lightTheme = FlickerTheme(useDarkMode: false);
/// final darkTheme = FlickerTheme(useDarkMode: true);
/// ```
///
/// ### Custom Theme Data
/// ```dart
/// final customTheme = FlickerTheme(
///   themeData: FlickThemeData(
///     dayTextStyle: TextStyle(color: Colors.purple),
///     daySelectedDecoration: BoxDecoration(
///       color: Colors.purple,
///       shape: BoxShape.circle,
///     ),
///     // ... other custom properties
///   ),
/// );
/// ```
///
/// ### Accessing Theme Properties
/// ```dart
/// final theme = FlickerTheme();
///
/// // Get text style for a selected date
/// final selectedStyle = theme.getDayStyle(
///   selected: true,
///   enabled: true,
///   highlightToday: false,
/// );
///
/// // Get decoration for a date in range
/// final rangeDecoration = theme.getDayDecoration(
///   selected: false,
///   inRange: true,
///   isRangeStart: false,
///   isRangeEnd: false,
/// );
/// ```
class FlickerTheme {
  /// Theme mode preference for dark/light theme selection
  ///
  /// - `true`: Force dark theme regardless of system setting
  /// - `false`: Force light theme regardless of system setting
  /// - `null`: Automatically follow system brightness setting (default)
  ///
  /// When `null`, the theme manager will automatically detect the system's
  /// current brightness setting and apply the appropriate theme.
  final bool? useDarkMode;

  /// Custom theme data to override default themes
  ///
  /// When provided, this custom theme data takes precedence over the
  /// automatic theme selection based on [useDarkMode]. This allows for
  /// completely custom styling that doesn't follow the predefined
  /// light/dark theme patterns.
  ///
  /// If `null`, the theme manager will use the appropriate predefined
  /// theme based on the [useDarkMode] setting or system brightness.
  final FlickThemeData? themeData;
  static FlickThemeData dark() => FlickThemeData.dark();
  static FlickThemeData light() => FlickThemeData.light();

  /// Creates a new FlickerTheme instance with optional theme configuration
  ///
  /// ## Parameters
  /// - [useDarkMode]: Optional theme mode preference. When `null`, follows system setting
  /// - [themeData]: Optional custom theme data. When provided, overrides automatic theme selection
  ///
  /// ## Examples
  ///
  /// ```dart
  /// // Automatic system theme
  /// final autoTheme = FlickerTheme();
  ///
  /// // Explicit dark theme
  /// final darkTheme = FlickerTheme(useDarkMode: true);
  ///
  /// // Custom theme
  /// final customTheme = FlickerTheme(
  ///   themeData: FlickThemeData.light().copyWith(
  ///     daySelectedDecoration: BoxDecoration(color: Colors.red),
  ///   ),
  /// );
  /// ```
  const FlickerTheme({this.useDarkMode, this.themeData});

  /// Resolves and returns the current theme data based on configuration
  ///
  /// This getter implements the theme resolution logic with the following priority:
  /// 1. **Custom Theme Data**: If [themeData] is provided, it's used directly
  /// 2. **Explicit Mode**: If [useDarkMode] is set, uses the corresponding predefined theme
  /// 3. **System Detection**: Falls back to system brightness detection
  ///
  /// ## Theme Resolution Process
  /// 1. Check if custom [themeData] is provided → return it
  /// 2. Determine dark mode preference from [useDarkMode] or system
  /// 3. Return appropriate predefined theme (light/dark)
  ///
  /// ## Performance Notes
  /// This getter performs theme resolution on each access. For performance-critical
  /// scenarios, consider caching the result if accessed frequently.
  ///
  /// Returns the resolved [FlickThemeData] instance for the current configuration.
  FlickThemeData get data {
    // Priority 1: Use custom theme data if provided
    if (themeData != null) return themeData!;

    // Priority 2: Resolve theme based on dark mode preference or system setting
    final bool darkMode = useDarkMode ?? _getSystemBrightness();
    return darkMode ? FlickThemeData.dark() : FlickThemeData.light();
  }

  /// Detects the current system brightness setting
  ///
  /// This private method queries the platform's brightness setting to determine
  /// whether the system is currently in dark mode. It's used for automatic
  /// theme selection when [useDarkMode] is `null`.
  ///
  /// ## Platform Integration
  /// - **iOS**: Integrates with iOS Dark Mode setting
  /// - **Android**: Integrates with Android Dark Theme setting
  /// - **Web**: Respects browser/OS dark mode preference
  /// - **Desktop**: Follows system theme on macOS, Windows, and Linux
  ///
  /// Returns `true` if the system is in dark mode, `false` otherwise.
  bool _getSystemBrightness() {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  /// Determines the appropriate text style for a date based on its state
  ///
  /// This method provides a convenient interface for getting text styles
  /// without needing to specify all state parameters. It's particularly
  /// useful for simple date styling scenarios.
  ///
  /// ## Parameters
  /// - [selected]: Whether the date is currently selected (required)
  /// - [enabled]: Whether the date is enabled/selectable (optional, defaults to `false` for disabled)
  /// - [highlightToday]: Whether to highlight this date as today (optional, defaults to `false`)
  ///
  /// ## State Mapping
  /// The method maps the simplified parameters to the full state system:
  /// - `selected` → `isSelected`
  /// - `enabled` → `isDisabled` (inverted logic)
  /// - `highlightToday` → `isHighlighted`
  /// - Range states are set to `false` (not applicable for simple styling)
  ///
  /// ## Example
  /// ```dart
  /// final theme = FlickerTheme();
  ///
  /// // Style for a selected, enabled date
  /// final selectedStyle = theme.getDayStyle(
  ///   selected: true,
  ///   enabled: true,
  /// );
  ///
  /// // Style for today's date (highlighted but not selected)
  /// final todayStyle = theme.getDayStyle(
  ///   selected: false,
  ///   highlightToday: true,
  /// );
  /// ```
  ///
  /// Returns the appropriate [TextStyle] for the specified date state.
  TextStyle getDayStyle({
    required bool selected,
    bool? enabled,
    bool? highlightToday,
  }) {
    return data.getDayTextStyle(
      isSelected: selected,
      isDisabled: !(enabled ?? true), // Invert enabled to get disabled state
      isHighlighted: highlightToday ?? false,
      isInRange: false,
      isRangeStart: false,
      isRangeEnd: false,
    );
  }

  /// Determines the appropriate decoration for a date based on its state
  ///
  /// This method provides a convenient interface for getting decorations
  /// with support for both simple and complex date states, including
  /// range selection scenarios.
  ///
  /// ## Parameters
  /// - [selected]: Whether the date is currently selected (optional, defaults to `false`)
  /// - [enabled]: Whether the date is enabled/selectable (optional, defaults to `true`)
  /// - [highlightToday]: Whether to highlight this date as today (optional, defaults to `false`)
  /// - [inRange]: Whether the date is within a selected range (optional, defaults to `false`)
  /// - [isRangeStart]: Whether the date is the start of a range (optional, defaults to `false`)
  /// - [isRangeEnd]: Whether the date is the end of a range (optional, defaults to `false`)
  ///
  /// ## Range Selection Support
  /// This method fully supports range selection styling with proper handling
  /// of start, middle, and end dates in a range:
  ///
  /// ```dart
  /// // Range start date
  /// final startDecoration = theme.getDayDecoration(
  ///   selected: true,
  ///   inRange: true,
  ///   isRangeStart: true,
  /// );
  ///
  /// // Range middle date
  /// final middleDecoration = theme.getDayDecoration(
  ///   inRange: true,
  /// );
  ///
  /// // Range end date
  /// final endDecoration = theme.getDayDecoration(
  ///   selected: true,
  ///   inRange: true,
  ///   isRangeEnd: true,
  /// );
  /// ```
  ///
  /// ## State Priority
  /// The decoration selection follows the same priority system as the
  /// underlying theme data, ensuring consistent visual hierarchy.
  ///
  /// Returns the appropriate [BoxDecoration] for the specified date state,
  /// or `null` if no decoration should be applied.
  BoxDecoration? getDayDecoration({
    bool? selected,
    bool? enabled,
    bool? highlightToday,
    bool? inRange,
    bool? isRangeStart,
    bool? isRangeEnd,
  }) {
    return data.getDayDecoration(
      isSelected: selected ?? false,
      isDisabled: !(enabled ?? true), // Invert enabled to get disabled state
      isHighlighted: highlightToday ?? false,
      isInRange: inRange ?? false,
      isRangeStart: isRangeStart ?? false,
      isRangeEnd: isRangeEnd ?? false,
    );
  }

  /// Gets the human-readable name of the current theme
  ///
  /// This property provides access to the theme's identifier name,
  /// which is useful for debugging, logging, and theme management.
  ///
  /// ## Common Values
  /// - `'light'`: For the predefined light theme
  /// - `'dark'`: For the predefined dark theme
  /// - Custom names for custom themes
  ///
  /// Returns the theme name as defined in the current [FlickThemeData].
  String get name => data.name;

  /// Gets the brightness setting of the current theme
  ///
  /// This property indicates whether the current theme is designed for
  /// light or dark interfaces, which can be useful for:
  /// - Conditional styling logic
  /// - Integration with other UI components
  ///
  /// Returns [Brightness.light] for light themes or [Brightness.dark] for dark themes.
  Brightness get brightness => data.brightness;
}
