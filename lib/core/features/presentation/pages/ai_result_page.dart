import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_dari_ppt/core/features/data/repositories/models/feature_vector.dart';
import '../providers/ai_provider.dart';

class AIResultPage extends ConsumerWidget {
  final FeatureVector fv;

  const AIResultPage({
    super.key,
    required this.fv,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(aiResultProvider(fv));
    final level = result['riskLevel'];
    final weighted = result['weightedScore'];
    final conf = result['confidence'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Risk Prediction"),
        elevation: 2,
      ),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          shadowColor: Colors.indigo.withOpacity(0.3),
          elevation: 6,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insights,
                  size: 80,
                  color: Colors.indigo.shade600,
                ),
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

                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Kembali"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
