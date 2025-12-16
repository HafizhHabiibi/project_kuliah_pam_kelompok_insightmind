import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_dari_ppt/core/theme/app_theme.dart';
import 'package:tugas_dari_ppt/core/widgets/custom_widgets.dart';
import 'dart:math' as math;

import '../providers/score_provider.dart';
import '../providers/history_provider.dart';
import '../providers/questionnaire_provider.dart';

class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({super.key});

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimController;
  late AnimationController _fadeAnimController;
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scoreAnimController.forward();
    _fadeAnimController.forward();
  }

  @override
  void dispose() {
    _scoreAnimController.dispose();
    _fadeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riskLevel = ref.watch(resultProvider);
    final score = ref.watch(scoreProvider);

    // Konfigurasi berdasarkan tingkat risiko
    final config = _getRiskConfig(riskLevel, score);

    // Simpan otomatis ke history
    if (!_hasShownDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        await ref
            .read(historyProvider.notifier)
            .saveHistory(
              score: score,
              risk: riskLevel,
              recommendation: config.recommendation,
            );

        _hasShownDialog = true;
        _showRecommendationDialog(context, config);
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [config.color.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text(
                    'Hasil Screening',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimController,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Score Circle
                        _buildScoreCircle(score, config),

                        const SizedBox(height: 32),

                        // Risk Level Card
                        _buildRiskLevelCard(config),

                        const SizedBox(height: 24),

                        // Recommendation Card
                        _buildRecommendationCard(config),

                        const SizedBox(height: 24),

                        // Tips Card
                        _buildTipsCard(config),

                        const SizedBox(height: 32),

                        // Disclaimer
                        _buildDisclaimer(),

                        const SizedBox(height: 24),

                        // Action Buttons
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(int score, RiskConfig config) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score.toDouble()),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: config.color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _ScoreCirclePainter(
              progress: value / 30, // Assuming max score is 30
              color: config.color,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: config.color,
                    ),
                  ),
                  const Text(
                    'Skor Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiskLevelCard(RiskConfig config) {
    return GradientCard(
      gradient: LinearGradient(
        colors: [config.color, config.color.withOpacity(0.7)],
      ),
      child: Column(
        children: [
          Icon(config.icon, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Tingkat Risiko',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            config.level,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              config.statusText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(RiskConfig config) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: config.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Rekomendasi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            config.recommendation,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            config.extraAdvice,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(RiskConfig config) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tips_and_updates,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tips untuk Anda',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...config.tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: config.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.warningColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Disclaimer: InsightMind adalah alat skrining edukatif dan bukan '
              'pengganti diagnosis profesional. Untuk evaluasi lengkap, konsultasikan '
              'dengan psikolog atau psikiater.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.warningColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('Kembali ke Beranda'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Reset dan mulai screening baru
              ref.read(questionnaireProvider.notifier).reset();
              ref.read(answersProvider.notifier).state = [];
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Mulai Screening Baru'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showRecommendationDialog(BuildContext context, RiskConfig config) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(config.icon, color: config.color, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Hasil Screening Anda',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Tingkat Risiko: ${config.level}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: config.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              config.recommendation,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  RiskConfig _getRiskConfig(String riskLevel, int score) {
    switch (riskLevel) {
      case 'Tinggi':
        return RiskConfig(
          level: 'Tinggi',
          color: AppTheme.errorColor,
          icon: Icons.warning_rounded,
          statusText: 'Perlu Perhatian Khusus',
          recommendation:
              'Tingkat risiko Anda tinggi. Sangat disarankan untuk segera '
              'berbicara dengan konselor profesional atau psikolog untuk mendapatkan '
              'dukungan yang tepat.',
          extraAdvice:
              'Kurangi stres dengan istirahat yang cukup, hindari aktivitas berlebihan, '
              'dan pertimbangkan untuk berkonsultasi dengan ahli.',
          tips: [
            'Hubungi konselor atau psikolog profesional',
            'Jaga rutinitas tidur yang teratur (7-8 jam per malam)',
            'Lakukan aktivitas fisik ringan setiap hari',
            'Batasi konsumsi kafein dan alkohol',
            'Berbagi perasaan dengan orang terdekat',
          ],
        );
      case 'Sedang':
        return RiskConfig(
          level: 'Sedang',
          color: AppTheme.warningColor,
          icon: Icons.info_rounded,
          statusText: 'Perlu Diperhatikan',
          recommendation:
              'Tingkat risiko sedang. Jaga keseimbangan antara aktivitas dan istirahat. '
              'Pertimbangkan untuk melakukan self-care dan monitoring berkala.',
          extraAdvice:
              'Luangkan waktu untuk tidur cukup, lakukan relaksasi, dan jaga pola makan sehat. '
              'Pertimbangkan konseling jika gejala berlanjut.',
          tips: [
            'Terapkan teknik relaksasi seperti meditasi atau yoga',
            'Atur waktu istirahat yang cukup setiap hari',
            'Lakukan hobi yang Anda sukai',
            'Jaga komunikasi dengan teman dan keluarga',
            'Monitor perkembangan kondisi Anda',
          ],
        );
      default:
        return RiskConfig(
          level: 'Rendah',
          color: AppTheme.successColor,
          icon: Icons.check_circle_rounded,
          statusText: 'Kondisi Baik',
          recommendation:
              'Tingkat risiko rendah. Kondisi Anda baik! Pertahankan kebiasaan positif '
              'dan terus jaga kesehatan mental Anda.',
          extraAdvice:
              'Teruskan rutinitas sehat Anda, tetap terhubung dengan orang lain, '
              'dan lakukan aktivitas yang Anda nikmati.',
          tips: [
            'Pertahankan pola hidup sehat yang sudah baik',
            'Tetap aktif secara fisik dan sosial',
            'Lakukan aktivitas yang membuat bahagia',
            'Jaga keseimbangan work-life balance',
            'Lakukan screening berkala untuk monitoring',
          ],
        );
    }
  }
}

class RiskConfig {
  final String level;
  final Color color;
  final IconData icon;
  final String statusText;
  final String recommendation;
  final String extraAdvice;
  final List<String> tips;

  RiskConfig({
    required this.level,
    required this.color,
    required this.icon,
    required this.statusText,
    required this.recommendation,
    required this.extraAdvice,
    required this.tips,
  });
}

class _ScoreCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScoreCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius - 6, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
