import 'package:tugas_dari_ppt/core/features/data/repositories/models/feature_vector.dart';

class PredictRiskAI {
  /// Menghitung risiko berdasarkan feature vector.
  Map<String, dynamic> predict(FeatureVector f) {
    // Weighted score
    final double weightedScore = 
        (f.screeningScore * 0.6) +
        (f.activityVar * 10 * 0.2) +
        (f.ppgVar * 1000 * 0.2);

    // Menentukan level risiko
    final String level;
    if (weightedScore > 25) {
      level = 'Tinggi';
    } else if (weightedScore > 12) {
      level = 'Sedang';
    } else {
      level = 'Rendah';
    }

    // Confidence sederhana dengan batas minimal & maksimal
    final double confidence =
        (weightedScore / 30).clamp(0.3, 0.95);

    return {
      'weightedScore': weightedScore,
      'riskLevel': level,
      'confidence': confidence,
    };
  }
}
