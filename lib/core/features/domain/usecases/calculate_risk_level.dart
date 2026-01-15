import '../entities/mental_result.dart';

class CalculateRiskLevel {
  MentalResult execute(int score) {
    String risk;
    if (score >= 20) {
      risk = 'Tinggi';
    } else if (score >= 10) {
      risk = 'Sedang';
    } else {
      risk = 'Rendah';
    }
    return MentalResult(score: score, riskLevel: risk);
  }
}
