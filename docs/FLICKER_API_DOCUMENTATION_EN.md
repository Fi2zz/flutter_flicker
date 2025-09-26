# Flicker API Documentation

## Overview

Flicker is a highly customizable Flutter date picker component that provides multiple selection modes and rich customization options.

## Core Components

### Flicker

The main date picker component.

```dart
class Flicker extends StatelessWidget
```

#### Constructor

```dart
const Flicker({
  Key? key,
  SelectionMode? mode = SelectionMode.single,
  List<DateTime> value = const [],
  DateTime? startDate,
  DateTime? endDate,
  bool Function(DateTime)? disabledDate,
  Function(List<DateTime>)? onValueChange,
  DayBuilder? dayBuilder,
  FirstDayOfWeek? firstDayOfWeek = FirstDayOfWeek.monday,
  FlickerTheme? theme,
  int? viewCount = 1,
  Axis? scrollDirection = Axis.horizontal,
  int? selectionCount,
})
```

#### Parameter Details

| Parameter         | Type                        | Default                 | Required | Description                                                 |
| ----------------- | --------------------------- | ----------------------- | -------- | ----------------------------------------------------------- |
| `key`             | `Key?`                      | `null`                  | No       | Unique identifier for the widget                            |
| `mode`            | `SelectionMode?`            | `SelectionMode.single`  | No       | Selection mode: single, range, or multiple                  |
| `value`           | `List<DateTime>`            | `const []`              | No       | List of currently selected dates                            |
| `startDate`       | `DateTime?`                 | `null`                  | No       | Minimum selectable date (inclusive)                         |
| `endDate`         | `DateTime?`                 | `null`                  | No       | Maximum selectable date (inclusive)                         |
| `disabledDate`    | `bool Function(DateTime)?`  | `null`                  | No       | Callback to determine if a specific date should be disabled |
| `onValueChange`   | `Function(List<DateTime>)?` | `null`                  | No       | Callback when selected dates change                         |
| `dayBuilder`      | `DayBuilder?`               | `null`                  | No       | Custom builder for date cells                               |
| `firstDayOfWeek`  | `FirstDayOfWeek?`           | `FirstDayOfWeek.monday` | No       | First day of the week configuration                         |
| `theme`           | `FlickerTheme?`             | `null`                  | No       | Custom theme configuration                                  |
| `viewCount`       | `int?`                      | `1`                     | No       | Number of months to display simultaneously (1 or 2)         |
| `scrollDirection` | `Axis?`                     | `Axis.horizontal`       | No       | Scroll direction: horizontal or vertical                    |
| `selectionCount`  | `int?`                      | `null`                  | No       | Maximum number of selections in multiple mode               |

## Enum Types

### SelectionMode

Defines the behavior mode for date selection.

```dart
enum SelectionMode {
  /// Single selection mode: only one date can be selected at a time
  single,

  /// Range selection mode: select a continuous date range
  range,

  /// Multiple selection mode: select multiple independent dates
  many,
}
```

#### Mode Descriptions

- **`single`**:

  - Behavior: Only one date can be selected at a time, selecting a new date automatically deselects the previous one
  - Return value: `List<DateTime>` containing 0 or 1 date
  - Use cases: Birthday selection, appointment scheduling, simple date input

- **`range`**:

  - Behavior: Select a continuous date range by choosing start and end dates
  - Return value: `List<DateTime>` containing 0, 1, or 2 dates (start and end)
  - Use cases: Hotel booking, vacation planning, report date ranges

- **`many`**:
  - Behavior: Select multiple independent dates, each date can be independently selected or deselected
  - Return value: `List<DateTime>` containing 0 or more dates
  - Use cases: Meeting availability, multi-event dates, flexible scheduling

### FirstDayOfWeek

Configure the first day of the week display.

```dart
enum FirstDayOfWeek {
  /// Sunday as the first day of the week (US, Japan, Korea, etc.)
  sunday,

  /// Monday as the first day of the week (Europe, China, etc., ISO 8601 standard)
  monday,

  /// Saturday as the first day of the week (some Middle Eastern countries)
  saturday,

  /// Automatically determined based on system locale settings
  locale,
}
```

## Callback Function Types

### DayBuilder

Type definition for custom date cell builder.

```dart
typedef DayBuilder = Widget Function(
  BuildContext context,
  DateTime date,
  bool isSelected,
  bool isDisabled,
);
```

#### Parameter Description

- `context`: Build context
- `date`: Current date
- `isSelected`: Whether the date is selected
- `isDisabled`: Whether the date is disabled

#### Usage Example

```dart
DayBuilder customDayBuilder = (context, date, isSelected, isDisabled) {
  return Container(
    decoration: BoxDecoration(
      color: isSelected ? Colors.blue : Colors.transparent,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        '${date.day}',
        style: TextStyle(
          color: isDisabled ? Colors.grey : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
};
```

### Disabled Date Callback

```dart
typedef DisabledDateCallback = bool Function(DateTime date);
```

Used to determine if a specific date should be disabled.

#### Usage Example

```dart
bool disabledDateCallback(DateTime date) {
  // Disable weekends
  if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
    return true;
  }

  // Disable past dates
  if (date.isBefore(DateTime.now())) {
    return true;
  }

  return false;
}
```

### Value Change Callback

```dart
typedef ValueChangeCallback = Function(List<DateTime> selectedDates);
```

Called when selected dates change.

#### Usage Example

```dart
void onValueChange(List<DateTime> selectedDates) {
  print('Selected dates: $selectedDates');

  switch (mode) {
    case SelectionMode.single:
      if (selectedDates.isNotEmpty) {
        print('Selected date: ${selectedDates.first}');
      }
      break;
    case SelectionMode.range:
      if (selectedDates.length == 2) {
        print('Date range: ${selectedDates.first} to ${selectedDates.last}');
      }
      break;
    case SelectionMode.many:
      print('Selected ${selectedDates.length} dates');
      break;
  }
}
```

## Theme System

### FlickerTheme

Theme management class for configuring the date picker's appearance.

```dart
class FlickerTheme {
  const FlickerTheme({
    this.useDarkMode,
    this.themeData,
  });

  final bool? useDarkMode;
  final FlickThemeData? themeData;
}
```

#### Parameter Description

- `useDarkMode`:

  - `true`: Force dark theme
  - `false`: Force light theme
  - `null`: Automatically follow system theme (default)

- `themeData`: Custom theme data that overrides default theme

#### Usage Example

```dart
// Auto theme
FlickerTheme autoTheme = FlickerTheme();

// Light theme
FlickerTheme lightTheme = FlickerTheme(useDarkMode: false);

// Dark theme
FlickerTheme darkTheme = FlickerTheme(useDarkMode: true);

// Custom theme
FlickerTheme customTheme = FlickerTheme(
  themeData: FlickThemeData(
    dayTextStyle: TextStyle(color: Colors.purple),
    daySelectedDecoration: BoxDecoration(
      color: Colors.purple,
      shape: BoxShape.circle,
    ),
  ),
);
```

## Usage Examples

### Basic Usage

```dart
Flicker(
  mode: SelectionMode.single,
  onValueChange: (dates) {
    print('Selected dates: $dates');
  },
)
```

### Range Selection

```dart
Flicker(
  mode: SelectionMode.range,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 365)),
  onValueChange: (dates) {
    if (dates.length == 2) {
      print('Selected range: ${dates.first} to ${dates.last}');
    }
  },
)
```

### Multiple Selection Mode

```dart
Flicker(
  mode: SelectionMode.many,
  selectionCount: 5,
  disabledDate: (date) => date.weekday == DateTime.sunday,
  onValueChange: (dates) {
    print('Selected ${dates.length} dates');
  },
)
```

### Custom Theme

```dart
Flicker(
  theme: FlickerTheme(useDarkMode: true),
  firstDayOfWeek: FirstDayOfWeek.monday,
  viewCount: 2,
  scrollDirection: Axis.vertical,
)
```

### Fully Customized

```dart
Flicker(
  mode: SelectionMode.range,
  value: selectedDates,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 365)),
  firstDayOfWeek: FirstDayOfWeek.monday,
  viewCount: 2,
  scrollDirection: Axis.vertical,
  selectionCount: 10,
  theme: FlickerTheme(useDarkMode: false),
  disabledDate: (date) {
    return date.weekday == DateTime.saturday ||
           date.weekday == DateTime.sunday;
  },
  dayBuilder: (context, date, isSelected, isDisabled) {
    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: isDisabled ? Colors.grey : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  },
  onValueChange: (dates) {
    setState(() {
      selectedDates = dates;
    });
  },
)
```

---

This API documentation covers all public interfaces and usage methods of the Flicker component. For more detailed information, please refer to the source code comments.
