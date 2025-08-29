import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flicker/src/views/date_helpers.dart';
import 'package:flutter_flicker/src/utils/performance_monitor.dart';

void main() {
  group('Performance Tests', () {
    setUp(() {
      // Clear caches before each test
      DateHelpers.clearCaches();
      PerformanceMonitor.clear();
    });

    test('DateHelpers.generateGrid performance with caching', () {
      final date = DateTime(2024, 1, 1);
      const firstDayOfWeek = 0;
      const viewCount = 1;

      // First call - should be slower (no cache)
      final stopwatch1 = Stopwatch()..start();
      final result1 = DateHelpers.generateGrid(date, firstDayOfWeek, viewCount);
      stopwatch1.stop();
      final firstCallTime = stopwatch1.elapsedMicroseconds;

      // Second call - should be faster (cached)
      final stopwatch2 = Stopwatch()..start();
      final result2 = DateHelpers.generateGrid(date, firstDayOfWeek, viewCount);
      stopwatch2.stop();
      final secondCallTime = stopwatch2.elapsedMicroseconds;

      // Verify results are identical
      expect(result1.length, equals(result2.length));
      for (int i = 0; i < result1.length; i++) {
        expect(result1[i].length, equals(result2[i].length));
        for (int j = 0; j < result1[i].length; j++) {
          expect(result1[i][j], equals(result2[i][j]));
        }
      }

      // Second call should be significantly faster (cache hit)
      expect(secondCallTime, lessThan(firstCallTime));
      
      print('First call (no cache): ${firstCallTime}μs');
      print('Second call (cached): ${secondCallTime}μs');
      print('Performance improvement: ${((firstCallTime - secondCallTime) / firstCallTime * 100).toStringAsFixed(1)}%');
    });

    test('DateHelpers.generateCalendar performance with caching', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 12, 31);

      // First call - should be slower (no cache)
      final stopwatch1 = Stopwatch()..start();
      final result1 = DateHelpers.generateCalendar(start, end);
      stopwatch1.stop();
      final firstCallTime = stopwatch1.elapsedMicroseconds;

      // Second call - should be faster (cached)
      final stopwatch2 = Stopwatch()..start();
      final result2 = DateHelpers.generateCalendar(start, end);
      stopwatch2.stop();
      final secondCallTime = stopwatch2.elapsedMicroseconds;

      // Verify results are identical
      expect(result1.length, equals(result2.length));
      for (int i = 0; i < result1.length; i++) {
        expect(result1[i], equals(result2[i]));
      }

      // Second call should be significantly faster (cache hit)
      expect(secondCallTime, lessThan(firstCallTime));
      
      print('First call (no cache): ${firstCallTime}μs');
      print('Second call (cached): ${secondCallTime}μs');
      print('Performance improvement: ${((firstCallTime - secondCallTime) / firstCallTime * 100).toStringAsFixed(1)}%');
    });

    test('Cache statistics and management', () {
      // Generate some data to populate caches
      DateHelpers.generateGrid(DateTime(2024, 1, 1), 0, 1);
      DateHelpers.generateGrid(DateTime(2024, 2, 1), 0, 1);
      DateHelpers.generateCalendar(DateTime(2024, 1, 1), DateTime(2024, 6, 30));
      DateHelpers.generateCalendar(DateTime(2024, 7, 1), DateTime(2024, 12, 31));

      // Check cache statistics
      final stats = DateHelpers.getCacheStats();
      expect(stats['gridCacheSize'], greaterThan(0));
      expect(stats['calendarCacheSize'], greaterThan(0));
      expect(stats['maxCacheSize'], equals(50));

      print('Cache statistics: $stats');

      // Clear caches
      DateHelpers.clearCaches();
      final clearedStats = DateHelpers.getCacheStats();
      expect(clearedStats['gridCacheSize'], equals(0));
      expect(clearedStats['calendarCacheSize'], equals(0));
    });

    test('Performance monitor functionality', () {
      // Test timing operations
      final result = PerformanceMonitor.timeOperation('testOperation', () {
        // Simulate some work
        var sum = 0;
        for (int i = 0; i < 1000; i++) {
          sum += i;
        }
        return sum;
      });

      expect(result, equals(499500)); // Sum of 0 to 999
      print('Performance monitoring test completed successfully');
    });

    test('Large dataset performance', () {
      // Test with a large date range
      final start = DateTime(2000, 1, 1);
      final end = DateTime(2030, 12, 31);

      final stopwatch = Stopwatch()..start();
      final result = DateHelpers.generateCalendar(start, end);
      stopwatch.stop();

      // Should generate 31 years * 12 months = 372 months
      expect(result.length, equals(372));
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast

      print('Large dataset (372 months) generated in: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Memory usage with cache limits', () {
      // Generate more than the cache limit to test eviction
      for (int year = 2000; year < 2060; year++) {
        DateHelpers.generateGrid(DateTime(year, 1, 1), 0, 1);
        DateHelpers.generateCalendar(DateTime(year, 1, 1), DateTime(year, 12, 31));
      }

      final stats = DateHelpers.getCacheStats();
      // Cache should not exceed the maximum size
      expect(stats['gridCacheSize']!, lessThanOrEqualTo(stats['maxCacheSize']!));
      expect(stats['calendarCacheSize']!, lessThanOrEqualTo(stats['maxCacheSize']!));

      print('Cache sizes after generating 60 years of data: $stats');
    });
  });
}