import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

/// Localization delegate for Flicker date picker
///
/// Implements Flutter's [LocalizationsDelegate] interface to provide
/// custom localization support for Flicker date picker. Supports English and Chinese.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   localizationsDelegates: FlickerL10n.localizationsDelegates,
///   supportedLocales: FlickerL10n.supportedLocales,
/// )
/// ```
class FlickerL10nDelegate extends LocalizationsDelegate<FlickerL10n> {
  /// Creates a localization delegate instance
  const FlickerL10nDelegate();

  /// Checks if the specified locale is supported
  ///
  /// Currently supports:
  /// - 'en': English
  /// - 'zh': Chinese
  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  /// Asynchronously loads localization resources for the specified locale
  @override
  Future<FlickerL10n> load(Locale locale) async {
    return FlickerL10n(locale);
  }

  /// Determines whether the delegate should reload
  ///
  /// Since [FlickerL10nDelegate] is stateless and immutable, reloading is never required.
  @override
  bool shouldReload(FlickerL10nDelegate old) => false;
}

/// Localization resource provider for Flicker date picker
///
/// Provides localization resources for Flicker date picker, including weekday names,
/// date formats, and cultural preferences. Supports English and Chinese, with automatic
/// fallback to English for unsupported locales.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   localizationsDelegates: FlickerL10n.localizationsDelegates,
///   supportedLocales: FlickerL10n.supportedLocales,
/// )
/// ```
class FlickerL10n {
  /// The locale corresponding to this localization instance
  final Locale locale;

  /// Creates a localization instance for the specified locale
  const FlickerL10n(this.locale);

  /// Default English localization instance
  ///
  /// Used when no localization context is available or the requested locale is not supported.
  static const FlickerL10n defaultL10n = FlickerL10n(Locale('en', 'US'));

  /// Retrieves the localization instance from widget context
  ///
  /// Automatically falls back to default English localization if no instance is found.
  static FlickerL10n of(BuildContext context) {
    return Localizations.of<FlickerL10n>(context, FlickerL10n) ?? defaultL10n;
  }

  /// Flicker localization delegate instance
  static const LocalizationsDelegate<FlickerL10n> delegate =
      FlickerL10nDelegate();

  /// Complete list of localization delegates required for Flicker date picker
  ///
  /// Includes Flicker-specific delegate and all necessary Flutter framework delegates:
  /// - [FlickerL10n.delegate]: Flicker custom localization
  /// - [GlobalMaterialLocalizations.delegate]: Material Design components
  /// - [GlobalCupertinoLocalizations.delegate]: Cupertino (iOS-style) components
  /// - [GlobalWidgetsLocalizations.delegate]: Flutter core widgets
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    FlickerL10n.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// List of locales supported by Flicker date picker
  ///
  /// Currently supports:
  /// - English (United States): en-US
  /// - Chinese (China): zh-CN
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ];

  /// Localized weekday names for calendar headers
  ///
  /// Provides abbreviated weekday names for calendar column headers:
  /// - **English**: Two-letter abbreviations (Su, Mo, Tu, We, Th, Fr, Sa)
  /// - **Chinese**: Single-character Chinese weekday names (日, 一, 二, 三, 四, 五, 六)
  ///
  /// Weekday names are ordered from Sunday (index 0) to Saturday (index 6).
  static const Map<String, List<String>> _weekdayNames = {
    'en': ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
    'zh': ['日', '一', '二', '三', '四', '五', '六'],
  };

  /// First day of week preference for different locales
  ///
  /// Defines the preferred first day of the week for each locale:
  /// - **English (0)**: Sunday as the first day (Western convention)
  /// - **Chinese (1)**: Monday as the first day (ISO 8601 standard)
  ///
  /// Values correspond to DateTime weekday constants: 0 = Sunday, 1 = Monday, 2 = Tuesday, etc.
  static const Map<String, int> _firstDayOfWeek = {'en': 0, 'zh': 1};

  /// Gets the localized weekday names for the current locale
  ///
  /// Returns a list of 7 abbreviated weekday names ordered from Sunday to Saturday.
  /// Falls back to English if the current locale is not supported.
  ///
  /// Example:
  /// ```dart
  /// final l10n = FlickerL10n(Locale('en', 'US'));
  /// final weekdays = l10n.weekdayNames; // ['Su', 'Mo', 'Tu', ...]
  /// ```
  List<String> get weekdayNames =>
      _weekdayNames[locale.languageCode] ?? _weekdayNames['en']!;

  /// Gets the preferred first day of week for the current locale
  ///
  /// Returns the day of the week that should be displayed as the first column
  /// in calendar views. Follows cultural conventions:
  /// - Western locales typically start with Sunday (0)
  /// - Many international locales start with Monday (1)
  ///
  /// Example:
  /// ```dart
  /// final l10n = FlickerL10n(Locale('zh', 'CN'));
  /// final firstDay = l10n.firstDayOfWeek; // 1 (Monday)
  /// ```
  int get firstDayOfWeek => _firstDayOfWeek[locale.languageCode] ?? 0;

  /// Gets the appropriate month-year format pattern for the current locale
  ///
  /// Returns a format string suitable for use with DateFormat to display
  /// month and year information in a culturally appropriate way:
  /// - **English**: "MMMM yyyy" (e.g., "January 2024")
  /// - **Chinese**: "yyyy年MM月" (e.g., "2024年01月")
  ///
  /// Example:
  /// ```dart
  /// final l10n = FlickerL10n(Locale('zh', 'CN'));
  /// final format = l10n.monthYearFormat; // "yyyy年MM月"
  /// ```
  String get monthYearFormat {
    switch (locale.languageCode) {
      case 'zh':
        return 'yyyy年MM月';
      default:
        return 'MMMM yyyy';
    }
  }

  String formatMonth(DateTime date) {
    final formatter = DateFormat(monthYearFormat, locale.toString());
    return formatter.format(date);
  }

  /// Gets localized weekday names based on the first day of week setting
  ///
  /// This method retrieves the weekday names from the localization context
  /// and reorders them according to the configured first day of the week.
  /// This ensures the calendar header displays days in the correct order.
  ///
  /// Example:
  /// - If firstDayOfWeek is 0 (Sunday): ["Sun", "Mon", "Tue", ...]
  /// - If firstDayOfWeek is 1 (Monday): ["Mon", "Tue", "Wed", ..., "Sun"]
  ///
  /// Parameters:
  /// - [firstDayOfWeek]: Build context for accessing localization
  ///
  /// Returns:
  /// - List of weekday names in the correct order for display
  List<String> getWeekNames(int firstDayOfWeek) {
    if (firstDayOfWeek == 0) return weekdayNames;
    return [
      ...weekdayNames.sublist(firstDayOfWeek),
      ...weekdayNames.sublist(0, firstDayOfWeek),
    ];
  }
}
