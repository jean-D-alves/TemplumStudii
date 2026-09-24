import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:templum_studdi/models/time.dart';

class StudyTimerController extends ChangeNotifier {
  Timer? _ticker;
  DateTime? _startedAt;
  Duration _accumulated = Duration.zero;
  Duration _goal = const Duration(minutes: 1);

  Duration get goal => _goal;

  Duration get current {
    if (_startedAt == null) return _accumulated;
    final extra = DateTime.now().difference(_startedAt!);
    if (extra.isNegative) return _accumulated;
    return _accumulated + extra;
  }

  bool get isRunning => _startedAt != null;

  bool get isPaused => _startedAt == null && _accumulated != Duration.zero;

  bool get goalReached {
    if (_goal.inMilliseconds <= 0) return false;
    return current >= _goal;
  }

  double get progress {
    if (_goal.inMilliseconds <= 0) return 0;
    return (current.inMilliseconds / _goal.inMilliseconds).clamp(0.0, 1.0);
  }

  void setGoal(Duration value) {
    if (isRunning) return;
    _goal = value;
    notifyListeners();
  }

  void syncFromServer(Time? record) {
    if (record == null) return;
    _goal = record.definedDuration;
    final startedAt = record.StartedAt?.toLocal();
    if (startedAt != null &&
        startedAt.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
      _applyRunningState(record, startedAt);
      return;
    }
    _accumulated = record.accumulatedDuration;
    _startedAt = null;
    _stopTicker();
    notifyListeners();
  }

  void applyServerStart(Time record) {
    _applyRunningState(
      record,
      record.StartedAt?.toLocal() ?? DateTime.now(),
    );
  }

  void applyServerStop(Time record) {
    _accumulated = record.accumulatedDuration;
    _startedAt = null;
    _stopTicker();
    notifyListeners();
  }

  void _applyRunningState(Time record, DateTime startedAt) {
    _accumulated = record.accumulatedDuration;
    final serverElapsed = record.ServerNow.toLocal().difference(startedAt);
    if (serverElapsed > Duration.zero) {
      _accumulated += serverElapsed;
    }
    _startedAt = DateTime.now();
    _ensureTicker();
    notifyListeners();
  }

  void start() {
    if (_startedAt != null) return;
    _startedAt = DateTime.now();
    _ensureTicker();
    notifyListeners();
  }

  void pause() {
    if (_startedAt == null) return;
    _accumulated += DateTime.now().difference(_startedAt!);
    _startedAt = null;
    _stopTicker();
    notifyListeners();
  }

  void reset() {
    _startedAt = null;
    _accumulated = Duration.zero;
    _stopTicker();
    notifyListeners();
  }

  void _ensureTicker() {
    if (_ticker != null) return;
    _ticker = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => notifyListeners(),
    );
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}

String formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}