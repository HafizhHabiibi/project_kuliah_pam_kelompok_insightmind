class FeatureVector {
  /// Skor dari kuisioner
  final double screeningScore;

  /// Rata-rata magnitude accelerometer
  final double activityMean;

  /// Variansi accelerometer (indikator stres)
  final double activityVar;

  /// Rata-rata sinyal PPG-like
  final double ppgMean;

  /// Variansi sinyal PPG-like
  final double ppgVar;

  const FeatureVector({
    required this.screeningScore,
    required this.activityMean,
    required this.activityVar,
    required this.ppgMean,
    required this.ppgVar,
  });
}
