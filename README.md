# Flicker

A powerful and customizable Flutter date picker widget with advanced features including date range selection, localization support, and theme customization.

## Features

### Current Implementation ✅

- **Single Date Selection** - Basic single date picking functionality
- **Month/Year View Navigation** - Switch between month and year views
- **Date Range Constraints** - Limit selectable dates with startDate/endDate parameters
- **Date Range Selection** - Select start and end date ranges with highlight display
- **Custom Disable Logic** - Flexible date disabling rules with custom functions
- **Localization Support** - Multi-language support (Chinese, English) with regional date formats
- **First Day of Week Configuration** - Customizable week start day (FirstDayOfWeek enum)
- **Theme System** - Dark/light mode switching with custom style extensions
- **Multiple Date Selection** - Support for selecting multiple non-consecutive dates
- **Basic UI Structure** - Well-structured and responsive user interface

## Development Roadmap

### Phase 1: Core Feature Enhancement (High Priority)

- [ ] **Keyboard Navigation Support** - Complete keyboard operation support
  - Tab key navigation
  - Arrow key date selection
  - Enter/Space confirmation
  - Escape to close picker

### Phase 2: User Experience Optimization (Medium Priority)

- [ ] **Accessibility Support** - Complete ARIA attributes support
  - Semantic tags
  - Screen reader support
  - High contrast mode
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

```dart
import 'package:flutter/material.dart';
import 'package:flutter_flicker/flicker.dart';

// Basic usage example
FlickerDatePicker(
  onDateSelected: (DateTime date) {
    print('Selected date: $date');
  },
  startDate: DateTime(2020),
  endDate: DateTime(2030),
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
