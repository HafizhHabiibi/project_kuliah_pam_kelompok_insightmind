// lib/core/features/presentation/pages/result_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/score_provider.dart';

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskLevel = ref.watch(resultProvider); // hasil berupa String
    final score = ref.watch(scoreProvider); // skor numerik

    String recommendation;
    String extraAdvice = '';

    switch (riskLevel) {
      case 'Tinggi':
        recommendation =
            'Tingkat risiko Anda tinggi. Pertimbangkan berbicara dengan konselor atau psikolog.';
        extraAdvice = 'Kurangi stres dan perbanyak waktu istirahat.';
        break;
      case 'Sedang':
        recommendation =
            'Tingkat risiko sedang. Jaga keseimbangan antara aktivitas dan istirahat.';
        extraAdvice = 'Luangkan waktu untuk tidur cukup dan lakukan relaksasi.';
        break;
      default:
        recommendation =
            'Tingkat risiko rendah. Kondisi Anda baik, pertahankan kebiasaan positif.';
        extraAdvice =
            'Teruskan rutinitas sehat dan tetap terhubung dengan orang lain.';
    }

    // 🔹 Pop-up rekomendasi otomatis
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Rekomendasi Untuk Anda'),
          content: Text('$recommendation\n\n$extraAdvice'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Screening'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Skor Anda: $score',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tingkat Risiko: $riskLevel',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: Colors.indigo),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$recommendation\n\n$extraAdvice',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Spacer(),
            const Text(
              'Disclaimer: InsightMind bersifat edukatif, bukan alat diagnosis medis.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
