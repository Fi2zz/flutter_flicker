# Flutter Flicker Usage Guide

## Overview

This comprehensive guide demonstrates how to use all the components exported by `lib/flicker.dart`. Flutter Flicker provides a powerful, customizable date picker with multiple selection modes, internationalization support, and extensive theming capabilities.

## Table of Contents

- [Quick Start](#quick-start)
- [Basic Usage](#basic-usage)
  - [Single Date Selection](#single-date-selection)
  - [Date Range Selection](#date-range-selection)
  - [Multiple Date Selection](#multiple-date-selection)
- [Advanced Features](#advanced-features)
  - [Custom Day Builders](#custom-day-builders)
  - [Date Constraints](#date-constraints)
  - [Theme Customization](#theme-customization)
  - [Internationalization](#internationalization)
  - [Keyboard Navigation](#keyboard-navigation)
- [Layout Options](#layout-options)
  - [Multi-Month Display](#multi-month-display)
  - [Scroll Direction](#scroll-direction)
  - [First Day of Week](#first-day-of-week)
- [Real-World Examples](#real-world-examples)
  - [Event Calendar](#event-calendar)
  - [Booking System](#booking-system)
  - [Date Range Filter](#date-range-filter)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## Quick Start

### Installation

Add Flutter Flicker to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_flicker: ^1.0.0
```

### Basic Setup

```dart
import 'package:flutter/material.dart';
import 'package:flutter_flicker/flicker.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Add localization support
      localizationsDelegates: FlickerL10n.localizationsDelegates,
      supportedLocales: FlickerL10n.supportedLocales,
      home: DatePickerDemo(),
    );
  }
}

class DatePickerDemo extends StatefulWidget {
  @override
  _DatePickerDemoState createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  List<DateTime> selectedDates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Flicker Demo')),
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
          ),
          if (selectedDates.isNotEmpty)
            Text('Selected: ${selectedDates.first}'),
        ],
      ),
    );
  }
}
```

---

## Basic Usage

### Single Date Selection

The most common use case - allowing users to select one date.

```dart
class SingleDatePicker extends StatefulWidget {
  @override
  _SingleDatePickerState createState() => _SingleDatePickerState();
}

class _SingleDatePickerState extends State<SingleDatePicker> {
  List<DateTime> selectedDates = [];
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Basic single date picker
        Flicker(
          mode: FlickerSelectionMode.single,
          value: selectedDates,
          onValueChange: (dates) {
            setState(() {
              selectedDates = dates;
              selectedDate = dates.isNotEmpty ? dates.first : null;
            });
          },
    
        ),
        
        // Display selected date
        if (selectedDate != null)
          Container(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Selected Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Clear selection button
        if (selectedDate != null)
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedDates = [];
                selectedDate = null;
              });
            },
            child: Text('Clear Selection'),
          ),
      ],
    );
  }
}
```

### Date Range Selection

Allow users to select a start and end date for ranges like booking periods or date filters.

```dart
class DateRangePicker extends StatefulWidget {
  @override
  _DateRangePickerState createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  List<DateTime> selectedRange = [];
  DateTime? startDate;
  DateTime? endDate;
  int? daysBetween;

  void _updateRange(List<DateTime> dates) {
    setState(() {
      selectedRange = dates;
      if (dates.length >= 2) {
        startDate = dates.first;
        endDate = dates.last;
        daysBetween = endDate!.difference(startDate!).inDays + 1;
      } else {
        startDate = dates.isNotEmpty ? dates.first : null;
        endDate = null;
        daysBetween = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Range date picker
        Flicker(
          mode: FlickerSelectionMode.range,
          value: selectedRange,
          onValueChange: _updateRange,
  
          theme: FlickTheme(useDarkMode: false),
        ),
        
        // Display range information
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Range',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  if (startDate != null) ..[
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 8),
                        Text('Start: ${_formatDate(startDate!)}'),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                  
                  if (endDate != null) ..[
                    Row(
                      children: [
                        Icon(Icons.event, size: 16),
                        SizedBox(width: 8),
                        Text('End: ${_formatDate(endDate!)}'),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                  
                  if (daysBetween != null) ..[
                    Row(
                      children: [
                        Icon(Icons.date_range, size: 16),
                        SizedBox(width: 8),
                        Text('Duration: $daysBetween days'),
                      ],
                    ),
                  ],
                  
                  if (selectedRange.isEmpty)
                    Text(
                      'Select start and end dates',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

### Multiple Date Selection

Allow users to select multiple individual dates, useful for scheduling or event planning.

```dart
class MultipleDatePicker extends StatefulWidget {
  @override
  _MultipleDatePickerState createState() => _MultipleDatePickerState();
}

class _MultipleDatePickerState extends State<MultipleDatePicker> {
  List<DateTime> selectedDates = [];
  final int maxSelections = 5;

  void _updateSelection(List<DateTime> dates) {
    setState(() {
      if (dates.length <= maxSelections) {
        selectedDates = dates;
      } else {
        // Show warning if trying to select too many dates
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum $maxSelections dates can be selected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Multiple date picker
        Flicker(
          mode: FlickerSelectionMode.many,
          value: selectedDates,
          onValueChange: _updateSelection,
      
        ),
        
        // Selection counter
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected: ${selectedDates.length}/$maxSelections',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (selectedDates.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedDates = [];
                    });
                  },
                  child: Text('Clear All'),
                ),
            ],
          ),
        ),
        
        // List of selected dates
        if (selectedDates.isNotEmpty)
          Container(
            height: 200,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Selected Dates',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedDates.length,
                      itemBuilder: (context, index) {
                        final date = selectedDates[index];
                        return ListTile(
                          leading: Icon(Icons.event),
                          title: Text(_formatDate(date)),
                          subtitle: Text(_getDayOfWeek(date)),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
                                selectedDates.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _getDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
```

---

## Advanced Features

### Custom Day Builders

Create completely custom day cell appearances with `FlickerDayBuilder`.

```dart
class CustomDayBuilderExample extends StatefulWidget {
  @override
  _CustomDayBuilderExampleState createState() => _CustomDayBuilderExampleState();
}

class _CustomDayBuilderExampleState extends State<CustomDayBuilderExample> {
  List<DateTime> selectedDates = [];
  
  // Sample data for demonstration
  final Map<DateTime, String> events = {
    DateTime(2024, 1, 15): 'Meeting',
    DateTime(2024, 1, 20): 'Birthday',
    DateTime(2024, 1, 25): 'Holiday',
  };
  
  final List<DateTime> holidays = [
    DateTime(2024, 1, 1),   // New Year
    DateTime(2024, 12, 25), // Christmas
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
    if (date == null) {
      return const SizedBox.shrink();
    }

    // Check for special dates
    final hasEvent = events.containsKey(DateTime(date.year, date.month, date.day));
    final isHoliday = holidays.any((holiday) => 
        holiday.year == date.year && 
        holiday.month == date.month && 
        holiday.day == date.day);
    final isWeekend = date.weekday == DateTime.saturday || 
                      date.weekday == DateTime.sunday;

    // Determine colors and styling
    Color? backgroundColor;
    Color textColor = Colors.black;
    Color? borderColor;
    
    if (selected == true) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
    } else if (isToday == true) {
      backgroundColor = Colors.orange.withOpacity(0.3);
      borderColor = Colors.orange;
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
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null 
            ? Border.all(color: borderColor, width: 2) 
            : null,
      ),
      child: Stack(
        children: [
          // Main date display
          Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isToday == true ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
          
          // Event indicator
          if (hasEvent)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selected == true ? Colors.white : Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          
          // Holiday indicator
          if (isHoliday)
            Positioned(
              bottom: 2,
              left: 2,
              child: Icon(
                Icons.star,
                size: 8,
                color: selected == true ? Colors.white : Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom styled calendar
        Flicker(
          mode: FlickerSelectionMode.many,
          value: selectedDates,
          dayBuilder: customDayBuilder,
          onValueChange: (dates) {
            setState(() {
              selectedDates = dates;
            });
          },

        ),
        
        // Legend
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Legend',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildLegendItem(Colors.blue, 'Event', Icons.circle),
                  _buildLegendItem(Colors.red, 'Holiday', Icons.star),
                  _buildLegendItem(Colors.orange, 'Today', Icons.today),
                ],
              ),
            ),
          ),
        ),
        
        // Selected dates with events
        if (selectedDates.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Dates',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ...selectedDates.map((date) {
                      final event = events[DateTime(date.year, date.month, date.day)];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('${date.day}/${date.month}/${date.year}'),
                            if (event != null) ..[
                              SizedBox(width: 8),
                              Chip(
                                label: Text(event),
                                backgroundColor: Colors.blue.withOpacity(0.2),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildLegendItem(Color color, String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
```

### Date Constraints

Control which dates users can select using various constraint mechanisms.

```dart
class DateConstraintsExample extends StatefulWidget {
  @override
  _DateConstraintsExampleState createState() => _DateConstraintsExampleState();
}

class _DateConstraintsExampleState extends State<DateConstraintsExample> {
  List<DateTime> selectedDates = [];
  
  // Define constraints
  final DateTime minDate = DateTime.now(); // No past dates
  final DateTime maxDate = DateTime.now().add(Duration(days: 90)); // 3 months ahead
  
  // Business rules
  final List<DateTime> blockedDates = [
    DateTime.now().add(Duration(days: 10)),
    DateTime.now().add(Duration(days: 20)),
  ];

  bool isDateDisabled(DateTime date) {
    // Disable weekends
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return true;
    }
    
    // Disable specific blocked dates
    if (blockedDates.any((blocked) => 
        blocked.year == date.year && 
        blocked.month == date.month && 
        blocked.day == date.day)) {
      return true;
    }
    
    // Disable dates too far in the future (beyond maxDate)
    if (date.isAfter(maxDate)) {
      return true;
    }
    
    // Disable past dates (before minDate)
    if (date.isBefore(minDate)) {
      return true;
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Constrained date picker
        Flicker(
          mode: FlickerSelectionMode.many,
          value: selectedDates,
          startDate: minDate,
          endDate: maxDate,
          disabledDate: isDateDisabled,
          onValueChange: (dates) {
            setState(() {
              selectedDates = dates;
            });
          },
  
        ),
        
        // Constraints information
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date Constraints',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  _buildConstraintItem(
                    Icons.schedule,
                    'Available from: ${_formatDate(minDate)}',
                    Colors.green,
                  ),
                  
                  _buildConstraintItem(
                    Icons.event_busy,
                    'Available until: ${_formatDate(maxDate)}',
                    Colors.orange,
                  ),
                  
                  _buildConstraintItem(
                    Icons.weekend,
                    'Weekends are disabled',
                    Colors.red,
                  ),
                  
                  _buildConstraintItem(
                    Icons.block,
                    '${blockedDates.length} specific dates blocked',
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Selection summary
        if (selectedDates.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valid Selections (${selectedDates.length})',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ...selectedDates.map((date) => Text(
                      '• ${_formatDate(date)} (${_getDayOfWeek(date)})',
                    )).toList(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildConstraintItem(IconData icon, String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _getDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
```

### Theme Customization

Customize the appearance using the theme system.

```dart
class ThemeCustomizationExample extends StatefulWidget {
  @override
  _ThemeCustomizationExampleState createState() => _ThemeCustomizationExampleState();
}

class _ThemeCustomizationExampleState extends State<ThemeCustomizationExample> {
  List<DateTime> selectedDates = [];
  int selectedTheme = 0;
  
  final List<Map<String, dynamic>> themes = [
    {
      'name': 'Light Theme',
      'theme': FlickTheme(useDarkMode: false),
    },
    {
      'name': 'Dark Theme',
      'theme': FlickTheme(useDarkMode: true),
    },
    {
      'name': 'System Theme',
      'theme': FlickTheme(), // Follows system setting
    },
    {
      'name': 'Custom Purple',
      'theme': FlickTheme(
        custom: FlickThemeData.custom(
          primaryColor: Colors.purple,
          selectedColor: Colors.purple,
          backgroundColor: Colors.purple.withOpacity(0.05),
          textColor: Colors.purple[800],
          todayColor: Colors.orange,
        ),
      ),
    },
    {
      'name': 'Custom Green',
      'theme': FlickTheme(
        custom: FlickThemeData.custom(
          primaryColor: Colors.green,
          selectedColor: Colors.green,
          backgroundColor: Colors.green.withOpacity(0.05),
          textColor: Colors.green[800],
          todayColor: Colors.amber,
        ),
      ),
    },
    {
      'name': 'No Today Highlight',
      'theme': FlickTheme(
        custom: FlickThemeData.custom(
          primaryColor: Colors.blue,
          selectedColor: Colors.blue,
          backgroundColor: Colors.blue.withOpacity(0.05),
          textColor: Colors.blue[800],
          highlightToday: false, // Disable today highlighting
        ),
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Theme selector
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Theme',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: themes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final theme = entry.value;
                      return ChoiceChip(
                        label: Text(theme['name']),
                        selected: selectedTheme == index,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedTheme = index;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Themed calendar
        Flicker(
          mode: FlickerSelectionMode.range,
          value: selectedDates,
          theme: themes[selectedTheme]['theme'],
          onValueChange: (dates) {
            setState(() {
              selectedDates = dates;
            });
          },
    
          viewCount: 1,
        ),
        
        // Theme information
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Theme: ${themes[selectedTheme]['name']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Themes control colors, typography, and visual styling of the calendar.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### Internationalization

Support multiple languages and locales.

```dart
class InternationalizationExample extends StatefulWidget {
  @override
  _InternationalizationExampleState createState() => _InternationalizationExampleState();
}

class _InternationalizationExampleState extends State<InternationalizationExample> {
  List<DateTime> selectedDates = [];
  Locale currentLocale = Locale('en', 'US');
  
  final List<Map<String, dynamic>> supportedLocales = [
    {'locale': Locale('en', 'US'), 'name': 'English (US)', 'flag': '🇺🇸'},
    {'locale': Locale('zh', 'CN'), 'name': '中文 (简体)', 'flag': '🇨🇳'},
    {'locale': Locale('es', 'ES'), 'name': 'Español', 'flag': '🇪🇸'},
    {'locale': Locale('fr', 'FR'), 'name': 'Français', 'flag': '🇫🇷'},
    {'locale': Locale('de', 'DE'), 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'locale': Locale('ja', 'JP'), 'name': '日本語', 'flag': '🇯🇵'},
    {'locale': Locale('ko', 'KR'), 'name': '한국어', 'flag': '🇰🇷'},
  ];

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: currentLocale,
      child: Builder(
        builder: (context) {
          final l10n = FlickerL10n.maybeOf(context);
          
          return Column(
            children: [
              // Locale selector
              Container(
                padding: EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Language',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        DropdownButton<Locale>(
                          value: currentLocale,
                          isExpanded: true,
                          items: supportedLocales.map((localeData) {
                            return DropdownMenuItem<Locale>(
                              value: localeData['locale'],
                              child: Row(
                                children: [
                                  Text(
                                    localeData['flag'],
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(width: 8),
                                  Text(localeData['name']),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (locale) {
                            if (locale != null) {
                              setState(() {
                                currentLocale = locale;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Localized calendar
              Flicker(
                mode: FlickerSelectionMode.single,
                value: selectedDates,
                firstDayOfWeek: FirstDayOfWeek.locale, // Uses locale-specific first day
                onValueChange: (dates) {
                  setState(() {
                    selectedDates = dates;
                  });
                },
            
              ),
              
              // Localization information
              Container(
                padding: EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Localization Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        _buildInfoRow('Locale', '${currentLocale.languageCode}_${currentLocale.countryCode}'),
                        _buildInfoRow('First Day of Week', _getFirstDayName(l10n.firstDayOfWeek)),
                        _buildInfoRow('Month Format', l10n.monthYearFormat),
                        
                        SizedBox(height: 12),
                        Text(
                          'Month Names:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: l10n.monthNames.map((month) => Chip(
                            label: Text(month),
                            backgroundColor: Colors.blue.withOpacity(0.1),
                          )).toList(),
                        ),
                        
                        SizedBox(height: 12),
                        Text(
                          'Weekday Names:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: l10n.weekdayNames.map((day) => Chip(
                            label: Text(day),
                            backgroundColor: Colors.green.withOpacity(0.1),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Selected date in localized format
              if (selectedDates.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Selected Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _formatLocalizedDate(selectedDates.first, l10n),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  String _getFirstDayName(int firstDay) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[firstDay];
  }
  
  String _formatLocalizedDate(DateTime date, FlickerL10n l10n) {
    final monthName = l10n.monthNames[date.month - 1];
    return '${date.day} $monthName ${date.year}';
  }
}
```

### Keyboard Navigation

Flutter Flicker provides comprehensive keyboard navigation support for enhanced accessibility and user experience.

#### Supported Keys

- **Arrow Keys**: Navigate between dates
  - `←` / `→`: Move left/right by one day
  - `↑` / `↓`: Move up/down by one week
- **Page Navigation**: Quick month navigation
  - `Page Up`: Go to previous month
  - `Page Down`: Go to next month
- **Home/End**: Jump to month boundaries
  - `Home`: Go to first day of current month
  - `End`: Go to last day of current month
- **Selection Keys**: Confirm date selection
  - `Enter` / `Space`: Select the focused date
- **Escape**: Clear focus or close picker

#### Configuration

Keyboard navigation can be configured using the `KeyboardNavigationConfig` class:

```dart
class KeyboardNavigationExample extends StatefulWidget {
  @override
  _KeyboardNavigationExampleState createState() => _KeyboardNavigationExampleState();
}

class _KeyboardNavigationExampleState extends State<KeyboardNavigationExample> {
  List<DateTime> selectedDates = [];
  bool keyboardEnabled = true;
  bool showFocusIndicator = true;
  bool enableQuickNavigation = true;
  bool enableWrapNavigation = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Keyboard navigation settings
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keyboard Navigation Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  SwitchListTile(
                    title: Text('Enable Keyboard Navigation'),
                    subtitle: Text('Allow navigation using keyboard'),
                    value: keyboardEnabled,
                    onChanged: (value) {
                      setState(() {
                        keyboardEnabled = value;
                      });
                    },
                  ),
                  
                  SwitchListTile(
                    title: Text('Show Focus Indicator'),
                    subtitle: Text('Display visual focus indicator'),
                    value: showFocusIndicator,
                    onChanged: (value) {
                      setState(() {
                        showFocusIndicator = value;
                      });
                    },
                  ),
                  
                  SwitchListTile(
                    title: Text('Enable Quick Navigation'),
                    subtitle: Text('Page Up/Down and Home/End keys'),
                    value: enableQuickNavigation,
                    onChanged: (value) {
                      setState(() {
                        enableQuickNavigation = value;
                      });
                    },
                  ),
                  
                  SwitchListTile(
                    title: Text('Enable Wrap Navigation'),
                    subtitle: Text('Wrap to next/previous month at boundaries'),
                    value: enableWrapNavigation,
                    onChanged: (value) {
                      setState(() {
                        enableWrapNavigation = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Calendar with keyboard navigation
        Flicker(
          mode: FlickerSelectionMode.single,
          value: selectedDates,
          onValueChange: (dates) {
            setState(() {
              selectedDates = dates;
            });
          },
          // Keyboard navigation is enabled by default
          // Configuration is handled internally
        ),
        
        // Keyboard shortcuts help
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keyboard Shortcuts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  _buildShortcutRow('←/→', 'Navigate left/right by day'),
                  _buildShortcutRow('↑/↓', 'Navigate up/down by week'),
                  _buildShortcutRow('Page Up/Down', 'Previous/next month'),
                  _buildShortcutRow('Home/End', 'First/last day of month'),
                  _buildShortcutRow('Enter/Space', 'Select focused date'),
                  _buildShortcutRow('Escape', 'Clear focus'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildShortcutRow(String keys, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 120,
            child: Text(
              keys,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }
}
```

#### Accessibility Features

Keyboard navigation includes comprehensive accessibility support:

- **Screen Reader Support**: Semantic labels for all interactive elements
- **Focus Management**: Clear visual focus indicators
- **ARIA Attributes**: Proper labeling for assistive technologies
- **High Contrast**: Focus indicators work with high contrast themes

#### Best Practices

1. **Always Enable**: Keep keyboard navigation enabled for accessibility
2. **Visual Feedback**: Ensure focus indicators are clearly visible
3. **Test with Screen Readers**: Verify compatibility with assistive technologies
4. **Document Shortcuts**: Provide keyboard shortcut documentation for users

---

## Layout Options

### Multi-Month Display

Show multiple months simultaneously for better date range selection.

```dart
class MultiMonthExample extends StatefulWidget {
  @override
  _MultiMonthExampleState createState() => _MultiMonthExampleState();
}

class _MultiMonthExampleState extends State<MultiMonthExample> {
  List<DateTime> selectedRange = [];
  int viewCount = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // View count selector
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number of Months',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text('1 Month'),
                        selected: viewCount == 1,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              viewCount = 1;
                            });
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('2 Months'),
                        selected: viewCount == 2,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              viewCount = 2;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Multi-month calendar
        Flicker(
          mode: FlickerSelectionMode.range,
          value: selectedRange,
          viewCount: viewCount,
          onValueChange: (dates) {
            setState(() {
              selectedRange = dates;
            });
          },
       
        ),
        
        // Benefits explanation
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Multi-Month Benefits',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Better for range selection across months'),
                  Text('• Improved user experience for date planning'),
                  Text('• Reduced scrolling and navigation'),
                  Text('• Better context for date relationships'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### Scroll Direction

Control the scroll direction for different layout needs.

```dart
class ScrollDirectionExample extends StatefulWidget {
  @override
  _ScrollDirectionExampleState createState() => _ScrollDirectionExampleState();
}

class _ScrollDirectionExampleState extends State<ScrollDirectionExample> {
  List<DateTime> selectedDates = [];
  Axis scrollDirection = Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scroll direction selector
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scroll Direction',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_horiz, size: 16),
                            SizedBox(width: 4),
                            Text('Horizontal'),
                          ],
                        ),
                        selected: scrollDirection == Axis.horizontal,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              scrollDirection = Axis.horizontal;
                            });
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_vert, size: 16),
                            SizedBox(width: 4),
                            Text('Vertical'),
                          ],
                        ),
                        selected: scrollDirection == Axis.vertical,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              scrollDirection = Axis.vertical;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Calendar with configurable scroll direction
        Container(
          height: scrollDirection == Axis.vertical ? 600 : 400,
          child: Flicker(
            mode: FlickerSelectionMode.many,
            value: selectedDates,
            scrollDirection: scrollDirection,
            onValueChange: (dates) {
              setState(() {
                selectedDates = dates;
              });
            },
          ),
        ),
        
        // Usage recommendations
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'When to Use Each Direction',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  Text(
                    'Horizontal Scroll:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('• Default and most common'),
                  Text('• Better for landscape layouts'),
                  Text('• Familiar swipe gestures'),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'Vertical Scroll:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('• Better for tall, narrow layouts'),
                  Text('• Integrates well with scrollable content'),
                  Text('• Good for mobile portrait mode'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### First Day of Week

Configure which day appears as the first column.

```dart
class FirstDayOfWeekExample extends StatefulWidget {
  @override
  _FirstDayOfWeekExampleState createState() => _FirstDayOfWeekExampleState();
}

class _FirstDayOfWeekExampleState extends State<FirstDayOfWeekExample> {
  List<DateTime> selectedDates = [];
  FirstDayOfWeek firstDayOfWeek = FirstDayOfWeek.monday;
  
  final List<Map<String, dynamic>> firstDayOptions = [
    {
      'value': FirstDayOfWeek.sunday,
      'name': 'Sunday',
      'description': 'Common in US, Japan, Korea',
      'flag': '🇺🇸',
    },
    {
      'value': FirstDayOfWeek.monday,
      'name': 'Monday',
      'description': 'Common in Europe, China',
      'flag': '🇪🇺',
    },
    {
      'value': FirstDayOfWeek.saturday,
      'name': 'Saturday',
      'description': 'Common in Middle East',
      'flag': '🇸🇦',
    },
    {
      'value': FirstDayOfWeek.locale,
      'name': 'Locale-based',
      'description': 'Follows device locale setting',
      'flag': '🌍',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First day selector
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'First Day of Week',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  ...firstDayOptions.map((option) {
                    return RadioListTile<FirstDayOfWeek>(
                      title: Row(
                        children: [
                          Text(option['flag'], style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text(option['name']),
                        ],
                      ),
                      subtitle: Text(option['description']),
                      value: option['value'],
                      groupValue: firstDayOfWeek,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            firstDayOfWeek = value;
                          });
                        }
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
        
        // Calendar with configurable first day
        Flicker(
          mode: FlickerSelectionMode.single,
          value: selectedDates,
          firstDayOfWeek: firstDayOfWeek,
          onValueChange: (dates) {
            setState(() {
              selectedDates = dates;
            });
          },
        ),
        
        // Current configuration info
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Configuration',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  Text('First Day: ${_getFirstDayName(firstDayOfWeek)}'),
                  
                  if (firstDayOfWeek == FirstDayOfWeek.locale) ..[
                    SizedBox(height: 4),
                    Text(
                      'Note: Locale-based setting uses the device\'s regional preferences.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  String _getFirstDayName(FirstDayOfWeek firstDay) {
    switch (firstDay) {
      case FirstDayOfWeek.sunday:
        return 'Sunday';
      case FirstDayOfWeek.monday:
        return 'Monday';
      case FirstDayOfWeek.saturday:
        return 'Saturday';
      case FirstDayOfWeek.locale:
        return 'Locale-based';
    }
  }
}
```

---

## Real-World Examples

### Event Calendar

A complete event calendar implementation with custom day builders and event management.

```dart
class EventCalendar extends StatefulWidget {
  @override
  _EventCalendarState createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  List<DateTime> selectedDates = [];
  Map<DateTime, List<Event>> events = {};
  
  @override
  void initState() {
    super.initState();
    _loadSampleEvents();
  }
  
  void _loadSampleEvents() {
    final now = DateTime.now();
    events = {
      DateTime(now.year, now.month, 5): [
        Event('Team Meeting', Colors.blue, '10:00 AM'),
        Event('Code Review', Colors.green, '2:00 PM'),
      ],
      DateTime(now.year, now.month, 12): [
        Event('Project Deadline', Colors.red, 'All Day'),
      ],
      DateTime(now.year, now.month, 18): [
        Event('Client Presentation', Colors.purple, '3:00 PM'),
      ],
      DateTime(now.year, now.month, 25): [
        Event('Team Lunch', Colors.orange, '12:00 PM'),
        Event('Sprint Planning', Colors.blue, '4:00 PM'),
      ],
    };
  }

  Widget eventDayBuilder(
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

    final dateKey = DateTime(date.year, date.month, date.day);
    final dayEvents = events[dateKey] ?? [];
    final hasEvents = dayEvents.isNotEmpty;

    Color? backgroundColor;
    Color textColor = Colors.black;
    
    if (selected == true) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
    } else if (isToday == true) {
      backgroundColor = Colors.orange.withOpacity(0.3);
    }
    
    if (disabled == true) {
      textColor = Colors.grey[400]!;
    }

    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday == true 
            ? Border.all(color: Colors.orange, width: 2) 
            : null,
      ),
      child: Stack(
        children: [
          // Date number
          Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isToday == true ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
          
          // Event indicators
          if (hasEvents)
            Positioned(
              bottom: 2,
              left: 2,
              right: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dayEvents.take(3).map((event) => Container(
                  width: 4,
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: selected == true ? Colors.white : event.color,
                    shape: BoxShape.circle,
                  ),
                )).toList(),
              ),
            ),
          
          // More events indicator
          if (dayEvents.length > 3)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: selected == true ? Colors.white : Colors.grey[600],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      color: selected == true ? Colors.blue : Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Event calendar
        Flicker(
          mode: FlickerSelectionMode.single,
          value: selectedDates,
          dayBuilder: eventDayBuilder,
          onValueChange: (dates) {
            setState(() {
              selectedDates = dates;
            });
          },
        ),
        
        // Selected date events
        if (selectedDates.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Events for ${_formatDate(selectedDates.first)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    ...(_getEventsForDate(selectedDates.first).map((event) => 
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: event.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.title,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              event.time,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                    
                    if (_getEventsForDate(selectedDates.first).isEmpty)
                      Text(
                        'No events scheduled',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ),
          ),
        
        // Legend
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Legend',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Meetings'),
                      SizedBox(width: 16),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Deadlines'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  List<Event> _getEventsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return events[dateKey] ?? [];
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class Event {
  final String title;
  final Color color;
  final String time;
  
  Event(this.title, this.color, this.time);
}
```

### Booking System

A hotel/service booking system with availability checking and constraints.

```dart
class BookingSystem extends StatefulWidget {
  @override
  _BookingSystemState createState() => _BookingSystemState();
}

class _BookingSystemState extends State<BookingSystem> {
  List<DateTime> selectedRange = [];
  DateTime? checkIn;
  DateTime? checkOut;
  int? nights;
  double? totalPrice;
  
  // Sample availability data
  final Map<DateTime, BookingStatus> availability = {};
  final double pricePerNight = 120.0;
  
  @override
  void initState() {
    super.initState();
    _generateAvailability();
  }
  
  void _generateAvailability() {
    final now = DateTime.now();
    for (int i = 0; i < 90; i++) {
      final date = now.add(Duration(days: i));
      
      // Simulate different availability statuses
      if (i % 7 == 0 || i % 7 == 6) {
        // Weekends are more expensive
        availability[date] = BookingStatus.available;
      } else if (i % 15 == 0) {
        // Some dates are booked
        availability[date] = BookingStatus.booked;
      } else if (i % 20 == 0) {
        // Some dates have limited availability
        availability[date] = BookingStatus.limited;
      } else {
        availability[date] = BookingStatus.available;
      }
    }
  }
  
  bool isDateDisabled(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final status = availability[dateKey];
    return status == BookingStatus.booked || date.isBefore(DateTime.now());
  }
  
  void _updateBooking(List<DateTime> dates) {
    setState(() {
      selectedRange = dates;
      if (dates.length >= 2) {
        checkIn = dates.first;
        checkOut = dates.last;
        nights = checkOut!.difference(checkIn!).inDays;
        totalPrice = nights! * pricePerNight;
      } else {
        checkIn = dates.isNotEmpty ? dates.first : null;
        checkOut = null;
        nights = null;
        totalPrice = null;
      }
    });
  }

  Widget bookingDayBuilder(
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

    final dateKey = DateTime(date.year, date.month, date.day);
    final status = availability[dateKey] ?? BookingStatus.available;
    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    Color? backgroundColor;
    Color textColor = Colors.black;
    Color? borderColor;
    
    if (selected == true || isRangeStart == true || isRangeEnd == true) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
    } else if (isInRange == true) {
      backgroundColor = Colors.blue.withOpacity(0.3);
    } else if (isToday == true) {
      borderColor = Colors.orange;
    }
    
    // Status-based styling
    if (status == BookingStatus.booked) {
      backgroundColor = Colors.red.withOpacity(0.3);
      textColor = Colors.red[800]!;
    } else if (status == BookingStatus.limited) {
      backgroundColor = Colors.orange.withOpacity(0.2);
    } else if (isWeekend && status == BookingStatus.available) {
      backgroundColor = Colors.green.withOpacity(0.1);
    }
    
    if (disabled == true) {
      textColor = Colors.grey[400]!;
      backgroundColor = Colors.grey[200];
    }

    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null 
            ? Border.all(color: borderColor, width: 2) 
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isToday == true ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          
          // Status indicator
          if (status == BookingStatus.limited)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          
          // Weekend price indicator
          if (isWeekend && status == BookingStatus.available && selected != true)
            Positioned(
              bottom: 2,
              left: 2,
              child: Text(
                '\$',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Booking calendar
        Flicker(
          mode: FlickerSelectionMode.range,
          value: selectedRange,
          dayBuilder: bookingDayBuilder,
          disabledDate: isDateDisabled,
          onValueChange: _updateBooking,
          viewCount: 2,
        ),
        
        // Booking summary
        if (checkIn != null)
          Container(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    _buildBookingRow('Check-in', _formatDate(checkIn!)),
                    if (checkOut != null) ..[
                      _buildBookingRow('Check-out', _formatDate(checkOut!)),
                      _buildBookingRow('Nights', '$nights'),
                      _buildBookingRow('Price per night', '\$${pricePerNight.toStringAsFixed(2)}'),
                      Divider(),
                      _buildBookingRow(
                        'Total Price', 
                        '\$${totalPrice!.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                    
                    if (checkOut == null)
                      Text(
                        'Select check-out date to complete booking',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    
                    if (totalPrice != null) ..[
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showBookingConfirmation();
                          },
                          child: Text('Book Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        
        // Legend
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Availability Legend',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildLegendItem(Colors.green.withOpacity(0.1), 'Available'),
                  _buildLegendItem(Colors.orange.withOpacity(0.2), 'Limited availability'),
                  _buildLegendItem(Colors.red.withOpacity(0.3), 'Fully booked'),
                  _buildLegendItem(Colors.grey[200]!, 'Past dates'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBookingRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
  
  void _showBookingConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Check-in: ${_formatDate(checkIn!)}'),
            Text('Check-out: ${_formatDate(checkOut!)}'),
            Text('Nights: $nights'),
            Text('Total: \$${totalPrice!.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Booking confirmed!')),
              );
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

enum BookingStatus {
  available,
  limited,
  booked,
}
```

### Date Range Filter

A date range filter for data analysis or reporting.

```dart
class DateRangeFilter extends StatefulWidget {
  @override
  _DateRangeFilterState createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  List<DateTime> selectedRange = [];
  List<Map<String, dynamic>> filteredData = [];
  
  // Sample data
  final List<Map<String, dynamic>> sampleData = [
    {'date': DateTime(2024, 1, 5), 'sales': 1200, 'orders': 15},
    {'date': DateTime(2024, 1, 12), 'sales': 1800, 'orders': 22},
    {'date': DateTime(2024, 1, 18), 'sales': 950, 'orders': 12},
    {'date': DateTime(2024, 1, 25), 'sales': 2100, 'orders': 28},
    {'date': DateTime(2024, 2, 2), 'sales': 1650, 'orders': 19},
    {'date': DateTime(2024, 2, 9), 'sales': 1400, 'orders': 17},
    {'date': DateTime(2024, 2, 16), 'sales': 1750, 'orders': 21},
  ];
  
  @override
  void initState() {
    super.initState();
    filteredData = sampleData;
  }
  
  void _applyDateFilter(List<DateTime> dates) {
    setState(() {
      selectedRange = dates;
      
      if (dates.length == 2) {
        final startDate = dates.first;
        final endDate = dates.last;
        
        filteredData = sampleData.where((item) {
          final itemDate = item['date'] as DateTime;
          return itemDate.isAfter(startDate.subtract(Duration(days: 1))) &&
                 itemDate.isBefore(endDate.add(Duration(days: 1)));
        }).toList();
      } else {
        filteredData = sampleData;
      }
    });
  }
  
  double get totalSales => filteredData.fold(0.0, (sum, item) => sum + item['sales']);
  int get totalOrders => filteredData.fold(0, (sum, item) => sum + item['orders']);
  double get averageOrderValue => totalOrders > 0 ? totalSales / totalOrders : 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date range filter
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date Range',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  Flicker(
                    mode: FlickerSelectionMode.range,
                    value: selectedRange,
                    onValueChange: _applyDateFilter,
                    theme: FlickTheme(useDarkMode: false),
                  ),
                  
                  if (selectedRange.length == 2) ..[
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.date_range, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Range: ${_formatDate(selectedRange.first)} - ${_formatDate(selectedRange.last)}',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _applyDateFilter([]),
                          child: Text('Clear Filter'),
                        ),
                        SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _setQuickRange(7),
                          child: Text('Last 7 days'),
                        ),
                        SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _setQuickRange(30),
                          child: Text('Last 30 days'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        
        // Summary statistics
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary Statistics',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Sales',
                          '\$${totalSales.toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Total Orders',
                          '$totalOrders',
                          Icons.shopping_cart,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Avg Order Value',
                          '\$${averageOrderValue.toStringAsFixed(2)}',
                          Icons.trending_up,
                          Colors.orange,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Records',
                          '${filteredData.length}',
                          Icons.list,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Filtered data list
        Container(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Filtered Data',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                if (filteredData.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No data in selected range',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final item = filteredData[index];
                      return ListTile(
                        leading: Icon(Icons.calendar_today),
                        title: Text(_formatDate(item['date'])),
                        subtitle: Text('${item['orders']} orders'),
                        trailing: Text(
                          '\$${item['sales']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _setQuickRange(int days) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    _applyDateFilter([startDate, endDate]);
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

---

## Performance Optimization

### Efficient Day Builders

```dart
// ❌ Inefficient - creates new objects on every build
Widget inefficientDayBuilder(int index, DateTime? date, {bool? selected, ...}) {
  return Container(
    decoration: BoxDecoration(
      color: selected == true ? Colors.blue : Colors.white,
      borderRadius: BorderRadius.circular(8), // Creates new object every time
    ),
    child: Text('${date?.day}'),
  );
}

// ✅ Efficient - reuses objects and minimizes allocations
class EfficientDayBuilder {
  static const _borderRadius = BorderRadius.all(Radius.circular(8));
  static const _selectedDecoration = BoxDecoration(
    color: Colors.blue,
    borderRadius: _borderRadius,
  );
  static const _defaultDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: _borderRadius,
  );
  
  static Widget build(int index, DateTime? date, {bool? selected, ...}) {
    if (date == null) return const SizedBox.shrink();
    
    return Container(
      decoration: selected == true ? _selectedDecoration : _defaultDecoration,
      child: Text('${date.day}'),
    );
  }
}
```

### Memory Management

```dart
class OptimizedDatePicker extends StatefulWidget {
  @override
  _OptimizedDatePickerState createState() => _OptimizedDatePickerState();
}

class _OptimizedDatePickerState extends State<OptimizedDatePicker> {
  List<DateTime> selectedDates = [];
  
  // Cache disabled date results to avoid repeated calculations
  final Map<DateTime, bool> _disabledCache = {};
  
  bool isDateDisabled(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    
    // Check cache first
    if (_disabledCache.containsKey(dateKey)) {
      return _disabledCache[dateKey]!;
    }
    
    // Calculate and cache result
    final isDisabled = date.weekday == DateTime.saturday || 
                      date.weekday == DateTime.sunday;
    _disabledCache[dateKey] = isDisabled;
    
    return isDisabled;
  }
  
  @override
  void dispose() {
    // Clear cache to prevent memory leaks
    _disabledCache.clear();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Flicker(
      mode: FlickerSelectionMode.single,
      value: selectedDates,
      disabledDate: isDateDisabled,
      onValueChange: (dates) {
        setState(() {
          selectedDates = dates;
        });
      },
    );
  }
}
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Dates not updating properly

```dart
// ❌ Problem: Not updating state correctly
class ProblematicDatePicker extends StatefulWidget {
  @override
  _ProblematicDatePickerState createState() => _ProblematicDatePickerState();
}

class _ProblematicDatePickerState extends State<ProblematicDatePicker> {
  List<DateTime> selectedDates = [];
  
  @override
  Widget build(BuildContext context) {
    return Flicker(
      value: selectedDates,
      onValueChange: (dates) {
        selectedDates = dates; // ❌ Missing setState!
      },
    );
  }
}

// ✅ Solution: Always use setState
class CorrectDatePicker extends StatefulWidget {
  @override
  _CorrectDatePickerState createState() => _CorrectDatePickerState();
}

class _CorrectDatePickerState extends State<CorrectDatePicker> {
  List<DateTime> selectedDates = [];
  
  @override
  Widget build(BuildContext context) {
    return Flicker(
      value: selectedDates,
      onValueChange: (dates) {
        setState(() {
          selectedDates = dates; // ✅ Correct!
        });
      },
    );
  }
}
```

#### Issue: Custom day builder not working

```dart
// ❌ Problem: Returning null or wrong widget
Widget problematicDayBuilder(int index, DateTime? date, {...}) {
  if (date == null) return null; // ❌ Should return Widget
  return Text('${date.day}'); // ❌ No container/sizing
}

// ✅ Solution: Always return proper widget
Widget correctDayBuilder(int index, DateTime? date, {...}) {
  if (date == null) return const SizedBox.shrink(); // ✅ Proper empty widget
  
  return Container( // ✅ Proper container with sizing
    width: 40,
    height: 40,
    child: Center(
      child: Text('${date.day}'),
    ),
  );
}
```

#### Issue: Performance problems with large date ranges

```dart
// ❌ Problem: Expensive operations in day builder
Widget expensiveDayBuilder(int index, DateTime? date, {...}) {
  if (date == null) return const SizedBox.shrink();
  
  // ❌ Expensive calculation on every build
  final events = database.getEventsForDate(date); // Database call!
  final isHoliday = holidayService.isHoliday(date); // API call!
  
  return Container(child: Text('${date.day}'));
}

// ✅ Solution: Pre-calculate and cache data
class OptimizedCalendar extends StatefulWidget {
  @override
  _OptimizedCalendarState createState() => _OptimizedCalendarState();
}

class _OptimizedCalendarState extends State<OptimizedCalendar> {
  Map<DateTime, List<Event>> eventsCache = {};
  Set<DateTime> holidaysCache = {};
  
  @override
  void initState() {
    super.initState();
    _preloadData(); // ✅ Load data once
  }
  
  Future<void> _preloadData() async {
    // Load events and holidays for the visible date range
    final events = await database.getEventsForRange(startDate, endDate);
    final holidays = await holidayService.getHolidays(year);
    
    setState(() {
      eventsCache = events;
      holidaysCache = holidays;
    });
  }
  
  Widget optimizedDayBuilder(int index, DateTime? date, {...}) {
    if (date == null) return const SizedBox.shrink();
    
    // ✅ Fast cache lookup
    final events = eventsCache[date] ?? [];
    final isHoliday = holidaysCache.contains(date);
    
    return Container(child: Text('${date.day}'));
  }
}
```

---

## Best Practices

### 1. State Management

```dart
// ✅ Use proper state management
class BestPracticeDatePicker extends StatefulWidget {
  final Function(List<DateTime>)? onSelectionChanged;
  
  const BestPracticeDatePicker({Key? key, this.onSelectionChanged}) : super(key: key);
  
  @override
  _BestPracticeDatePickerState createState() => _BestPracticeDatePickerState();
}

class _BestPracticeDatePickerState extends State<BestPracticeDatePicker> {
  List<DateTime> _selectedDates = [];
  
  void _handleSelectionChange(List<DateTime> dates) {
    setState(() {
      _selectedDates = dates;
    });
    
    // Notify parent widget
    widget.onSelectionChanged?.call(dates);
  }
  
  @override
  Widget build(BuildContext context) {
    return Flicker(
      value: _selectedDates,
      onValueChange: _handleSelectionChange,
    );
  }
}
```

### 2. Error Handling

```dart
class RobustDatePicker extends StatefulWidget {
  @override
  _RobustDatePickerState createState() => _RobustDatePickerState();
}

class _RobustDatePickerState extends State<RobustDatePicker> {
  List<DateTime> selectedDates = [];
  String? errorMessage;
  
  void _handleSelectionChange(List<DateTime> dates) {
    try {
      // Validate selection
      if (dates.length > 5) {
        throw Exception('Maximum 5 dates can be selected');
      }
      
      setState(() {
        selectedDates = dates;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flicker(
          value: selectedDates,
          onValueChange: _handleSelectionChange,
        ),
        
        if (errorMessage != null)
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.red.withOpacity(0.1),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
```

### 3. Accessibility

```dart
class AccessibleDatePicker extends StatefulWidget {
  @override
  _AccessibleDatePickerState createState() => _AccessibleDatePickerState();
}

class _AccessibleDatePickerState extends State<AccessibleDatePicker> {
  List<DateTime> selectedDates = [];
  
  Widget accessibleDayBuilder(int index, DateTime? date, {...}) {
    if (date == null) return const SizedBox.shrink();
    
    return Semantics(
      label: 'Date ${date.day} ${_getMonthName(date.month)} ${date.year}',
      hint: selected == true ? 'Selected' : 'Tap to select',
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: selected == true ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: selected == true ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
  
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Date picker calendar',
      child: Flicker(
        value: selectedDates,
        dayBuilder: accessibleDayBuilder,
        onValueChange: (dates) {
          setState(() {
            selectedDates = dates;
          });
          
          // Announce selection to screen readers
          if (dates.isNotEmpty) {
            SemanticsService.announce(
              'Selected ${dates.length} date${dates.length == 1 ? '' : 's'}',
              TextDirection.ltr,
            );
          }
        },
      ),
    );
  }
}
```

### 4. Testing

```dart
// Example test file: test/flicker_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flicker/flicker.dart';

void main() {
  group('Flicker Widget Tests', () {
    testWidgets('should select single date', (WidgetTester tester) async {
      List<DateTime> selectedDates = [];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Flicker(
              mode: FlickerSelectionMode.single,
              value: selectedDates,
              onValueChange: (dates) {
                selectedDates = dates;
              },
            ),
          ),
        ),
      );
      
      // Find and tap a date
      final dateFinder = find.text('15');
      expect(dateFinder, findsOneWidget);
      
      await tester.tap(dateFinder);
      await tester.pump();
      
      // Verify selection
      expect(selectedDates.length, 1);
      expect(selectedDates.first.day, 15);
    });
    
    testWidgets('should respect disabled dates', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Flicker(
              disabledDate: (date) => date.weekday == DateTime.sunday,
              onValueChange: (dates) {},
            ),
          ),
        ),
      );
      
      // Sunday dates should be disabled
      // Add specific test logic here
    });
  });
}
```

---

## Conclusion

Flutter Flicker provides a comprehensive solution for date selection in Flutter applications. By following the examples and best practices in this guide, you can:

- Implement any type of date selection interface
- Customize appearance to match your app's design
- Support multiple languages and locales
- Optimize performance for large date ranges
- Create accessible and user-friendly date pickers

For more information, check out the [API Documentation](flicker_api_documentation.md) and the example applications in the repository.

---

**Happy coding with Flutter Flicker! 🗓️✨**