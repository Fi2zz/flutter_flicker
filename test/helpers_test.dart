import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flicker/src/helpers/helpers.dart';

void main() {
  group('DateHelpers Tests', () {
    group('Date Comparison', () {
      test('should correctly identify same day', () {
        final date1 = DateTime(2024, 1, 15, 10, 30);
        final date2 = DateTime(2024, 1, 15, 14, 45);

        expect(DateHelpers.isSameDay(date1, date2), isTrue);
      });

      test('should correctly identify different days', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 16);

        expect(DateHelpers.isSameDay(date1, date2), isFalse);
      });

      test('should correctly identify same month', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 25);

        expect(DateHelpers.isSameMonth(date1, date2), isTrue);
      });

      test('should correctly identify different months', () {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 2, 15);

        expect(DateHelpers.isSameMonth(date1, date2), isFalse);
      });
    });

    group('Month Navigation', () {
      test('should get next month correctly', () {
        final january = DateTime(2024, 1, 15);
        final february = DateHelpers.nextMonth(january);

        expect(february.year, 2024);
        expect(february.month, 2);
        expect(february.day, 1); // Should be first day of month
      });

      test('should handle year boundary for next month', () {
        final december = DateTime(2024, 12, 15);
        final january = DateHelpers.nextMonth(december);

        expect(january.year, 2025);
        expect(january.month, 1);
      });

      test('should get previous month correctly', () {
        final february = DateTime(2024, 2, 15);
        final january = DateHelpers.prevMonth(february);

        expect(january.year, 2024);
        expect(january.month, 1);
        expect(january.day, 1); // Should be first day of month
      });

      test('should handle year boundary for previous month', () {
        final january = DateTime(2024, 1, 15);
        final december = DateHelpers.prevMonth(january);

        expect(december.year, 2023);
        expect(december.month, 12);
      });
    });

    group('Month Information', () {
      test('should get correct days in month', () {
        final january = DateTime(2024, 1, 15);
        final february = DateTime(2024, 2, 15); // Leap year
        final april = DateTime(2024, 4, 15);

        expect(DateHelpers.getDaysInMonth(january), 31);
        expect(DateHelpers.getDaysInMonth(february), 29); // Leap year
        expect(DateHelpers.getDaysInMonth(april), 30);
      });
    });

    group('Utility Functions', () {
      test('should handle null date gracefully', () {
        final result = DateHelpers.maybeToday(null);

        expect(result, isNotNull);
        // Should return today's date
        final today = DateTime.now();
        expect(result.year, today.year);
        expect(result.month, today.month);
        expect(result.day, today.day);
      });

      test('should return normalized date when not null', () {
        final date = DateTime(2024, 1, 15, 10, 30, 45);
        final result = DateHelpers.maybeToday(date);

        expect(result.year, 2024);
        expect(result.month, 1);
        expect(result.day, 15);
        expect(result.hour, 0); // Should be normalized
        expect(result.minute, 0);
        expect(result.second, 0);
      });

      test('should get today correctly', () {
        final today = DateHelpers.getToday();
        final now = DateTime.now();

        expect(today.year, now.year);
        expect(today.month, now.month);
        expect(today.day, now.day);
        expect(today.hour, 0); // Should be normalized
        expect(today.minute, 0);
        expect(today.second, 0);
      });
    });
  });
}
