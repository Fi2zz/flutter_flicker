/// Flicker Date Picker Library
///
/// A comprehensive, customizable Flutter date picker widget with support for:
/// - Single date selection
/// - Date range selection
/// - Multiple date selection
/// - Custom themes (light/dark mode)
/// - Internationalization support
/// - Flexible layout options (horizontal/vertical scrolling)
/// - Custom date builders and styling
///
/// This library provides a complete date picker solution with smooth animations,
/// responsive design, and extensive customization options.
library;

/// Internationalization support
export 'src/l10n/i10n.dart' show FlickerL10n, FlickerL10nDelegate;

/// Core date picker widget and related types
export 'src/views/flicker.dart' show Flicker, FlickerSelectionMode;
export 'src/views/flicker_month_view.dart' show FlickerDayBuilder;

/// Theme system for customizing the appearance
export 'src/theme/theme.dart' show FlickThemeData, FlickTheme;

/// Extension methods for BuildContext
export 'src/views/flicker_extensions.dart' show FirstDayOfWeek;
