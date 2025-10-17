import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

/// Performance monitoring utilities
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};
  final List<FrameTimingInfo> _frameTimings = [];
  static const int _maxFrameTimings = 100;

  /// Start timing an operation
  void startTimer(String operationName) {
    _timers[operationName] = Stopwatch()..start();
  }

  /// Stop timing an operation and log the duration
  Duration? stopTimer(String operationName) {
    final timer = _timers[operationName];
    if (timer == null) return null;

    timer.stop();
    final duration = timer.elapsed;
    _timers.remove(operationName);

    if (kDebugMode) {
      print('⏱️ $operationName took: ${duration.inMilliseconds}ms');
    }

    return duration;
  }

  /// Measure the execution time of a function
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      if (kDebugMode) {
        print('⏱️ $operationName took: ${stopwatch.elapsedMilliseconds}ms');
      }
      return result;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '❌ $operationName failed after: ${stopwatch.elapsedMilliseconds}ms',
        );
      }
      rethrow;
    }
  }

  /// Measure the execution time of a synchronous function
  static T measureSync<T>(String operationName, T Function() operation) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = operation();
      stopwatch.stop();
      if (kDebugMode) {
        print('⏱️ $operationName took: ${stopwatch.elapsedMilliseconds}ms');
      }
      return result;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '❌ $operationName failed after: ${stopwatch.elapsedMilliseconds}ms',
        );
      }
      rethrow;
    }
  }

  /// Start monitoring frame timings
  void startFrameMonitoring() {
    SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);
  }

  /// Stop monitoring frame timings
  void stopFrameMonitoring() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTiming);
  }

  void _onFrameTiming(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildDuration = timing.buildDuration.inMilliseconds;
      final rasterDuration = timing.rasterDuration.inMilliseconds;
      final totalDuration = timing.totalSpan.inMilliseconds;

      final info = FrameTimingInfo(
        buildDuration: buildDuration,
        rasterDuration: rasterDuration,
        totalDuration: totalDuration,
        isJanky: totalDuration > 16, // 60fps = 16.67ms per frame
      );

      _frameTimings.add(info);

      // Keep only recent timings
      if (_frameTimings.length > _maxFrameTimings) {
        _frameTimings.removeAt(0);
      }

      // Log janky frames in debug mode
      if (kDebugMode && info.isJanky) {
        debugPrint(
          '🐌 Janky frame detected: ${info.totalDuration}ms (build: ${info.buildDuration}ms, raster: ${info.rasterDuration}ms)',
        );
      }
    }
  }

  /// Get frame timing statistics
  FrameTimingStats getFrameStats() {
    if (_frameTimings.isEmpty) {
      return FrameTimingStats.empty();
    }

    final buildDurations = _frameTimings.map((f) => f.buildDuration).toList();
    final rasterDurations = _frameTimings.map((f) => f.rasterDuration).toList();
    final totalDurations = _frameTimings.map((f) => f.totalDuration).toList();
    final jankyCount = _frameTimings.where((f) => f.isJanky).length;

    return FrameTimingStats(
      avgBuildDuration: _average(buildDurations),
      avgRasterDuration: _average(rasterDurations),
      avgTotalDuration: _average(totalDurations),
      maxTotalDuration: totalDurations.reduce((a, b) => a > b ? a : b),
      jankyFramePercentage: (jankyCount / _frameTimings.length) * 100,
      fps: 1000 / _average(totalDurations),
    );
  }

  double _average(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Log performance summary
  void logPerformanceSummary() {
    if (!kDebugMode) return;

    final stats = getFrameStats();
    debugPrint('📊 Performance Summary:');
    debugPrint('   FPS: ${stats.fps.toStringAsFixed(1)}');
    debugPrint(
      '   Avg Frame Time: ${stats.avgTotalDuration.toStringAsFixed(1)}ms',
    );
    debugPrint('   Max Frame Time: ${stats.maxTotalDuration}ms');
    debugPrint(
      '   Janky Frames: ${stats.jankyFramePercentage.toStringAsFixed(1)}%',
    );
  }

  /// Clear all timers and statistics
  void clear() {
    _timers.clear();
    _frameTimings.clear();
  }
}

/// Frame timing information
class FrameTimingInfo {
  final int buildDuration;
  final int rasterDuration;
  final int totalDuration;
  final bool isJanky;

  FrameTimingInfo({
    required this.buildDuration,
    required this.rasterDuration,
    required this.totalDuration,
    required this.isJanky,
  });
}

/// Frame timing statistics
class FrameTimingStats {
  final double avgBuildDuration;
  final double avgRasterDuration;
  final double avgTotalDuration;
  final int maxTotalDuration;
  final double jankyFramePercentage;
  final double fps;

  FrameTimingStats({
    required this.avgBuildDuration,
    required this.avgRasterDuration,
    required this.avgTotalDuration,
    required this.maxTotalDuration,
    required this.jankyFramePercentage,
    required this.fps,
  });

  factory FrameTimingStats.empty() {
    return FrameTimingStats(
      avgBuildDuration: 0,
      avgRasterDuration: 0,
      avgTotalDuration: 0,
      maxTotalDuration: 0,
      jankyFramePercentage: 0,
      fps: 60,
    );
  }

  bool get isPerformant => fps >= 55 && jankyFramePercentage < 5;
}

/// Memory monitoring utilities
class MemoryMonitor {
  /// Log current memory usage (debug only)
  static void logMemoryUsage(String label) {
    if (!kDebugMode) return;

    // Note: Detailed memory monitoring requires platform channels
    // This is a placeholder for memory monitoring
    debugPrint('💾 Memory checkpoint: $label');
  }

  /// Check if app is running on a low-memory device
  static bool isLowMemoryDevice() {
    // Basic heuristic: assume devices with smaller screens might be lower memory
    // In a real implementation, use device_info_plus package for accurate detection
    try {
      final mediaQuery = WidgetsBinding.instance.platformDispatcher.views.first;
      final devicePixelRatio = mediaQuery.devicePixelRatio;
      final physicalSize = mediaQuery.physicalSize;

      // Rough estimate: if screen area is small, might be lower memory device
      final screenArea =
          physicalSize.width *
          physicalSize.height /
          (devicePixelRatio * devicePixelRatio);
      return screenArea < 1000000; // Less than ~1M logical pixels
    } catch (e) {
      // Fallback: assume not low memory if we can't determine
      return false;
    }
  }
}

/// Network performance monitoring
class NetworkMonitor {
  static final Map<String, Stopwatch> _networkTimers = {};

  /// Start timing a network request
  static void startRequest(String requestId) {
    _networkTimers[requestId] = Stopwatch()..start();
  }

  /// Stop timing a network request and log the duration
  static void stopRequest(String requestId, {bool success = true}) {
    final timer = _networkTimers[requestId];
    if (timer == null) return;

    timer.stop();
    final duration = timer.elapsedMilliseconds;
    _networkTimers.remove(requestId);

    if (kDebugMode) {
      final status = success ? '✅' : '❌';
      print('$status Network request $requestId: ${duration}ms');
    }
  }

  /// Measure network request time
  static Future<T> measureRequest<T>(
    String requestId,
    Future<T> Function() request,
  ) async {
    startRequest(requestId);
    try {
      final result = await request();
      stopRequest(requestId, success: true);
      return result;
    } catch (e) {
      stopRequest(requestId, success: false);
      rethrow;
    }
  }
}

/// Widget build performance monitor
class BuildPerformanceObserver with WidgetsBindingObserver {
  static final BuildPerformanceObserver _instance =
      BuildPerformanceObserver._internal();
  factory BuildPerformanceObserver() => _instance;
  BuildPerformanceObserver._internal();

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) {
      print('📱 App lifecycle changed: $state');
    }
  }

  @override
  void didChangeMetrics() {
    if (kDebugMode) {
      print('📐 Metrics changed (rotation/resize)');
    }
  }
}
