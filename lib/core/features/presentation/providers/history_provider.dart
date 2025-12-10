import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  HistoryNotifier() : super([]) {
    _loadHistory();
  }

  final String _boxName = 'historyBox';

  /// 🔹 Load history from Hive saat aplikasi dibuka
  Future<void> _loadHistory() async {
    final box = await Hive.openBox(_boxName);
    final data = box.get('history', defaultValue: []);
    state = (data as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  /// 🔹 Menambah data screening ke history
  Future<void> saveHistory({
    required int score,
    required String risk,
    required String recommendation,
  }) async {
    final newEntry = {
      'score': score,
      'result': risk,
      'recommendation': recommendation,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final updated = [...state, newEntry];
    state = updated;

    final box = await Hive.openBox(_boxName);
    await box.put('history', updated);
  }

  /// 🔹 Menghapus seluruh history
  Future<void> clear() async {
    state = [];

    final box = await Hive.openBox(_boxName);
    await box.put('history', []);
  }

  /// 🔹 Menghapus 1 item berdasarkan index
  Future<void> removeAt(int index) async {
    final updated = [...state]..removeAt(index);
    state = updated;

    final box = await Hive.openBox(_boxName);
    await box.put('history', updated);
  }
}

/// 🔹 Provider untuk diakses di UI
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<Map<String, dynamic>>>(
      (ref) => HistoryNotifier(),
    );
