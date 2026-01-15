// WEEK 6: ACCELEROMETER PROVIDER
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Model fitur accelerometer: mean & variance dari magnitude |a|.
class AccelFeature {
  final double mean;
  final double variance;

  AccelFeature({required this.mean, required this.variance});
}

/// Provider stream accelerometer mentah
final accelerometerStreamProvider = StreamProvider.autoDispose((ref) {
  return accelerometerEventStream();
});

/// Provider fitur accelerometer (sliding window 50 sampel)
final accelFeatureProvider =
    StateNotifierProvider<AccelFeatureNotifier, AccelFeature>((ref) {
      return AccelFeatureNotifier();
    });

class AccelFeatureNotifier extends StateNotifier<AccelFeature> {
  AccelFeatureNotifier() : super(AccelFeature(mean: 0, variance: 0)) {
    _start();
  }

  final List<double> _buffer = [];

  void _start() {
    accelerometerEventStream().listen((event) {
      // Hitung magnitude percepatan
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Sliding window 50 sampel
      _buffer.add(magnitude);
      if (_buffer.length > 50) _buffer.removeAt(0);

      _updateStats();
    });
  }

  void _updateStats() {
    if (_buffer.isEmpty) return;

    final mean = _buffer.reduce((a, b) => a + b) / _buffer.length;

    final variance = _buffer.length > 1
        ? _buffer.fold<double>(0.0, (sum, x) => sum + pow(x - mean, 2)) /
              (_buffer.length - 1)
        : 0.0;

    state = AccelFeature(mean: mean, variance: variance);
  }

  void reset() {
    _buffer.clear();
    state = AccelFeature(mean: 0, variance: 0);
  }
}
