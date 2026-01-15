import 'package:tugas_dari_ppt/core/features/data/repositories/models/feature_vector.dart';

class PredictRiskAI {
  /// Menghitung risiko berdasarkan feature vector.
  Map<String, dynamic> predict(FeatureVector f) {
    // 1. Normalisasi Skor Screening (0-40 -> 0-1)
    final double normalizedScreening = (f.screeningScore / 40).clamp(0.0, 1.0);

    // 2. Normalisasi Aktivitas (Accel Variance)
    // Variansi accel biasanya rendah (0-2 m/s^2), kita kuadratkan atau skala agar lebih signifikan
    final double normalizedActivity = (f.activityVar * 5).clamp(0.0, 1.0);

    // 3. Normalisasi PPG Variance (0-200 -> 0-1)
    // Variansi PPG menunjukkan stabilitas sinyal / detak jantung.
    final double normalizedPPG = (f.ppgVar / 200).clamp(0.0, 1.0);

    // Weighted score (Total 0-100)
    // Kita kurangi ketergantungan pada screening score saja.
    final double weightedScore =
        (normalizedScreening * 40) + // Max 40
        (normalizedActivity * 30) + // Max 30
        (normalizedPPG * 30); // Max 30

    // Menentukan level risiko yang lebih variatif
    final String level;
    if (weightedScore > 65) {
      level = 'Tinggi';
    } else if (weightedScore > 35) {
      level = 'Sedang';
    } else {
      level = 'Rendah';
    }

    // Confidence berdasarkan kestabilan data (PPG & Accel)
    // Semakin rendah variansi (tapi tidak nol), semakin stabil/terpercaya datanya.
    final double stability =
        1.0 - ((f.activityVar + (f.ppgVar / 1000)) / 2).clamp(0.0, 0.7);
    final double confidence = (0.5 + (stability * 0.45)).clamp(0.5, 0.95);

    return {
      'weightedScore': weightedScore,
      'riskLevel': level,
      'confidence': confidence,
      'details': {
        'screening': normalizedScreening,
        'activity': normalizedActivity,
        'biometric': normalizedPPG,
      },
    };
  }
}
