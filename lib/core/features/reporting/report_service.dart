import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Service untuk membuat dan membagikan/print laporan PDF
class ReportService {
  /// Menghasilkan PDF berbentuk bytes yang dapat disimpan/dibagikan
  Future<Uint8List> generateScreeningReport({
    required int score,
    required String riskLevel,
    required String recommendation,
    required List<Map<String, dynamic>> history,
    String title = 'Laporan Screening Kesehatan Mental',
  }) async {
    final pdf = pw.Document();

    final date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Tanggal: $date', style: const pw.TextStyle(fontSize: 10)),
                pw.Divider(),
              ],
            ),
          ),

          // Section: Hasil Screening
          pw.Header(level: 1, text: 'Hasil Screening'),
          pw.Bullet(text: 'Skor: $score'),
          pw.Bullet(text: 'Tingkat Risiko: $riskLevel'),
          pw.SizedBox(height: 6),
          pw.Text('Rekomendasi:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(recommendation),

          pw.SizedBox(height: 18),

          // Section: Rekap History
          pw.Header(level: 1, text: 'Rekap History Screening'),
          if (history.isEmpty)
            pw.Text('Belum ada riwayat screening lain.')
          else
            _buildHistoryTable(history),

          pw.SizedBox(height: 18),

          // Footer / Catatan
          pw.Divider(),
          pw.Text('Catatan: Dokumen ini dibuat otomatis dari aplikasi. Bukan pengganti diagnosis profesional.'),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generate a report that is purely a history/rekap of screenings
  Future<Uint8List> generateHistoryReport({
    required List<Map<String, dynamic>> history,
    String title = 'Rekap Perkembangan Kondisi Mental',
  }) async {
    final pdf = pw.Document();
    final date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Tanggal: $date', style: const pw.TextStyle(fontSize: 10)),
                pw.Divider(),
              ],
            ),
          ),
          if (history.isEmpty) pw.Text('Belum ada data riwayat.') else _buildHistoryTable(history),
          pw.SizedBox(height: 18),
          pw.Divider(),
          pw.Text('Catatan: Dokumen ini dibuat otomatis dari aplikasi.'),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHistoryTable(List<Map<String, dynamic>> history) {
    final rows = history.map((e) {
      final ts = e['timestamp'] ?? '';
      final score = e['score']?.toString() ?? '-';
      final result = e['result'] ?? '-';
      final rec = e['recommendation'] ?? '-';
      return [ts, score, result, rec];
    }).toList();

    final headers = ['Tanggal', 'Skor', 'Hasil', 'Rekomendasi'];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: headers
              .map((h) => pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))))
              .toList(),
        ),
        // Data rows
        ...rows.map((r) => pw.TableRow(
              children: r.map((cell) => pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(cell.toString()))).toList(),
            ))
      ],
    );
  }

  /// Langsung membuka dialog share/print bawaan device untuk PDF tersebut
  Future<void> sharePdf(Uint8List pdfBytes, {String filename = 'laporan.pdf'}) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }

  /// Menampilkan preview print (bisa di-print dari dialog)
  Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
}
