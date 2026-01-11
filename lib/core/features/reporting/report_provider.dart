import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'report_service.dart';

final reportServiceProvider = Provider<ReportService>((ref) => ReportService());

/// Helper provider untuk membuat laporan dari data yang ada
final reportGeneratorProvider = Provider((ref) => _ReportGenerator(ref));

class _ReportGenerator {
  final Ref _ref;
  _ReportGenerator(this._ref);

  Future<Uint8List> generateFrom({
    required int score,
    required String riskLevel,
    required String recommendation,
    required List<Map<String, dynamic>> history,
  }) async {
    final svc = _ref.read(reportServiceProvider);
    return svc.generateScreeningReport(
      score: score,
      riskLevel: riskLevel,
      recommendation: recommendation,
      history: history,
    );
  }
}
