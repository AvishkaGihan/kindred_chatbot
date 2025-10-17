import 'package:flutter_test/flutter_test.dart';
import 'package:kindred_chatbot/utils/performance/performance_monitor.dart';

void main() {
  group('PerformanceMonitor Tests', () {
    late PerformanceMonitor monitor;

    setUp(() {
      monitor = PerformanceMonitor();
      // Clear any existing timers
      monitor.stopTimer('test');
    });

    test('startTimer and stopTimer measure duration', () async {
      monitor.startTimer('test_operation');

      // Simulate some work
      await Future.delayed(const Duration(milliseconds: 100));

      final duration = monitor.stopTimer('test_operation');

      expect(duration, isNotNull);
      expect(duration!.inMilliseconds, greaterThanOrEqualTo(100));
    });

    test('stopTimer without startTimer returns null', () {
      final duration = monitor.stopTimer('nonexistent');
      expect(duration, isNull);
    });

    test('measureSync measures synchronous function', () {
      int result = 0;

      final returnedResult = PerformanceMonitor.measureSync('sync_test', () {
        result = 42;
        return result;
      });

      expect(result, equals(42));
      expect(returnedResult, equals(42));
    });

    test('measureAsync measures asynchronous function', () async {
      int result = 0;

      final returnedResult = await PerformanceMonitor.measureAsync(
        'async_test',
        () async {
          await Future.delayed(const Duration(milliseconds: 50));
          result = 100;
          return result;
        },
      );

      expect(result, equals(100));
      expect(returnedResult, equals(100));
    });

    test('multiple timers work independently', () async {
      monitor.startTimer('timer1');
      await Future.delayed(const Duration(milliseconds: 50));

      monitor.startTimer('timer2');
      await Future.delayed(const Duration(milliseconds: 50));

      final duration1 = monitor.stopTimer('timer1');
      final duration2 = monitor.stopTimer('timer2');

      expect(duration1, isNotNull);
      expect(duration2, isNotNull);
      expect(duration1!.inMilliseconds, greaterThan(duration2!.inMilliseconds));
    });
  });

  group('FrameTimingInfo Tests', () {
    test('isJanky detects frames over 16ms', () {
      final smoothFrame = FrameTimingInfo(
        buildDuration: 5,
        rasterDuration: 5,
        totalDuration: 10,
        isJanky: false,
      );

      final jankyFrame = FrameTimingInfo(
        buildDuration: 10,
        rasterDuration: 10,
        totalDuration: 20,
        isJanky: true,
      );

      expect(smoothFrame.isJanky, false);
      expect(jankyFrame.isJanky, true);
    });
  });

  group('FrameTimingStats Tests', () {
    test('fps calculates correctly', () {
      final stats = FrameTimingStats(
        avgBuildDuration: 5.0,
        avgRasterDuration: 5.0,
        avgTotalDuration: 10.0,
        maxTotalDuration: 15,
        jankyFramePercentage: 2.0,
        fps: 100.0,
      );

      expect(stats.fps, equals(100.0));
    });

    test('fps handles zero duration', () {
      final stats = FrameTimingStats(
        avgBuildDuration: 0.0,
        avgRasterDuration: 0.0,
        avgTotalDuration: 0.0,
        maxTotalDuration: 0,
        jankyFramePercentage: 0.0,
        fps: 0.0,
      );

      expect(stats.fps, equals(0.0));
    });

    test('isPerformant returns correct values', () {
      final performantStats = FrameTimingStats(
        avgBuildDuration: 5.0,
        avgRasterDuration: 5.0,
        avgTotalDuration: 10.0,
        maxTotalDuration: 15,
        jankyFramePercentage: 2.0, // Less than 5%
        fps: 100.0,
      );

      final slowStats = FrameTimingStats(
        avgBuildDuration: 10.0,
        avgRasterDuration: 10.0,
        avgTotalDuration: 20.0,
        maxTotalDuration: 30,
        jankyFramePercentage: 10.0, // More than 5%
        fps: 50.0,
      );

      expect(performantStats.isPerformant, true);
      expect(slowStats.isPerformant, false);
    });
  });

  group('NetworkMonitor Tests', () {
    test('measureRequest measures network call duration', () async {
      String result = '';

      final returnedResult = await NetworkMonitor.measureRequest(
        'test_api_call',
        () async {
          await Future.delayed(const Duration(milliseconds: 100));
          result = 'success';
          return result;
        },
      );

      expect(result, equals('success'));
      expect(returnedResult, equals('success'));
    });

    test('startRequest and stopRequest measure duration', () async {
      NetworkMonitor.startRequest('request_1');

      await Future.delayed(const Duration(milliseconds: 50));

      NetworkMonitor.stopRequest('request_1');

      // stopRequest returns void, so we just verify it doesn't throw
    });
  });
}
