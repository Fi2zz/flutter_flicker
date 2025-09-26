# Flicker 📅

![Flutter Flicker](flutter__flicker-blue.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-blue.svg)](https://flutter.dev/)

[中文文档](README_CN.md) | **English**

A modern, highly customizable and performant Flutter date picker widget that supports multiple selection modes, custom styling, and flexible layouts.

## ✨ Features

### 🎯 Multiple Selection Modes

- **Single**: Select one date at a time
- **Range**: Select a continuous date range
- **Multiple**: Select multiple individual dates

### 🎨 Rich Customization

- Custom day cell builders for complete UI control
- Comprehensive theme system with light/dark modes
- Disabled date support with validation callbacks
- Flexible layout options (horizontal/vertical scrolling)
- Multi-month display (1 or 2 months simultaneously)

### 🌍 Internationalization

- Locale-aware date formatting
- Configurable first day of week
- Support for multiple languages (English, Chinese)

### ⚡ Performance

- Efficient grid management with lazy loading
- Optimized rendering for smooth scrolling
- Memory-conscious date generation
- Reactive updates using signals pattern

## 📱 Screenshots

_Screenshots will be added soon_

## 🚀 Quick Start

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_flicker:
    git:
      url: https://github.com/Fi2zz/flutter_flicker.git
```

Then run:

```bash
flutter pub get
```

### Basic Usage

```dart
import 'package:flutter_flicker/flutter_flicker.dart';

// Simple single date selection
Flicker(
  onValueChange: (dates) {
    print('Selected dates: $dates');
  },
)

// Date range selection with constraints
Flicker(
  mode: SelectionMode.range,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 365)),
  onValueChange: (dates) {
    if (dates.length == 2) {
      print('Range: ${dates.first} to ${dates.last}');
    }
  },
)

// Multiple date selection with custom theme
Flicker(
  mode: SelectionMode.many,
  theme: FlickerTheme.dark(),
  selectionCount: 5, // Limit to 5 selections
  onValueChange: (dates) {
    print('Selected ${dates.length} dates');
  },
)
```

## 📖 Documentation

### Selection Modes

| Mode                   | Description           | Use Case                                |
| ---------------------- | --------------------- | --------------------------------------- |
| `SelectionMode.single` | Select one date       | Appointment booking, birthday selection |
| `SelectionMode.range`  | Select date range     | Hotel booking, vacation planning        |
| `SelectionMode.many`   | Select multiple dates | Event planning, availability marking    |

### Key Properties

| Property          | Type                           | Default      | Description               |
| ----------------- | ------------------------------ | ------------ | ------------------------- |
| `mode`            | `SelectionMode`                | `single`     | Selection behavior        |
| `value`           | `List<DateTime>`               | `[]`         | Currently selected dates  |
| `startDate`       | `DateTime?`                    | `null`       | Minimum selectable date   |
| `endDate`         | `DateTime?`                    | `null`       | Maximum selectable date   |
| `disabledDate`    | `bool Function(DateTime)?`     | `null`       | Custom date validation    |
| `onValueChange`   | `ValueChanged<List<DateTime>>` | required     | Selection callback        |
| `theme`           | `FlickerTheme?`                | `null`       | Custom theme              |
| `viewCount`       | `int`                          | `1`          | Number of months (1 or 2) |
| `scrollDirection` | `Axis`                         | `horizontal` | Scroll direction          |
| `firstDayOfWeek`  | `FirstDayOfWeek`               | `monday`     | Week start day            |

### Theming

```dart
// Light theme
Flicker(
  theme: FlickerTheme.light(),
  // ... other properties
)

// Dark theme
Flicker(
  theme: FlickerTheme.dark(),
  // ... other properties
)

// Custom theme
Flicker(
  theme: FlickerTheme(
    useDarkMode: false,
    // Custom theme properties
  ),
  // ... other properties
)
```

### Custom Day Builder

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
  // ... other properties
)
```

## 🌐 Internationalization

Flicker supports multiple locales and provides built-in localization:

```dart
MaterialApp(
  localizationsDelegates: FlickerL10n.localizationsDelegates,
  supportedLocales: FlickerL10n.supportedLocales,
  home: MyApp(),
)
```

Supported locales:

- English (en-US)
- Chinese (zh-CN)

## 🎯 Examples

Check out the [example](example/) directory for a complete demo application showcasing all features.

To run the example:

```bash
cd example
flutter run
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Contributors and community feedback
- Inspiration from various date picker implementations

---

Made with ❤️ by the Flutter community
