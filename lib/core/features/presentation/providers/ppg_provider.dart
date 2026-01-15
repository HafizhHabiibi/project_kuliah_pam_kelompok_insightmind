import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PpgState {
  final bool capturing;
  final List<double> samples;
  final double mean;
  final double variance;

  PpgState({
    required this.capturing,
    required this.samples,
    required this.mean,
    required this.variance,
  });

  PpgState copyWith({
    bool? capturing,
    List<double>? samples,
    double? mean,
    double? variance,
  }) {
    return PpgState(
      capturing: capturing ?? this.capturing,
      samples: samples ?? this.samples,
      mean: mean ?? this.mean,
      variance: variance ?? this.variance,
    );
  }
}

/// Provider untuk state PPG
final ppgProvider = StateNotifierProvider<PpgNotifier, PpgState>((ref) {
  return PpgNotifier();
});

class PpgNotifier extends StateNotifier<PpgState> {
  PpgNotifier()
    : super(PpgState(capturing: false, samples: [], mean: 0, variance: 0));

  CameraController? _controller;

  Future<void> startCapture() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('cameraNotAvailable');
      }
      final cam = cameras.first;

      // Clean up existing controller if present
      if (_controller != null) {
        try {
          if (_controller!.value.isStreamingImages) {
            await _controller!.stopImageStream();
          }
        } catch (_) {}
        try {
          await _controller!.dispose();
        } catch (_) {}
        _controller = null;
      }

      _controller = CameraController(
        cam,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await _controller!.initialize();
      state = state.copyWith(capturing: true);

      if (!_controller!.value.isStreamingImages) {
        _controller!.startImageStream((image) {
          // Kanal Y (luminance) berada di plane pertama
          final plane = image.planes[0];
          final buffer = plane.bytes;

          // Sampling per 50 byte untuk efisiensi
          double sum = 0;
          int count = 0;

          for (int i = 0; i < buffer.length; i += 50) {
            sum += buffer[i];
            count++;
          }

          final meanY = sum / count;

          // Update sliding window 300 sampel
          final newSamples = [...state.samples, meanY];
          if (newSamples.length > 300) newSamples.removeAt(0);

          final mean = newSamples.reduce((a, b) => a + b) / newSamples.length;

          final variance =
              newSamples.fold(0.0, (s, x) => s + pow(x - mean, 2)) /
              max(1, newSamples.length - 1);

          state = state.copyWith(
            samples: newSamples,
            mean: mean,
            variance: variance,
          );
        });
      }
    } on CameraException catch (_) {
      try {
        await _controller?.dispose();
      } catch (_) {}
      _controller = null;
      state = state.copyWith(capturing: false);
      rethrow;
    } catch (_) {
      try {
        await _controller?.dispose();
      } catch (_) {}
      _controller = null;
      state = state.copyWith(capturing: false);
      rethrow;
    }
  }

  Future<void> stopCapture() async {
    if (_controller == null) {
      state = state.copyWith(capturing: false);
      return;
    }

    try {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
    } on CameraException catch (_) {
      // ignore if already stopped or disposed
    } catch (_) {}

    try {
      if (_controller!.value.isInitialized) {
        await _controller!.dispose();
      } else {
        await _controller!.dispose();
      }
    } catch (_) {}

    _controller = null;
    state = state.copyWith(capturing: false);
  }

  void reset() {
    state = PpgState(capturing: false, samples: [], mean: 0, variance: 0);
  }
}
