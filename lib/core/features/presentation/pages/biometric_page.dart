import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_dari_ppt/core/features/data/repositories/models/feature_vector.dart';

import '../providers/sensors_provider.dart';
import '../providers/ppg_provider.dart';
import '../providers/score_provider.dart';
import 'ai_result_page.dart';

class BiometricPage extends ConsumerWidget {
  const BiometricPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accelFeat = ref.watch(accelFeatureProvider);
    final ppg = ref.watch(ppgProvider);
    final score = ref.watch(scoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Sensor & Biometrik InsightMind")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // === ACCELEROMETER CARD ===
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fitur Accelerometer",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Mean: ${accelFeat.mean.toStringAsFixed(4)}"),
                  Text("Variance: ${accelFeat.variance.toStringAsFixed(4)}"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // === CAMERA PPG CARD ===
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fitur PPG via Kamera",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Mean Y: ${ppg.mean.toStringAsFixed(6)}"),
                  Text("Variance Y: ${ppg.variance.toStringAsFixed(6)}"),
                  Text("Samples: ${ppg.samples.length}"),
                  const SizedBox(height: 12),

                  // Tombol Start / Stop Capture
                  FilledButton.icon(
                    onPressed: () {
                      final notifier = ref.read(ppgProvider.notifier);
                      ppg.capturing
                          ? notifier.stopCapture()
                          : notifier.startCapture();
                    },
                    icon: Icon(
                      ppg.capturing ? Icons.stop : Icons.play_arrow,
                    ),
                    label: Text(
                      ppg.capturing ? "Stop Capture" : "Start Capture",
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // === PREDIKSI AI BUTTON ===
          FilledButton.icon(
            icon: const Icon(Icons.insights),
            label: const Text("Hitung Prediksi AI"),
            onPressed: () {
              if (ppg.samples.length < 30) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Ambil minimal 30 sampel PPG dahulu"),
                  ),
                );
                return;
              }

              final fv = FeatureVector(
                screeningScore: score.toDouble(),
                activityMean: accelFeat.mean,
                activityVar: accelFeat.variance,
                ppgMean: ppg.mean,
                ppgVar: ppg.variance,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AIResultPage(fv: fv),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}