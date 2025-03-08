import 'dart:async';
import 'package:flutter/foundation.dart';

class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  static const int _memoryWarningThreshold = 100 * 1024 * 1024;

  static const int _memoryCriticalThreshold = 115 * 1024 * 1024;

  final List<Function()> _memoryWarningListeners = [];
  final List<Function()> _memoryCriticalListeners = [];

  Timer? _memoryCheckTimer;

  bool _isInLowMemoryState = false;

  void startMonitoring() {
    _memoryCheckTimer?.cancel();
    _memoryCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkMemoryUsage();
    });
  }

  void stopMonitoring() {
    _memoryCheckTimer?.cancel();
    _memoryCheckTimer = null;
  }

  void addMemoryWarningListener(Function() listener) {
    if (!_memoryWarningListeners.contains(listener)) {
      _memoryWarningListeners.add(listener);
    }
  }

  void removeMemoryWarningListener(Function() listener) {
    _memoryWarningListeners.remove(listener);
  }

  void addMemoryCriticalListener(Function() listener) {
    if (!_memoryCriticalListeners.contains(listener)) {
      _memoryCriticalListeners.add(listener);
    }
  }

  void removeMemoryCriticalListener(Function() listener) {
    _memoryCriticalListeners.remove(listener);
  }

  Future<void> _checkMemoryUsage() async {
    try {
      final memoryPressure = await _estimateMemoryPressure();

      if (memoryPressure >= _memoryCriticalThreshold) {
        for (final listener in _memoryCriticalListeners) {
          listener();
        }
        _isInLowMemoryState = true;
      } else if (memoryPressure >= _memoryWarningThreshold) {
        for (final listener in _memoryWarningListeners) {
          listener();
        }
        _isInLowMemoryState = true;
      } else {
        _isInLowMemoryState = false;
      }
    } catch (e) {
      debugPrint('Error checking memory usage: $e');
    }
  }

  Future<int> _estimateMemoryPressure() async {
    await _forceGarbageCollection();

    return 0;
  }

  Future<void> _forceGarbageCollection() async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }

  bool get isInLowMemoryState => _isInLowMemoryState;

  Future<void> triggerMemoryCleanup() async {
    for (final listener in _memoryWarningListeners) {
      listener();
    }

    await _forceGarbageCollection();
  }
}
