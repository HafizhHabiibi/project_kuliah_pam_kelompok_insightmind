import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/score_repository.dart';

final answersProvider = StateProvider<List<int>>((ref) => []);
final scoreRepositoryProvider = Provider((ref) => ScoreRepository());

final scoreProvider = Provider<int>((ref) {
  final repo = ref.watch(scoreRepositoryProvider);
  final answers = ref.watch(answersProvider);
  return repo.calculateScore(answers);
});

final resultProvider = Provider<String>((ref) {
  final score = ref.watch(scoreProvider);

  if (score < 5) return 'Risiko Rendah';
  if (score < 12) return 'Risiko Sedang';
  return 'Risiko Tinggi';
});
