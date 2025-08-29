# Flutter Flicker API Documentation

## Overview

This document provides comprehensive API documentation for all public classes, enums, and functions exported by `lib/flicker.dart`. Flutter Flicker is a powerful and customizable date picker widget with support for multiple selection modes, internationalization, and extensive theming options.

## Table of Contents

- [Core Components](#core-components)
  - [Flicker Widget](#flicker-widget)
  - [FlickerSelectionMode](#flickerselectionmode)
  - [FlickerDayBuilder](#flickerdaybuilder)
- [Internationalization](#internationalization)
  - [FlickerL10n](#flickerl10n)
  - [FlickerL10nDelegate](#flickerl10ndelegate)
- [Theme System](#theme-system)
  - [FlickTheme](#flicktheme)
  - [FlickThemeData](#flickthemedata)
- [Extensions](#extensions)
  - [FirstDayOfWeek](#firstdayofweek)
- [Usage Examples](#usage-examples)
- [Migration Guide](#migration-guide)

---

## Core Components

### Flicker Widget

The main date picker widget that provides a comprehensive date selection interface.

#### Constructor

```dart
Flicker({
  Key? key,
  FlickerSelectionMode? mode = FlickerSelectionMode.single,
  List<DateTime> value = const [],
  DateTime? startDate,
  DateTime? endDate,
  bool Function(DateTime)? disabledDate,
  Function(List<DateTime>)? onValueChange,
  FlickerDayBuilder? dayBuilder,
  FirstDayOfWeek? firstDayOfWeek = FirstDayOfWeek.monday,
  FlickTheme? theme,
  int? viewCount = 1,
  bool? highlightToday,
  Axis? scrollDirection = Axis.horizontal,
})
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `mode` | `FlickerSelectionMode?` | `FlickerSelectionMode.single` | Selection mode determining how users can select dates |
| `value` | `List<DateTime>` | `const []` | Currently selected dates |
| `startDate` | `DateTime?` | `null` | Minimum selectable date (inclusive) |
| `endDate` | `DateTime?` | `null` | Maximum selectable date (inclusive) |
| `disabledDate` | `bool Function(DateTime)?` | `null` | Callback to determine if a specific date should be disabled |
| `onValueChange` | `Function(List<DateTime>)?` | `null` | Called when the selection changes |
| `dayBuilder` | `FlickerDayBuilder?` | `null` | Custom widget builder for day cells |
| `firstDayOfWeek` | `FirstDayOfWeek?` | `FirstDayOfWeek.monday` | Which day appears as the first column |
| `theme` | `FlickTheme?` | `null` | Custom theme configuration |
| `viewCount` | `int?` | `1` | Number of months to display simultaneously (1 or 2) |
| `highlightToday` | `bool?` | `null` | Whether to highlight today's date |
| `scrollDirection` | `Axis?` | `Axis.horizontal` | Scroll direction (horizontal or vertical) |

#### Key Features

- **Multiple Selection Modes**: Support for single, range, and multiple date selection
- **Custom Date Builders**: Complete control over day cell appearance
- **Flexible Layout**: Horizontal/vertical scrolling with multi-month display
- **Date Constraints**: Min/max date limits and custom disabled date logic
- **Theme Support**: Built-in light/dark themes with custom theme support
- **Internationalization**: Multi-language support with locale-aware formatting

#### Example Usage

```dart
Flicker(
  mode: FlickerSelectionMode.range,
  value: [DateTime(2024, 1, 1), DateTime(2024, 1, 15)],
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 12, 31),
  onValueChange: (dates) {
    print('Selected dates: $dates');
  },
  theme: FlickTheme(useDarkMode: true),
  viewCount: 2,
  scrollDirection: Axis.horizontal,
)
```

---

### FlickerSelectionMode

Enum defining the date selection behavior of the calendar.

```dart
enum FlickerSelectionMode {
  /// Single date selection - user can select only one date
  single,
  
  /// Date range selection - user can select a start and end date
  range,
  
  /// Multiple date selection - user can select multiple individual dates
  many,
}
```

#### Values

- **`single`**: Allows selection of only one date at a time
- **`range`**: Allows selection of a date range (start and end date)
- **`many`**: Allows selection of multiple individual dates

#### Usage Examples

```dart
// Single date selection
Flicker(
  mode: FlickerSelectionMode.single,
  onValueChange: (dates) {
    if (dates.isNotEmpty) {
      print('Selected date: ${dates.first}');
    }
  },
)

// Range selection
Flicker(
  mode: FlickerSelectionMode.range,
  onValueChange: (dates) {
    if (dates.length == 2) {
      print('Range: ${dates.first} to ${dates.last}');
    }
  },
)

// Multiple selection
Flicker(
  mode: FlickerSelectionMode.many,
  onValueChange: (dates) {
    print('Selected ${dates.length} dates: $dates');
  },
)
```

---

### FlickerDayBuilder

Type definition for custom day cell builders, allowing complete customization of individual day cells.

```dart
typedef FlickerDayBuilder = Widget Function(
  int index,
  DateTime? date, {
  bool? selected,
  bool? disabled,
  bool? isInRange,
  bool? isRangeStart,
  bool? isRangeEnd,
  bool? isToday,
});
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | `int` | Cell index in the grid (0-41 for a 6-week view) |
| `date` | `DateTime?` | Cell date, may be null for empty cells |
| `selected` | `bool?` | Whether this date is currently selected |
| `disabled` | `bool?` | Whether this date is disabled |
| `isInRange` | `bool?` | In range mode, whether this date is within the selected range |
| `isRangeStart` | `bool?` | Whether this date is the start of a range |
| `isRangeEnd` | `bool?` | Whether this date is the end of a range |
| `isToday` | `bool?` | Whether this date is today |

#### Example Implementation

```dart
Widget customDayBuilder(
  int index,
  DateTime? date, {
  bool? selected,
  bool? disabled,
  bool? isInRange,
  bool? isRangeStart,
  bool? isRangeEnd,
  bool? isToday,
}) {
  if (date == null) {
    return const SizedBox.shrink();
  }

  Color? backgroundColor;
  Color textColor = Colors.black;
  
  if (selected == true) {
    backgroundColor = Colors.blue;
    textColor = Colors.white;
  } else if (isInRange == true) {
    backgroundColor = Colors.blue.withOpacity(0.3);
  } else if (isToday == true) {
    backgroundColor = Colors.orange.withOpacity(0.3);
  }
  
  if (disabled == true) {
    textColor = Colors.grey;
    backgroundColor = null;
  }

  return Container(
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      border: isToday == true ? Border.all(color: Colors.orange, width: 2) : null,
    ),
    child: Center(
      child: Text(
        '${date.day}',
        style: TextStyle(
          color: textColor,
          fontWeight: isToday == true ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}

// Usage
Flicker(
  dayBuilder: customDayBuilder,
  // ... other parameters
)
```

---

## Internationalization

### FlickerL10n

Localization class providing multi-language support for the date picker.

#### Static Properties

```dart
static const FlickerL10n defaultL10n = FlickerL10n(Locale('en', 'US'));
static const LocalizationsDelegate<FlickerL10n> delegate = FlickerL10nDelegate();
static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [...];
static const List<Locale> supportedLocales = [...];
```

#### Instance Properties

| Property | Type | Description |
|----------|------|-------------|
| `locale` | `Locale` | Current locale |
| `monthNames` | `List<String>` | Localized month names |
| `weekdayNames` | `List<String>` | Localized weekday abbreviations |
| `firstDayOfWeek` | `int` | Locale-specific first day of week (0=Sunday, 1=Monday) |
| `monthYearFormat` | `String` | Locale-specific month-year format pattern |

#### Static Methods

##### `of(BuildContext context)`
Retrieves the FlickerL10n instance from the current context.

```dart
static FlickerL10n? of(BuildContext context)
```

##### `maybeOf(BuildContext context)`
Retrieves the FlickerL10n instance with fallback to default.

```dart
static FlickerL10n maybeOf(BuildContext context)
```

#### Supported Languages

- **English** (`en`): English (US, GB, CA, AU)
- **Chinese** (`zh`): Simplified and Traditional Chinese (CN, TW)
- **Spanish** (`es`): Spanish (ES, MX)
- **French** (`fr`): French (FR, CA)
- **German** (`de`): German (DE, AT)
- **Japanese** (`ja`): Japanese (JP)
- **Korean** (`ko`): Korean (KR)

#### Usage Example

```dart
// In your app's main.dart
MaterialApp(
  localizationsDelegates: FlickerL10n.localizationsDelegates,
  supportedLocales: FlickerL10n.supportedLocales,
  // ... other app configuration
)

// Accessing localization in widgets
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = FlickerL10n.maybeOf(context);
    final monthNames = l10n.monthNames;
    final weekdayNames = l10n.weekdayNames;
    
    return Flicker(
      firstDayOfWeek: FirstDayOfWeek.locale, // Uses l10n.firstDayOfWeek
      // ... other parameters
    );
  }
}
```

---

### FlickerL10nDelegate

Localization delegate for integrating with Flutter's localization system.

```dart
class FlickerL10nDelegate extends LocalizationsDelegate<FlickerL10n>
```

#### Methods

##### `isSupported(Locale locale)`
Checks if the given locale is supported.

```dart
bool isSupported(Locale locale)
```

##### `load(Locale locale)`
Loads the localization for the given locale.

```dart
Future<FlickerL10n> load(Locale locale)
```

##### `shouldReload(FlickerL10nDelegate old)`
Determines if the delegate should reload.

```dart
bool shouldReload(FlickerL10nDelegate old) // Returns false
```

---

## Theme System

### FlickTheme

Theme manager for customizing the appearance of Flicker components.

#### Constructor

```dart
FlickTheme({
  bool? useDarkMode,
  FlickThemeData? custom,
})
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `useDarkMode` | `bool?` | Whether to use dark theme (null follows system) |
| `custom` | `FlickThemeData?` | Custom theme data override |

#### Properties

##### `data`
Returns the current theme data based on configuration.

```dart
FlickThemeData get data
```

#### Methods

##### `getDayStyle({required bool selected, bool? enabled, bool? highlightToday})`
Returns text style for day cells.

```dart
TextStyle getDayStyle({
  required bool selected,
  bool? enabled,
  bool? highlightToday,
})
```

##### `getDayDecoration({...})`
Returns decoration for day cells.

```dart
BoxDecoration? getDayDecoration({
  bool? selected,
  bool? enabled,
  bool? highlightToday,
  bool? inRange,
  bool? isRangeStart,
  bool? isRangeEnd,
})
```

#### Usage Examples

```dart
// Light theme
Flicker(
  theme: FlickTheme(useDarkMode: false),
)

// Dark theme
Flicker(
  theme: FlickTheme(useDarkMode: true),
)

// System theme (follows device setting)
Flicker(
  theme: FlickTheme(), // useDarkMode: null
)

// Custom theme
Flicker(
  theme: FlickTheme(
    custom: FlickThemeData.custom(
      primaryColor: Colors.purple,
      backgroundColor: Colors.grey[100],
      // ... other custom properties
    ),
  ),
)
```

---

### FlickThemeData

Data class containing all theme-related styling information.

#### Factory Constructors

```dart
// Light theme
FlickThemeData.light()

// Dark theme
FlickThemeData.dark()

// Custom theme
FlickThemeData.custom({
  Color? primaryColor,
  Color? backgroundColor,
  Color? textColor,
  Color? disabledColor,
  Color? selectedColor,
  Color? todayColor,
  Color? rangeColor,
  TextStyle? dayTextStyle,
  TextStyle? headerTextStyle,
  BoxDecoration? decoration,
  // ... other properties
})
```

#### Key Properties

| Property | Type | Description |
|----------|------|-------------|
| `primaryColor` | `Color` | Primary accent color |
| `backgroundColor` | `Color` | Background color |
| `textColor` | `Color` | Default text color |
| `selectedColor` | `Color` | Selected date background color |
| `disabledColor` | `Color` | Disabled date color |
| `todayColor` | `Color` | Today highlight color |
| `rangeColor` | `Color` | Range selection color |
| `dayTextStyle` | `TextStyle` | Base text style for day cells |
| `headerTextStyle` | `TextStyle` | Text style for headers |
| `decoration` | `BoxDecoration` | Container decoration |

#### Methods

##### `getDayTextStyle(bool selected, bool? enabled, bool? highlightToday)`
Returns appropriate text style for day cells based on state.

##### `getDayDecoration({...})`
Returns appropriate decoration for day cells based on state.

---

## Extensions

### FirstDayOfWeek

Enum defining which day appears as the first column in the calendar.

```dart
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
```

#### Values

- **`sunday`**: Week starts on Sunday (common in US, Japan, Korea)
- **`monday`**: Week starts on Monday (common in Europe, China)
- **`saturday`**: Week starts on Saturday (common in Middle East)
- **`locale`**: Uses the locale-specific first day from `FlickerL10n`

#### Usage Examples

```dart
// Explicit first day
Flicker(
  firstDayOfWeek: FirstDayOfWeek.monday,
)

// Locale-based first day
Flicker(
  firstDayOfWeek: FirstDayOfWeek.locale, // Uses FlickerL10n.firstDayOfWeek
)

// US-style calendar (Sunday first)
Flicker(
  firstDayOfWeek: FirstDayOfWeek.sunday,
)
```

---

## Usage Examples

### Basic Single Date Picker

```dart
class BasicDatePicker extends StatefulWidget {
  @override
  _BasicDatePickerState createState() => _BasicDatePickerState();
}

class _BasicDatePickerState extends State<BasicDatePicker> {
  List<DateTime> selectedDates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Basic Date Picker')),
      body: Column(
        children: [
          Flicker(
            mode: FlickerSelectionMode.single,
            value: selectedDates,
            onValueChange: (dates) {
              setState(() {
                selectedDates = dates;
              });
            },
            highlightToday: true,
          ),
          if (selectedDates.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Selected: ${selectedDates.first.toString().split(' ')[0]}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
```

### Date Range Picker with Constraints

```dart
class DateRangePicker extends StatefulWidget {
  @override
  _DateRangePickerState createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  List<DateTime> selectedRange = [];
  final DateTime minDate = DateTime.now();
  final DateTime maxDate = DateTime.now().add(Duration(days: 90));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Date Range Picker')),
      body: Column(
        children: [
          Flicker(
            mode: FlickerSelectionMode.range,
            value: selectedRange,
            startDate: minDate,
            endDate: maxDate,
            onValueChange: (dates) {
              setState(() {
                selectedRange = dates;
              });
            },
            disabledDate: (date) {
              // Disable weekends
              return date.weekday == DateTime.saturday || 
                     date.weekday == DateTime.sunday;
            },
            theme: FlickTheme(useDarkMode: false),
            viewCount: 2,
          ),
          if (selectedRange.length == 2)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Range: ${selectedRange.first.toString().split(' ')[0]} to ${selectedRange.last.toString().split(' ')[0]}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
```

### Custom Styled Date Picker

```dart
class CustomStyledDatePicker extends StatefulWidget {
  @override
  _CustomStyledDatePickerState createState() => _CustomStyledDatePickerState();
}

class _CustomStyledDatePickerState extends State<CustomStyledDatePicker> {
  List<DateTime> selectedDates = [];
  final List<DateTime> holidays = [
    DateTime(2024, 12, 25), // Christmas
    DateTime(2024, 1, 1),   // New Year
  ];

  Widget customDayBuilder(
    int index,
    DateTime? date, {
    bool? selected,
    bool? disabled,
    bool? isInRange,
    bool? isRangeStart,
    bool? isRangeEnd,
    bool? isToday,
  }) {
    if (date == null) return const SizedBox.shrink();

    final isHoliday = holidays.any((holiday) => 
        holiday.year == date.year && 
        holiday.month == date.month && 
        holiday.day == date.day);
    
    final isWeekend = date.weekday == DateTime.saturday || 
                      date.weekday == DateTime.sunday;

    Color? backgroundColor;
    Color textColor = Colors.black;
    
    if (selected == true) {
      backgroundColor = Colors.purple;
      textColor = Colors.white;
    } else if (isToday == true) {
      backgroundColor = Colors.orange.withOpacity(0.3);
    } else if (isHoliday) {
      backgroundColor = Colors.red.withOpacity(0.2);
      textColor = Colors.red[800]!;
    } else if (isWeekend) {
      textColor = Colors.grey[600]!;
    }
    
    if (disabled == true) {
      textColor = Colors.grey[400]!;
      backgroundColor = null;
    }

    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday == true 
            ? Border.all(color: Colors.orange, width: 2) 
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isToday == true ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            if (isHoliday)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Styled Date Picker')),
      body: Flicker(
        mode: FlickerSelectionMode.many,
        value: selectedDates,
        dayBuilder: customDayBuilder,
        onValueChange: (dates) {
          setState(() {
            selectedDates = dates;
          });
        },
        firstDayOfWeek: FirstDayOfWeek.monday,
        highlightToday: true,
      ),
    );
  }
}
```

### Internationalized Date Picker

```dart
class InternationalDatePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Add Flicker localization support
      localizationsDelegates: FlickerL10n.localizationsDelegates,
      supportedLocales: FlickerL10n.supportedLocales,
      
      home: Scaffold(
        appBar: AppBar(title: Text('International Date Picker')),
        body: Flicker(
          mode: FlickerSelectionMode.single,
          firstDayOfWeek: FirstDayOfWeek.locale, // Uses locale-specific first day
          onValueChange: (dates) {
            if (dates.isNotEmpty) {
              final l10n = FlickerL10n.maybeOf(context);
              final monthName = l10n.monthNames[dates.first.month - 1];
              print('Selected: ${dates.first.day} $monthName ${dates.first.year}');
            }
          },
        ),
      ),
    );
  }
}
```

---

## Migration Guide

### From Previous Versions

If you're upgrading from a previous version of Flutter Flicker, here are the key changes:

#### Breaking Changes

1. **Import Path**: All exports are now consolidated in `lib/flicker.dart`
   ```dart
   // Old
   import 'package:flutter_flicker/src/views/flicker.dart';
   import 'package:flutter_flicker/src/theme/theme.dart';
   
   // New
   import 'package:flutter_flicker/flicker.dart';
   ```

2. **Theme System**: Theme configuration has been simplified
   ```dart
   // Old
   FlickerTheme(
     data: FlickerThemeData.dark(),
     child: Flicker(...),
   )
   
   // New
   Flicker(
     theme: FlickTheme(useDarkMode: true),
     // ... other parameters
   )
   ```

3. **Localization**: Simplified localization setup
   ```dart
   // Old
   MaterialApp(
     localizationsDelegates: [
       FlickerL10nDelegate(),
       // ... other delegates
     ],
   )
   
   // New
   MaterialApp(
     localizationsDelegates: FlickerL10n.localizationsDelegates,
     supportedLocales: FlickerL10n.supportedLocales,
   )
   ```

#### New Features

- **Enhanced Performance**: Improved caching and rendering performance
- **Better Accessibility**: Enhanced screen reader support
- **More Locales**: Extended language support
- **Custom Day Builders**: More flexible day cell customization
- **Theme Improvements**: Better dark mode support and custom theming

---

## Best Practices

### Performance

1. **Use appropriate selection modes**: Choose the most restrictive mode that meets your needs
2. **Implement efficient day builders**: Keep custom day builders simple and avoid heavy computations
3. **Set reasonable date ranges**: Avoid extremely large date ranges that might impact performance
4. **Cache disabled date logic**: If using complex disabled date logic, consider caching results

### User Experience

1. **Provide visual feedback**: Use `highlightToday` and custom styling to guide users
2. **Handle edge cases**: Validate selected dates and handle empty selections gracefully
3. **Consider accessibility**: Ensure custom day builders maintain accessibility features
4. **Use appropriate themes**: Choose themes that match your app's design language

### Code Organization

1. **Separate concerns**: Keep date selection logic separate from UI logic
2. **Use state management**: For complex apps, consider using state management solutions
3. **Handle errors gracefully**: Implement proper error handling for date operations
4. **Document custom builders**: Clearly document any custom day builder implementations

---

## Support and Resources

- **GitHub Repository**: [flutter_flicker](https://github.com/Fi2zz/flutter_flicker)
- **Issue Tracker**: [GitHub Issues](https://github.com/Fi2zz/flutter_flicker/issues)
- **Documentation**: [Usage Guide](usage_guide.md)
- **Examples**: Check the `/example` directory in the repository

For questions, bug reports, or feature requests, please use the GitHub issue tracker.