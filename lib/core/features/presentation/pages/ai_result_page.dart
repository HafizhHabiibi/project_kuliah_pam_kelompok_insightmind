import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_dari_ppt/core/features/data/repositories/models/feature_vector.dart';
import '../providers/ai_provider.dart';
import '../providers/ppg_provider.dart';
import '../providers/sensors_provider.dart';

class AIResultPage extends ConsumerWidget {
  final FeatureVector fv;

  const AIResultPage({super.key, required this.fv});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(aiResultProvider(fv));
    final level = result['riskLevel'] ?? 'Unknown';
    final weighted = (result['weightedScore'] as num?)?.toDouble() ?? 0.0;
    final conf = (result['confidence'] as num?)?.toDouble() ?? 0.0;
    final details = result['details'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: const Text("AI Risk Prediction"), elevation: 2),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          shadowColor: Colors.indigo.withAlpha((0.3 * 255).round()),
          elevation: 6,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insights, size: 80, color: Colors.indigo.shade600),
                const SizedBox(height: 20),

                // Teks Tingkat Risiko
                Text(
                  "Tingkat Risiko: $level",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: level == "Tinggi"
                        ? Colors.red
                        : level == "Sedang"
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),

                const SizedBox(height: 14),
                Text("Skor AI: ${weighted.toStringAsFixed(2)}"),
                Text("Confidence: ${(conf * 100).toStringAsFixed(1)}%"),

                const SizedBox(height: 20),

                // Detailed Breakdown
                if (details != null) ...[
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Faktor Kontribusi:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow("Kuisioner", details['screening']),
                  _buildDetailRow("Aktivitas (Accel)", details['activity']),
                  _buildDetailRow("Biometrik (PPG)", details['biometric']),
                ],

                const SizedBox(height: 30),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(ppgProvider.notifier).reset();
                        ref.read(accelFeatureProvider.notifier).reset();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reset & Coba Lagi"),
                    ),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Kembali"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    final val = (value as num?)?.toDouble() ?? 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(
                "${(val * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: val,
              backgroundColor: Colors.grey.shade200,
              minHeight: 6,
              color: val > 0.7 ? Colors.red : (val > 0.4 ? Colors.orange : Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
