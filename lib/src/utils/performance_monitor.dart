import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_flicker/src/views/date_helpers.dart';

/// Performance monitoring utility for Flutter Flicker
///
/// Provides tools to measure and monitor performance of calendar operations
class PerformanceMonitor {
  static const String _tag = 'FlickerPerformance';
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<int>> _measurements = {};
  
  /// Start timing an operation
  ///
  /// [operationName] Name of the operation to time
  static void startTiming(String operationName) {
    if (kDebugMode) {
      _startTimes[operationName] = DateTime.now();
      developer.log('Started timing: $operationName', name: _tag);
    }
  }
  
  /// End timing an operation and record the duration
  ///
  /// [operationName] Name of the operation to end timing
  /// Returns the duration in milliseconds
  static int endTiming(String operationName) {
    if (!kDebugMode) return 0;
    
    final startTime = _startTimes[operationName];
    if (startTime == null) {
      developer.log('Warning: No start time found for $operationName', name: _tag);
      return 0;
    }
    
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    _startTimes.remove(operationName);
    
    // Store measurement
    _measurements.putIfAbsent(operationName, () => []).add(duration);
    
    developer.log('Completed $operationName in ${duration}ms', name: _tag);
    return duration;
  }
  
  /// Time a synchronous operation
  ///
  /// [operationName] Name of the operation
  /// [operation] Function to execute and time
  /// Returns the result of the operation
  static T timeOperation<T>(String operationName, T Function() operation) {
    startTiming(operationName);
    try {
      final result = operation();
      endTiming(operationName);
      return result;
    } catch (e) {
      endTiming(operationName);
      rethrow;
    }
  }
  
  /// Time an asynchronous operation
  ///
  /// [operationName] Name of the operation
  /// [operation] Async function to execute and time
  /// Returns the result of the operation
  static Future<T> timeAsyncOperation<T>(String operationName, Future<T> Function() operation) async {
    startTiming(operationName);
    try {
      final result = await operation();
      endTiming(operationName);
      return result;
    } catch (e) {
      endTiming(operationName);
      rethrow;
    }
  }
  
  /// Get performance statistics for an operation
  ///
  /// [operationName] Name of the operation
  /// Returns a map with min, max, average, and count statistics
  static Map<String, dynamic> getStats(String operationName) {
    final measurements = _measurements[operationName];
    if (measurements == null || measurements.isEmpty) {
      return {
        'count': 0,
        'min': 0,
        'max': 0,
        'average': 0.0,
        'total': 0,
      };
    }
    
    final min = measurements.reduce((a, b) => a < b ? a : b);
    final max = measurements.reduce((a, b) => a > b ? a : b);
    final total = measurements.reduce((a, b) => a + b);
    final average = total / measurements.length;
    
    return {
      'count': measurements.length,
      'min': min,
      'max': max,
      'average': average,
      'total': total,
    };
  }
  
  /// Get all performance statistics
  ///
  /// Returns a map of all operation statistics
  static Map<String, Map<String, dynamic>> getAllStats() {
    final allStats = <String, Map<String, dynamic>>{};
    for (final operationName in _measurements.keys) {
      allStats[operationName] = getStats(operationName);
    }
    return allStats;
  }
  
  /// Print performance report to console
  ///
  /// [operationName] Optional specific operation to report on
  static void printReport([String? operationName]) {
    if (!kDebugMode) return;
    
    developer.log('=== Flutter Flicker Performance Report ===', name: _tag);
    
    if (operationName != null) {
      final stats = getStats(operationName);
      _printOperationStats(operationName, stats);
    } else {
      final allStats = getAllStats();
      for (final entry in allStats.entries) {
        _printOperationStats(entry.key, entry.value);
      }
    }
    
    // Print cache statistics
    final cacheStats = DateHelpers.getCacheStats();
    developer.log('Cache Statistics:', name: _tag);
    for (final entry in cacheStats.entries) {
      developer.log('  ${entry.key}: ${entry.value}', name: _tag);
    }
    
    developer.log('=== End Performance Report ===', name: _tag);
  }
  
  /// Print statistics for a specific operation
  static void _printOperationStats(String operationName, Map<String, dynamic> stats) {
    developer.log('Operation: $operationName', name: _tag);
    developer.log('  Count: ${stats['count']}', name: _tag);
    developer.log('  Min: ${stats['min']}ms', name: _tag);
    developer.log('  Max: ${stats['max']}ms', name: _tag);
    developer.log('  Average: ${stats['average'].toStringAsFixed(2)}ms', name: _tag);
    developer.log('  Total: ${stats['total']}ms', name: _tag);
  }
  
  /// Clear all performance data
  static void clear() {
    _startTimes.clear();
    _measurements.clear();
    DateHelpers.clearCaches();
    if (kDebugMode) {
      developer.log('Performance data cleared', name: _tag);
    }
  }
  
  /// Check if performance monitoring is enabled
  static bool get isEnabled => kDebugMode;
  
  /// Get current memory usage statistics
  static Map<String, dynamic> getMemoryStats() {
    if (!kDebugMode) return {};
    
    return {
      'startTimesCount': _startTimes.length,
      'measurementsCount': _measurements.length,
      'totalMeasurements': _measurements.values.fold(0, (sum, list) => sum + list.length),
      'cacheStats': DateHelpers.getCacheStats(),
    };
  }
}

/// Extension to add performance monitoring to DateHelpers
extension DateHelpersPerformance on DateHelpers {
  /// Generate grid with performance monitoring
  static List<List<DateTime?>> generateGridWithMonitoring(
    DateTime date,
    int firstDayOfWeek,
    int viewCount,
  ) {
    return PerformanceMonitor.timeOperation(
      'generateGrid',
      () => DateHelpers.generateGrid(date, firstDayOfWeek, viewCount),
    );
  }
  
  /// Generate calendar with performance monitoring
  static List<DateTime> generateCalendarWithMonitoring(DateTime start, DateTime end) {
    return PerformanceMonitor.timeOperation(
      'generateCalendar',
      () => DateHelpers.generateCalendar(start, end),
    );
  }
}