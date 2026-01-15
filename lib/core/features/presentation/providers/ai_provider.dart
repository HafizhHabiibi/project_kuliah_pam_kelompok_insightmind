import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_dari_ppt/core/features/domain/usecases/predict_risk_ai.dart';
import 'package:tugas_dari_ppt/core/features/data/repositories/models/feature_vector.dart';

/// Provider untuk model AI prediksi risiko.
final aiPredictorProvider = Provider<PredictRiskAI>((ref) {
  return PredictRiskAI();
});

/// Provider untuk menghitung hasil prediksi berdasarkan FeatureVector.
final aiResultProvider =
    Provider.family<Map<String, dynamic>, FeatureVector>((ref, fv) {
  final model = ref.watch(aiPredictorProvider);
  return model.predict(fv);
});
