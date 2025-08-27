import 'package:flutter/foundation.dart';
import 'package:flutter_flicker/src/utils/date_helpers.dart';
// import './flicker.dart';

typedef Selected = List<DateTime>;

enum FlickerSelectionMode {
  /// Single date selection - user can select only one date
  single,

  /// Date range selection - user can select a start and end date
  range,

  /// Multiple date selection - user can select multiple individual dates
  many,
}

typedef SMode = FlickerSelectionMode;
// void Function(Selected);

class FlickerModel {
  final ValueChanged<Selected> sync;
  final bool Function(DateTime)? disabled;
  final VoidCallback? rebuild;

  FlickerModel({required this.sync, required this.disabled, this.rebuild});
  late FlickerSelectionMode mode = FlickerSelectionMode.single;
  late Selected selection = [];
  bool isToday(DateTime date) {
    return DateHelpers.isSameDay(date, DateTime.now());
  }

  /// Checks if a date falls within a selected range
  ///
  /// [date] - The date to check
  /// Returns true if date is between the first and last selected dates
  bool inRange(DateTime date, [String? type]) {
    if (selection.isEmpty || mode != FlickerSelectionMode.range) return false;
    final start = selection.first;
    final end = selection.last;
    if (type == 'start') return DateHelpers.isSameDay(date, start);
    if (type == 'end') return DateHelpers.isSameDay(date, end);
    return date.isAfter(start) && date.isBefore(end);
  }

  /// Checks if a date is currently selected
  ///
  /// [date] - The date to check
  /// Returns true if this date is in the selected dates list
  bool isContained(DateTime date) {
    if (selection.isEmpty) return false;
    return selection.any((d) => DateHelpers.isSameDay(d, date));
  }

  void update(Selected selected) {
    if (selection == selected) return;
    selection = selected;
  }

  void change(DateTime date) {
    switch (mode) {
      case FlickerSelectionMode.single:
        handleSingle(date);
        break;
      case FlickerSelectionMode.many:
        handleMany(date);
        break;
      case FlickerSelectionMode.range:
        handleRange(date);
        break;
    }

    sync(selection);
    rebuild?.call();
  }

  bool get isEmpty => selection.isEmpty;

  DateTime? get first {
    if (selection.isEmpty) return null;
    return selection.first;
  }

  DateTime? get last {
    if (selection.isEmpty) return null;
    return selection.last;
  }

  void handleSingle(DateTime date) {
    if (isContained(date)) {
      selection = [];
    } else {
      selection = [date];
    }
  }

  void handleMany(DateTime date) {
    if (isContained(date)) {
      selection.remove(date);
    } else {
      selection.add(date);
    }
    if (selection.length > 1) selection.sort((a, b) => a.compareTo(b));
  }

  void handleRange(DateTime date) {
    if (selection.length >= 2) selection = [];
    if (isContained(date)) {
      selection.remove(date);
    } else {
      selection.add(date);
    }
    if (selection.length == 2) selection.sort((a, b) => a.compareTo(b));
  }

  void onWidgetUpdate(Selected value, FlickerSelectionMode? mode) {
    if (this.mode != mode) this.mode = mode ?? FlickerSelectionMode.single;
    if (selection == value) return;
    // Selected next = selection;
    Selected next = List.from(value);
    if (next.isEmpty) {
      selection = next;

      return;
    }
    switch (this.mode) {
      case FlickerSelectionMode.single:
        if (disabled != null) {
          next.removeWhere((element) => disabled!(element));
        }
        if (next.isNotEmpty) {
          next = [next.last];
        }
        update(next);
        break;
      case FlickerSelectionMode.many:
        if (disabled != null) {
          next.removeWhere((element) => disabled!(element));
        }
        update(next);
        break;

      case FlickerSelectionMode.range:
        next = next.take(2).toList();
        if (disabled != null) {
          // Limit to maximum 2 dates for range mode
          next = next..removeWhere((date) => disabled!(date));
          // If we have exactly 2 dates, validate the range
          if (next.length == 2) {
            final startDate = next.first;
            final endDate = next.last;
            // For small ranges (≤7 days), check each day individually
            final daysDifference = endDate.difference(startDate).inDays;
            if (daysDifference <= 7) {
              bool hasDisabledDate = false;
              for (int i = 1; i < daysDifference; i++) {
                final checkDate = startDate.add(Duration(days: i));
                if (disabled!(checkDate)) {
                  hasDisabledDate = true;
                  break;
                }
              }
              // If disabled dates found in small range, keep only start date
              if (hasDisabledDate) {
                next = [startDate];
              }
            } else {
              // For larger ranges, use sampling approach for better performance
              // Check every 7th day and a few random days in between
              bool hasDisabledDate = false;
              final sample = <DateTime>[];
              // Add weekly samples
              for (int i = 7; i < daysDifference; i += 7) {
                sample.add(startDate.add(Duration(days: i)));
              }

              // Add a few random samples for better coverage
              if (daysDifference > 14) {
                sample.add(startDate.add(Duration(days: daysDifference ~/ 3)));
                sample.add(
                  startDate.add(Duration(days: (daysDifference * 2) ~/ 3)),
                );
              }

              // Check samples
              for (final sampleDate in sample) {
                if (disabled!(sampleDate)) {
                  hasDisabledDate = true;
                  break;
                }
              }
              // If disabled dates likely exist, keep only start date
              if (hasDisabledDate) {
                next = [startDate];
              }
            }
          }
        }
        update(next);

        break;
    }
  }
}
