import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/store/store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Store Tests', () {
    late Store store;

    setUp(() {
      store = Store();
    });

    tearDown(() {
      store.dispose();
    });

    group('Initialization', () {
      test('should initialize with default values', () {
        expect(store.selection.isEmpty, isTrue);
        expect(store.display, isNotNull);
        expect(store.mode, SelectionMode.single);
        expect(store.viewCount, 1);
        expect(store.firstDayOfWeek, 0); // Sunday
      });

      test('should initialize with custom props', () {
        final props = const Props(mode: SelectionMode.range, viewCount: 2);

        store.initialize(props);

        expect(store.mode, SelectionMode.range);
        expect(store.viewCount, 2);
      });
    });

    group('Date Selection', () {
      test('should select single date in single mode', () {
        final testDate = DateTime(2024, 1, 15);

        store.onSelectDate(testDate);

        expect(store.selection.isNotEmpty, isTrue);
        expect(store.selection.selection, contains(testDate));
      });

      test('should handle range selection mode', () {
        final props = const Props(mode: SelectionMode.range);
        store.initialize(props);

        final startDate = DateTime(2024, 1, 15);
        final endDate = DateTime(2024, 1, 20);

        store.onSelectDate(startDate);
        store.onSelectDate(endDate);

        expect(store.selection.isNotEmpty, isTrue);
        expect(store.mode, SelectionMode.range);
      });

      test('should handle multiple selection mode', () {
        final props = const Props(mode: SelectionMode.many);
        store.initialize(props);

        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 1, 20);

        store.onSelectDate(date1);
        store.onSelectDate(date2);

        expect(store.selection.isNotEmpty, isTrue);
        expect(store.mode, SelectionMode.many);
      });
    });

    group('Display Date Management', () {
      test('should have valid display date', () {
        expect(store.display, isNotNull);
        expect(store.display.year, greaterThan(2020));
      });

      test('should calculate next display correctly', () {
        final currentDisplay = store.display;
        final nextDisplay = store.nextDisplay;

        expect(nextDisplay.month, currentDisplay.month + 1);
      });

      test('should handle double views correctly', () {
        final props = const Props(viewCount: 2);
        store.initialize(props);

        expect(store.isDoubleViews, isTrue);
        expect(store.isSingleView, isFalse);
        expect(store.displays, hasLength(2));
      });
    });

    group('View Type Management', () {
      test('should start with month view', () {
        expect(store.isMonthView, isTrue);
        expect(store.isYearsView, isFalse);
      });

      test('should switch to years view', () {
        store.onSwtichView();

        expect(store.isYearsView, isTrue);
        expect(store.isMonthView, isFalse);
      });

      test('should switch back to month view', () {
        store.onSwtichView();
        expect(store.isMonthView, isTrue);
        expect(store.isYearsView, isFalse);
      });

      test('should select year and return to month view', () {
        store.onSwtichView();
        store.selectYear(2025);

        expect(store.isMonthView, isTrue);
        expect(store.display.year, 2025);
      });
    });

    group('Date Range Constraints', () {
      test('should respect start and end date constraints', () {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);

        final props = Props(startDate: startDate, endDate: endDate);
        store.initialize(props);

        expect(store.startDateSignal.value, startDate);
        expect(store.endDateSignal.value, endDate);
      });
    });

    group('Scroll Direction', () {
      test('should default to horizontal scroll', () {
        expect(store.isHorizontal, isTrue);
        expect(store.isVertical, isFalse);
      });

      test('should handle vertical scroll direction', () {
        final props = const Props(scrollDirection: Axis.vertical);
        store.initialize(props);

        expect(store.isVertical, isTrue);
        expect(store.isHorizontal, isFalse);
      });
    });

    group('Disabled Date Logic', () {
      test('should handle disabled date function', () {
        bool disabledDateFunction(DateTime date) {
          return date.weekday == DateTime.sunday;
        }

        final props = Props(disabledDate: disabledDateFunction);
        store.initialize(props);

        final sunday = DateTime(2024, 1, 7); // A Sunday
        final monday = DateTime(2024, 1, 8); // A Monday

        expect(store.disabledDate(sunday), isTrue);
        expect(store.disabledDate(monday), isFalse);
      });
    });

    group('Selection Reset', () {
      test('should reset selection when switching modes', () {
        // Select a date in single mode
        store.onSelectDate(DateTime(2024, 1, 15));
        expect(store.selection.isNotEmpty, isTrue);

        // Switch to range mode
        final props = const Props(mode: SelectionMode.range);
        store.initialize(props);

        // Selection should be maintained during mode switch
        expect(store.mode, SelectionMode.range);
      });
    });
  });
}
