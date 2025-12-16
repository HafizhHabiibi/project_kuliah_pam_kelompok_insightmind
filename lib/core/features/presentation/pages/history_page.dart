import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_dari_ppt/core/theme/app_theme.dart';
import 'package:tugas_dari_ppt/core/widgets/custom_widgets.dart';
import 'package:intl/intl.dart';

import '../providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.history,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Riwayat Screening',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Pantau perkembangan Anda',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Statistics Card
            if (history.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildStatisticsCard(history),
                ),
              ),

            // History List
            if (history.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  title: 'Belum Ada Riwayat',
                  description:
                      'Mulai screening untuk melihat riwayat hasil Anda di sini',
                  icon: Icons.history_rounded,
                  onAction: () => Navigator.pop(context),
                  actionText: 'Mulai Screening',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = history[history.length - 1 - index];
                    return _buildHistoryCard(
                      context,
                      ref,
                      item,
                      history.length - 1 - index,
                    );
                  }, childCount: history.length),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: history.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showDeleteAllDialog(context, ref),
              backgroundColor: AppTheme.errorColor,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Hapus Semua'),
            )
          : null,
    );
  }

  Widget _buildStatisticsCard(List<Map<String, dynamic>> history) {
    // Calculate statistics
    final scores = history.map((h) => (h['score'] as num).toInt()).toList();
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;

    final riskCounts = <String, int>{};
    for (final item in history) {
      final risk = item['result']?.toString() ?? 'Unknown';
      riskCounts[risk] = (riskCounts[risk] ?? 0) + 1;
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.primaryColor),
              SizedBox(width: 12),
              Text(
                'Statistik',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Screening',
                  history.length.toString(),
                  Icons.quiz,
                  AppTheme.primaryColor,
                ),
              ),
              Container(width: 1, height: 60, color: Colors.grey.shade300),
              Expanded(
                child: _buildStatItem(
                  'Rata-rata Skor',
                  avgScore.toStringAsFixed(1),
                  Icons.trending_up,
                  AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Distribusi Risiko',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...riskCounts.entries.map((entry) {
            final percentage = (entry.value / history.length * 100).toInt();
            final color = _getRiskColor(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '${entry.value}x ($percentage%)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item,
    int index,
  ) {
    final result = item['result']?.toString() ?? 'Unknown';
    final score = item['score'] as int? ?? 0;
    final tsString = item['timestamp']?.toString();

    DateTime? ts;
    if (tsString != null) {
      ts = DateTime.tryParse(tsString);
    }

    final formattedDate = ts != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(ts)
        : '-';

    final color = _getRiskColor(result);
    final icon = _getRiskIcon(result);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        onTap: () => _showDetailDialog(context, item, formattedDate),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Skor: $score',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      _showDetailDialog(context, item, formattedDate),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Detail'),
                ),
                IconButton(
                  onPressed: () => _showDeleteDialog(context, ref, index),
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.errorColor,
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic> item,
    String formattedDate,
  ) {
    final result = item['result']?.toString() ?? 'Unknown';
    final score = item['score']?.toString() ?? '-';
    final recommendation = item['recommendation']?.toString() ?? '-';
    final color = _getRiskColor(result);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getRiskIcon(result), color: color),
            ),
            const SizedBox(width: 12),
            const Text('Detail Screening'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Tanggal', formattedDate, Icons.calendar_today),
              const SizedBox(height: 12),
              _buildDetailRow('Tingkat Risiko', result, Icons.assessment),
              const SizedBox(height: 12),
              _buildDetailRow('Skor', score, Icons.score),
              const Divider(height: 24),
              const Text(
                'Rekomendasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                recommendation,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: AppTheme.errorColor),
            SizedBox(width: 12),
            Text('Hapus Riwayat'),
          ],
        ),
        content: const Text('Hapus riwayat screening ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(historyProvider.notifier).removeAt(index);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Riwayat berhasil dihapus'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
            SizedBox(width: 12),
            Text('Hapus Semua Riwayat'),
          ],
        ),
        content: const Text(
          'Anda yakin ingin menghapus semua riwayat screening? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(historyProvider.notifier).clear();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua riwayat berhasil dihapus'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'Tinggi':
        return AppTheme.errorColor;
      case 'Sedang':
        return AppTheme.warningColor;
      case 'Rendah':
        return AppTheme.successColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getRiskIcon(String risk) {
    switch (risk) {
      case 'Tinggi':
        return Icons.warning_rounded;
      case 'Sedang':
        return Icons.info_rounded;
      case 'Rendah':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline;
    }
  }
}
