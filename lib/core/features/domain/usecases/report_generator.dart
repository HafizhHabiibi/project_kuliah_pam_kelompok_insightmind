import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

class ReportGenerator {
  Future<Uint8List> generateReport({
    required String username,
    required List<Map<String, dynamic>> history,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'InsightMind Mental Health Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Nama Pengguna: $username'),
          pw.SizedBox(height: 16),

          // ignore: deprecated_member_use
          pw.Table.fromTextArray(
            headers: ['Tanggal', 'Skor', 'Risiko'],
            data: history
                .map(
                  (h) => [h['tanggal'], h['score'].toString(), h['riskLevel']],
                )
                .toList(),
          ),

          pw.SizedBox(height: 16),
          pw.Text(
            'Catatan: Laporan ini bersifat edukatif dan bukan diagnosis medis.',
            style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
