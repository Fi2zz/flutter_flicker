import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/flicker.dart';
import 'package:flutter_flicker/src/theme/theme.dart';

/// Configuration for the first day of the week
///
/// Defines which day appears as the first column in the calendar grid
/// Supports different regional conventions
enum FirstDayOfWeek {
  /// Sunday as first day (US, Japan, Korea)
  sunday,

  /// Monday as first day (Europe, China)
  monday,

  /// Saturday as first day (Middle East)
  saturday,

  /// Use locale-specific first day (default)
  locale,
}

extension FlickerExtension on BuildContext {
  FlickerL10n get flickerL10n {
    return FlickerL10n.maybeOf(this);
  }

  FlickThemeData get flickerTheme {
    return FlickThemeContext.of(this) ?? FlickThemeData.light();
  }

  /// Gets the numeric first day of week (0=Monday, 6=Sunday)
  ///
  /// [context] - Build context for localization
  /// [firstDayOfWeek] - Optional override for the first day setting
  int getFirstDayOfWeek(FirstDayOfWeek? firstDayOfWeek) {
    return switch (firstDayOfWeek) {
      FirstDayOfWeek.monday => 1,
      FirstDayOfWeek.saturday => 6,
      FirstDayOfWeek.locale => () {
        final l10n = flickerL10n;
        return l10n.firstDayOfWeek;
      }(),
      FirstDayOfWeek.sunday => 0,
      null => 0,
    };
  }
}
