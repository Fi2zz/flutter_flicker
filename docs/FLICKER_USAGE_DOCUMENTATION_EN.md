# Flicker Date Picker Usage Documentation

Flicker is a highly customizable and performant Flutter date picker widget that supports multiple selection modes, custom styling, and flexible layouts.

## Table of Contents

- [Core Features](#core-features)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
- [Selection Modes](#selection-modes)
- [Theme Configuration](#theme-configuration)
- [Advanced Usage](#advanced-usage)
- [Example Code](#example-code)

## Core Features

### 🎯 Selection Modes

- **Single**: Select one date at a time
- **Range**: Select a continuous date range
- **Multiple**: Select multiple individual dates

### 🎨 Customization

- Custom day cell builders for complete UI control
- Comprehensive theme system with light/dark modes
- Disabled date support with validation callbacks
- Flexible layout options (horizontal/vertical scrolling)
- Multi-month display (1 or 2 months simultaneously)

### 🌍 Internationalization

- Locale-aware date formatting
- Configurable first day of week

## Quick Start

### Basic Installation

```dart
import 'package:flutter_flicker/flutter_flicker.dart';
```

### Simplest Usage

```dart
Flicker(
  onValueChange: (dates) {
    print('Selected dates: $dates');
  },
)
```

## API Reference

### Constructor Parameters

| Parameter         | Type                        | Default                 | Description                          |
| ----------------- | --------------------------- | ----------------------- | ------------------------------------ |
| `mode`            | `SelectionMode?`            | `SelectionMode.single`  | Selection mode                       |
| `value`           | `List<DateTime>`            | `[]`                    | Currently selected dates             |
| `startDate`       | `DateTime?`                 | `null`                  | Minimum selectable date (inclusive)  |
| `endDate`         | `DateTime?`                 | `null`                  | Maximum selectable date (inclusive)  |
| `disabledDate`    | `bool Function(DateTime)?`  | `null`                  | Function to determine disabled dates |
| `onValueChange`   | `Function(List<DateTime>)?` | `null`                  | Selection change callback            |
| `dayBuilder`      | `DayBuilder?`               | `null`                  | Custom day cell builder              |
| `firstDayOfWeek`  | `FirstDayOfWeek?`           | `FirstDayOfWeek.monday` | First day of the week                |
| `theme`           | `FlickerTheme?`             | `null`                  | Custom theme configuration           |
| `viewCount`       | `int?`                      | `1`                     | Number of months to display          |
| `scrollDirection` | `Axis?`                     | `Axis.horizontal`       | Scroll direction                     |
| `selectionCount`  | `int?`                      | `null`                  | Selection count limit                |

## Selection Modes

### SelectionMode.single - Single Selection

Select only one date at a time. Selecting a new date automatically deselects the previous one.

```dart
Flicker(
  mode: SelectionMode.single,
  value: [DateTime.now()],
  onValueChange: (dates) {
    if (dates.isNotEmpty) {
      print('Selected date: ${dates.first}');
    }
  },
)
```

**Use Cases:**

- Birthday selection
- Appointment scheduling
- Simple date input forms

### SelectionMode.range - Range Selection

Select a continuous range of dates by choosing start and end dates.

```dart
Flicker(
  mode: SelectionMode.range,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 365)),
  disabledDate: (date) => date.weekday == DateTime.sunday,
  onValueChange: (dates) {
    if (dates.length == 2) {
      print('Date range: ${dates.first} to ${dates.last}');
    }
  },
)
```

**Use Cases:**

- Hotel booking date ranges
- Vacation planning
- Report date ranges
- Event duration selection

### SelectionMode.many - Multiple Selection

Select multiple individual dates that don't need to be continuous. Each date can be selected or deselected independently.

```dart
Flicker(
  mode: SelectionMode.many,
  selectionCount: 5, // Limit to maximum 5 dates
  onValueChange: (dates) {
    print('Selected dates: $dates');
  },
)
```

**Use Cases:**

- Meeting availability
- Multiple event dates
- Flexible scheduling
- Custom date collections

## Theme Configuration

### FirstDayOfWeek - First Day Configuration

```dart
enum FirstDayOfWeek {
  sunday,    // Sunday start (US, Japan, Korea, etc.)
  monday,    // Monday start (Europe, China, etc., ISO 8601 standard)
  saturday,  // Saturday start (some Middle Eastern countries)
  locale,    // Automatically determined by system locale
}
```

### FlickerTheme - Theme Management

```dart
// Automatically follow system theme
final autoTheme = FlickerTheme();

// Force light theme
final lightTheme = FlickerTheme(useDarkMode: false);

// Force dark theme
final darkTheme = FlickerTheme(useDarkMode: true);

// Custom theme data
final customTheme = FlickerTheme(
  themeData: FlickThemeData(
    dayTextStyle: TextStyle(color: Colors.purple),
    daySelectedDecoration: BoxDecoration(
      color: Colors.purple,
      shape: BoxShape.circle,
    ),
  ),
);
```

## Advanced Usage

### Custom Day Cell Builder

```dart
Flicker(
  dayBuilder: (context, date, isSelected, isDisabled) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        shape: BoxShape.circle,
        border: isDisabled ? Border.all(color: Colors.grey) : null,
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
)
```

### Disable Specific Dates

```dart
Flicker(
  disabledDate: (date) {
    // Disable weekends
    if (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday) {
      return true;
    }

    // Disable past dates
    if (date.isBefore(DateTime.now())) {
      return true;
    }

    // Disable specific dates
    final disabledDates = [
      DateTime(2024, 12, 25), // Christmas
      DateTime(2024, 1, 1),   // New Year
    ];

    return disabledDates.any((disabled) =>
      date.year == disabled.year &&
      date.month == disabled.month &&
      date.day == disabled.day
    );
  },
)
```

### Multi-Month View Configuration

```dart
// Horizontal dual-month view
Flicker(
  viewCount: 2,
  scrollDirection: Axis.horizontal,
)

// Vertical dual-month view
Flicker(
  viewCount: 2,
  scrollDirection: Axis.vertical,
)
```

## Example Code

### Complete Hotel Booking Example

```dart
class HotelBookingCalendar extends StatefulWidget {
  @override
  _HotelBookingCalendarState createState() => _HotelBookingCalendarState();
}

class _HotelBookingCalendarState extends State<HotelBookingCalendar> {
  List<DateTime> selectedDates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Check-in and Check-out Dates')),
      body: Column(
        children: [
          // Display selected date range
          if (selectedDates.length == 2)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Check-in: ${_formatDate(selectedDates.first)}\n'
                'Check-out: ${_formatDate(selectedDates.last)}',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

          // Date picker
          Expanded(
            child: Flicker(
              mode: SelectionMode.range,
              value: selectedDates,
              startDate: DateTime.now(),
              endDate: DateTime.now().add(Duration(days: 365)),
              firstDayOfWeek: FirstDayOfWeek.monday,
              theme: FlickerTheme(useDarkMode: false),
              viewCount: 2,
              scrollDirection: Axis.vertical,
              disabledDate: (date) {
                // Disable past dates
                return date.isBefore(DateTime.now().subtract(Duration(days: 1)));
              },
              onValueChange: (dates) {
                setState(() {
                  selectedDates = dates;
                });
              },
            ),
          ),

          // Confirm button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedDates.length == 2 ? _confirmBooking : null,
              child: Text('Confirm Booking'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _confirmBooking() {
    // Handle booking logic
    print('Booking confirmed: ${selectedDates.first} to ${selectedDates.last}');
  }
}
```

### Meeting Availability Picker Example

```dart
class MeetingAvailabilityPicker extends StatefulWidget {
  @override
  _MeetingAvailabilityPickerState createState() => _MeetingAvailabilityPickerState();
}

class _MeetingAvailabilityPickerState extends State<MeetingAvailabilityPicker> {
  List<DateTime> availableDates = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Select your available dates (max 5 days)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),

        Flicker(
          mode: SelectionMode.many,
          value: availableDates,
          selectionCount: 5,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 60)),
          firstDayOfWeek: FirstDayOfWeek.monday,
          disabledDate: (date) {
            // Disable weekends
            return date.weekday == DateTime.saturday ||
                   date.weekday == DateTime.sunday;
          },
          onValueChange: (dates) {
            setState(() {
              availableDates = dates;
            });
          },
          dayBuilder: (context, date, isSelected, isDisabled) {
            return Container(
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.green
                    : isDisabled
                        ? Colors.grey.shade300
                        : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isDisabled
                            ? Colors.grey
                            : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 16),
        Text(
          'Selected ${availableDates.length}/5 days',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
```

---

This documentation covers the main features and usage patterns of the Flicker date picker. For more detailed information, please refer to the comments and examples in the source code.
