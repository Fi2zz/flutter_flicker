# Flicker

A powerful and customizable Flutter date picker widget with advanced features including date range selection, localization support, and theme customization.

## Features

### Current Implementation ✅

- **Multiple Selection Modes** - Support for single, range, multiple, and basic date selection modes
- **Flexible Layout Options** - Horizontal and vertical scrolling directions
- **Multi-Month Views** - Single or double month display options
- **Theme Customization** - Built-in dark/light mode switching with FlickTheme
- **First Day of Week Configuration** - Configurable week start day (Monday, Sunday, Saturday, or locale-based)
- **Date Range Constraints** - Limit selectable dates with startDate/endDate parameters
- **Custom Date Disabling** - Flexible date disabling rules with custom functions
- **Today Highlighting** - Optional highlighting of current date
- **Real-time Selection Display** - Live updates of selected dates
- **Responsive Design** - Adaptive UI that works across different screen sizes
- **Interactive Demo** - Comprehensive demo application with all feature controls
- **Keyboard Navigation Support** - Complete keyboard operation support with Tab, arrow keys, Enter/Space, and Escape
- **Accessibility Support** - Full ARIA attributes, semantic labels, and screen reader compatibility

## Development Roadmap

### Phase 1: Core Feature Enhancement (High Priority)

### Phase 2: User Experience Optimization (Medium Priority)
- [ ] **Quick Action Buttons** - Today, clear, and other shortcut buttons
  - Today button for quick navigation
  - Clear selection button
  - Confirm/cancel buttons

### Phase 3: Advanced Features (Low Priority)

- [ ] **Time Picker Integration** - Integrated time selection functionality
  - Hour/minute/second selection
  - Time range constraints
  - Combined date-time selection
- [ ] **Holiday Marking** - Special date display and marking
  - Holiday data configuration
  - Special date styling
  - Custom marking functionality
- [ ] **Preset Options** - Quick time period selection
  - This week, month, quarter
  - Last 7 days, 30 days
  - Custom preset configuration

### Phase 4: Testing & Documentation (Low Priority)

- [ ] **Unit Testing** - Core functionality test coverage
- [ ] **Integration Testing** - User interaction flow testing
- [ ] **Usage Documentation** - API documentation and usage examples
- [ ] **Demo Application** - Feature demonstration app

## Technical Implementation

### Architecture Design

- State management for complex interactions
- Modular component design
- Extensible API interface

### Performance Optimization

- Lazy loading of month data
- Reduced unnecessary re-renders
- Optimized date calculation algorithms

### Compatibility

- Flutter 3.0+ support
- iOS/Android/Web platform compatibility
- Different screen density adaptation

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Installation

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Add flicker dependency here when published
```

## Usage

### Basic Single Date Selection

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_flicker/flicker.dart';

Flicker(
  mode: FlickerSelectionMode.single,
  value: [DateTime.now()],
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2025, 12, 31),
  onValueChange: (List<DateTime> dates) {
    print('Selected date: ${dates.first}');
  },
  theme: FlickTheme(useDarkMode: false),
  firstDayOfWeek: FirstDayOfWeek.monday,
)
```

### Date Range Selection

```dart
Flicker(
  mode: FlickerSelectionMode.range,
  value: [DateTime(2025, 8, 1), DateTime(2025, 8, 15)],
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2025, 12, 31),
  onValueChange: (List<DateTime> dates) {
    if (dates.length == 2) {
      print('Range: ${dates.first} to ${dates.last}');
    }
  },
  theme: FlickTheme(useDarkMode: true),
  viewCount: 2, // Show two months
  scrollDirection: Axis.horizontal,
)
```

### Multiple Date Selection

```dart
Flicker(
  mode: FlickerSelectionMode.many,
  value: [DateTime(2025, 8, 5), DateTime(2025, 8, 10), DateTime(2025, 8, 20)],
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2025, 12, 31),
  onValueChange: (List<DateTime> dates) {
    print('Selected ${dates.length} dates: $dates');
  },
  disabledDate: (DateTime date) {
    // Disable weekends
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  },
  theme: FlickTheme(useDarkMode: false),
  firstDayOfWeek: FirstDayOfWeek.sunday,
)
```

### Vertical Layout with Custom Styling

```dart
Flicker(
  mode: FlickerSelectionMode.single,
  value: [DateTime.now()],
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2025, 12, 31),
  onValueChange: (List<DateTime> dates) {
    // Handle date selection
  },
  scrollDirection: Axis.vertical,
  viewCount: 2,
  theme: FlickTheme(useDarkMode: true),
  
  firstDayOfWeek: FirstDayOfWeek.locale,
)
```

## API Reference

### Flicker Widget

The main date picker widget with comprehensive customization options.

#### Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `mode` | `FlickerSelectionMode` | Selection mode: single, range, many, or basic | `FlickerSelectionMode.single` |
| `value` | `List<DateTime>` | Currently selected dates | `[]` |
| `startDate` | `DateTime` | Minimum selectable date | Required |
| `endDate` | `DateTime` | Maximum selectable date | Required |
| `onValueChange` | `Function(List<DateTime>)` | Callback when selection changes | Required |
| `theme` | `FlickTheme` | Theme configuration for styling | `FlickTheme()` |

| `firstDayOfWeek` | `FirstDayOfWeek` | First day of the week | `FirstDayOfWeek.monday` |
| `viewCount` | `int` | Number of months to display (1 or 2) | `1` |
| `scrollDirection` | `Axis` | Scroll direction (horizontal/vertical) | `Axis.horizontal` |
| `disabledDate` | `bool Function(DateTime)` | Function to determine disabled dates | `null` |

### FlickerSelectionMode

Enum defining the selection behavior:

- `FlickerSelectionMode.single` - Single date selection
- `FlickerSelectionMode.range` - Date range selection (start and end)
- `FlickerSelectionMode.many` - Multiple individual dates
- `FlickerSelectionMode.basic` - Basic single date with horizontal scroll

### FirstDayOfWeek

Enum for configuring the first day of the week:

- `FirstDayOfWeek.monday` - Week starts on Monday
- `FirstDayOfWeek.sunday` - Week starts on Sunday
- `FirstDayOfWeek.saturday` - Week starts on Saturday
- `FirstDayOfWeek.locale` - Use system locale setting

### FlickTheme

Theme configuration class:

```dart
FlickTheme(
  useDarkMode: true, // Enable dark mode
  // Additional theme properties...
)
```

## Demo Application

The package includes a comprehensive demo application (`FlickerPickerDemo`) that showcases all features:

- **Interactive Controls**: Switch between different modes, themes, and layouts
- **Real-time Preview**: See changes immediately as you adjust settings
- **Feature Testing**: Test all selection modes and configuration options
- **Code Examples**: Reference implementation for common use cases

To run the demo:

```dart
import 'package:flutter_flicker/demos/flicker_demo.dart';

// Use FlickerPickerDemo widget in your app
FlickerPickerDemo()
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
