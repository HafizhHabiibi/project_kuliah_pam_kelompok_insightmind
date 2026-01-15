import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_dari_ppt/core/theme/app_theme.dart';
import 'package:tugas_dari_ppt/core/widgets/custom_widgets.dart';
import '../providers/history_provider.dart';
import 'screening_page.dart';
import 'biometric_page.dart';
import 'history_page.dart';
import 'analytics_dashboard_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final score = history.isNotEmpty ? history.last['score'] as int : 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar dengan Gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
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
                        const Text(
                          'Selamat Datang di',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.psychology,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'InsightMind',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Platform Screening Kesehatan Mental',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  );
                },
                icon: Badge(
                  isLabelVisible: history.isNotEmpty,
                  label: Text('${history.length}'),
                  child: const Icon(Icons.history),
                ),
                tooltip: 'Riwayat',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Card
                  _buildStatsCard(context, score, history.length),

                  const SizedBox(height: 32),

                  // 🔹 Analytics Dashboard Card
                  GlassCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnalyticsDashboardPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.analytics,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Analytics Dashboard',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ringkasan & tren kesehatan mental',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Mulai Screening',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  // Feature Cards
                  _buildScreeningCard(context),

                  const SizedBox(height: 16),

                  _buildBiometricCard(context),

                  const SizedBox(height: 32),

                  // Info Section
                  _buildInfoSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, int score, int historyCount) {
    return GradientCard(
      gradient: AppTheme.successGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Anda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Skor Terakhir',
                  score.toString(),
                  Icons.score,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withAlpha((0.3 * 255).round()),
              ),
              Expanded(
                child: _buildStatItem(
                  'Total Screening',
                  historyCount.toString(),
                  Icons.history,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withAlpha((0.8 * 255).round()), fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScreeningCard(BuildContext context) {
    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScreeningPage()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppTheme.primaryColor.withAlpha((0.3 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.quiz, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Screening Kuisioner',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '10-15 menit',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Jawab serangkaian pertanyaan untuk mendapatkan indikasi awal '
            'kesehatan mental Anda.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoBadge(
                text: 'Cepat',
                color: AppTheme.successColor,
                icon: Icons.speed,
              ),
              InfoBadge(
                text: 'Mudah',
                color: AppTheme.primaryColor,
                icon: Icons.thumb_up,
              ),
              InfoBadge(
                text: 'Tervalidasi',
                color: AppTheme.accentColor,
                icon: Icons.verified,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricCard(BuildContext context) {
    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BiometricPage()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.secondaryColor, AppTheme.accentColor],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppTheme.secondaryColor.withAlpha((0.3 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.sensors, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sensor & Biometrik AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '5-10 menit',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Gunakan sensor smartphone Anda (accelerometer & kamera) untuk '
            'analisis biometrik dan prediksi AI.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoBadge(
                text: 'AI Powered',
                color: AppTheme.secondaryColor,
                icon: Icons.auto_awesome,
              ),
              InfoBadge(
                text: 'Real-time',
                color: AppTheme.accentColor,
                icon: Icons.update,
              ),
              InfoBadge(
                text: 'Akurat',
                color: AppTheme.warningColor,
                icon: Icons.check_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.primaryColor.withAlpha((0.1 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Tentang InsightMind',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'InsightMind adalah platform edukatif untuk screening kesehatan mental. '
            'Aplikasi ini menggunakan kombinasi kuesioner tervalidasi dan teknologi AI '
            'untuk memberikan indikasi awal kondisi kesehatan mental Anda.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppTheme.warningColor.withAlpha((0.3 * 255).round())),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Disclaimer: Ini bukan alat diagnosis medis. '
                    'Konsultasikan dengan profesional untuk diagnosis yang tepat.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.warningColor,
                    ),
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