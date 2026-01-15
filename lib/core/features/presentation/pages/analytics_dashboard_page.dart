import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Pastikan sudah menjalankan: flutter pub add intl

import '../providers/history_provider.dart';
import '../../../theme/app_theme.dart';

class AnalyticsDashboardPage extends ConsumerWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    final latest = history.isNotEmpty ? history.last : null;
    
    // Hitung rata-rata
    final avgScore = history.isEmpty
        ? 0.0
        : history
                .map((e) => e['score'] as int)
                .reduce((a, b) => a + b) /
            history.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 🔹 AppBar
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                // Tombol Back Biru
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: AppTheme.primaryColor,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: const FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'Analytics Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: 'Rata-rata Skor',
                              value: avgScore.toStringAsFixed(1),
                              icon: Icons.trending_up,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD6C7F7), Color(0xFFC1B3F2)],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Status Terkini',
                              value: latest?['result'] ?? '-',
                              icon: Icons.shield,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9FE3AE), Color(0xFF7FD89B)],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 🔹 Trend Title
                      const Text(
                        'Trend Kesehatan Mental',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🔹 Chart (DIUBAH AGAR SESUAI TANGGAL/WAKTU)
                      Container(
                        height: 300,
                        padding: const EdgeInsets.fromLTRB(10, 24, 24, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: history.isEmpty
                            ? const Center(child: Text('Belum ada data'))
                            : LineChart(
                                _buildChartData(history),
                              ),
                      ),

                      const SizedBox(height: 24),

                      // 🔹 AI Insight
                      _AIInsightCard(latest?['result']),

                      const SizedBox(height: 24),

                      // 🔹 History List
                      const Text(
                        'Riwayat Screening',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...history.reversed.map(
                            (item) => _HistoryTile(
                              score: item['score'],
                              result: item['result'],
                              time: item['timestamp'],
                            ),
                          ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 KONFIGURASI GRAFIK DENGAN LABEL WAKTU
  LineChartData _buildChartData(List<Map<String, dynamic>> history) {
    final spots = List.generate(history.length, (index) {
      return FlSpot(
        index.toDouble(),
        (history[index]['score'] as int).toDouble(),
      );
    });

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.15),
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: 100, 
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < history.length) {
                String timestamp = history[index]['timestamp'] ?? '';
                String label = '';
                try {
                  // Mengambil jam:menit (HH:mm) untuk sumbu X
                  DateTime dt = DateTime.parse(timestamp);
                  label = DateFormat('HH:mm').format(dt);
                } catch (e) {
                  // Fallback jika format bukan ISO string
                  label = timestamp.length > 5 ? timestamp.substring(timestamp.length - 5) : timestamp;
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppTheme.primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppTheme.primaryColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withOpacity(0.3),
                AppTheme.primaryColor.withOpacity(0.01),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ================= UI COMPONENTS =================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _AIInsightCard extends StatelessWidget {
  final String? risk;

  const _AIInsightCard(this.risk);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '✨ AI Insight',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Kondisi relatif stabil, namun terdapat indikasi '
            'kelelahan ringan. Pertahankan pola tidur yang baik.',
            style: TextStyle(
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final int score;
  final String result;
  final String time;

  const _HistoryTile({
    required this.score,
    required this.result,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    Color getScoreColor(int s) {
      if (s < 10) return Colors.green;
      if (s < 20) return Colors.orange;
      return Colors.red;
    }

    // Memformat tampilan waktu riwayat
    String displayTime = time;
    try {
      DateTime dt = DateTime.parse(time);
      displayTime = DateFormat('EEEE, d MMM yyyy • HH:mm').format(dt);
    } catch (e) {
      displayTime = time;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: getScoreColor(score).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                score.toString(),
                style: TextStyle(
                  color: getScoreColor(score),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}