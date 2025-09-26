/// Flutter Flicker - High-Performance Customizable Date Picker Library
///
/// Flicker is a powerful, highly customizable Flutter date picker library
/// designed for modern mobile applications, providing smooth user experience
/// and rich customization options.
///
/// ## Core Features
///
/// ### 🎯 Multiple Selection Modes
/// - **Single Mode**: Select a single date
/// - **Range Mode**: Select a continuous date range
/// - **Multiple Mode**: Select multiple individual dates
///
/// ### 🎨 Powerful Theme System
/// - Automatic light/dark theme switching
/// - Fully customizable visual styles
/// - Responsive design for different screen sizes
///
/// ### 🌍 Internationalization Support
/// - Multi-language localization
/// - Configurable first day of week
/// - Localized date formatting
///

/// ## Quick Start
///
/// ```dart
/// import 'package:flutter_flicker/flicker.dart';
///
/// Flicker(
///   mode: SelectionMode.single,
///   value: [DateTime.now()],
///   onValueChange: (dates) {
///     print('Selected date: ${dates.first}');
///   },
/// )
/// ```
///
/// ## Main Components
///
/// - [Flicker]: Main date picker component
/// - [FlickerTheme]: Theme management and style customization
/// - [FlickerL10n]: Internationalization and localization support
///
/// For more detailed information and examples, please refer to the documentation
/// of each component.
library;

// Export internationalization classes for multi-language support and localization
export 'src/l10n/i10n.dart' show FlickerL10n, FlickerL10nDelegate;

// Export theme-related classes for style customization and theme management
export 'src/theme/theme.dart' show FlickThemeData, FlickerTheme;

// Export core view components and related enum types
export 'src/views/flicker.dart'
    show Flicker, SelectionMode, FirstDayOfWeek, DayBuilder;
