// lib/features/insightmind/presentation/pages/screening_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/qusetion.dart';
import '../providers/questionnaire_provider.dart';
import '../providers/score_provider.dart';
import 'result_page.dart';

class ScreeningPage extends ConsumerWidget {
  const ScreeningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);

    final answered = qState.answers.length;
    final total = questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening InsightMind'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // 🔹 Tambahkan tombol Reset di AppBar
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset semua jawaban',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Reset Jawaban'),
                  content: const Text(
                    'Apakah Anda yakin ingin menghapus semua jawaban?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () {
                        ref.read(questionnaireProvider.notifier).reset();
                        ref.read(answersProvider.notifier).state = [];
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Jawaban telah direset.'),
                          ),
                        );
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔹 Progres pertanyaan
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Progress: $answered / $total pertanyaan',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: total > 0 ? answered / total : 0,
                  color: Colors.indigo,
                  backgroundColor: Colors.grey[300],
                  minHeight: 8,
                ),
              ],
            ),
          ),
          const Divider(),

          // 🔹 Daftar pertanyaan
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final q = questions[index];
                final selected = qState.answers[q.id];
                return _QuestionTile(
                  question: q,
                  selectedScore: selected,
                  onSelected: (score) {
                    ref
                        .read(questionnaireProvider.notifier)
                        .selectAnswer(questionId: q.id, score: score);
                  },
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Tombol lihat hasil dengan validasi
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigo,
                ),
                onPressed: () {
                  if (!qState.isComplete) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Lengkapi semua pertanyaan terlebih dahulu.',
                        ),
                      ),
                    );
                    return;
                  }

                  // 🔹 Pop-up ringkasan jawaban sebelum hasil
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text('Ringkasan Jawaban'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final q in questions)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    '${q.text}\n→ ${q.options.firstWhere((opt) => opt.score == qState.answers[q.id]!).label}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Kembali'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);

                              // Simpan jawaban ke provider
                              final orderedAnswers = <int>[];
                              for (final q in questions) {
                                orderedAnswers.add(qState.answers[q.id]!);
                              }
                              ref.read(answersProvider.notifier).state =
                                  orderedAnswers;

                              // Navigasi ke hasil
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ResultPage(),
                                ),
                              );
                            },
                            child: const Text('Lanjut ke Hasil'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Lihat Hasil'),
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 Tombol reset tambahan di bawah
            OutlinedButton.icon(
              onPressed: () {
                ref.read(questionnaireProvider.notifier).reset();
                ref.read(answersProvider.notifier).state = [];
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Jawaban telah dihapus.')),
                );
              },
              icon: const Icon(Icons.refresh, color: Colors.indigo),
              label: const Text('Reset Jawaban'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final Question question;
  final int? selectedScore;
  final ValueChanged<int> onSelected;

  const _QuestionTile({
    required this.question,
    required this.selectedScore,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final answered = selectedScore != null;

    return Card(
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.text, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final opt in question.options)
              RadioListTile<int>(
                title: Text(opt.label),
                value: opt.score,
                groupValue: selectedScore,
                activeColor: Colors.indigo,
                onChanged: (val) => onSelected(val!),
              ),
            if (answered)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 6),
                    Text('Sudah dijawab', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
