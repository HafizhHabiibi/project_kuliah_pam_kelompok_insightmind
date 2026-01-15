import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_dari_ppt/core/theme/app_theme.dart';
import 'package:tugas_dari_ppt/core/widgets/custom_widgets.dart';
import 'dart:math' as math;

import '../providers/score_provider.dart';
import '../providers/history_provider.dart';
import '../providers/questionnaire_provider.dart';
import '../../reporting/report_provider.dart';

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

    final config = _getRiskConfig(riskLevel);

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

        if (!mounted) return;
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
            colors: [config.color.withAlpha((0.1 * 255).round()), Colors.white],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: const FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'Hasil Screening',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimController,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildScoreCircle(score, config),
                        const SizedBox(height: 32),
                        _buildRiskLevelCard(config),
                        const SizedBox(height: 24),
                        _buildRecommendationCard(config),
                        const SizedBox(height: 24),
                        _buildTipsCard(config),
                        const SizedBox(height: 32),
                        _buildDisclaimer(),
                        const SizedBox(height: 24),
                        _buildActionButtons(context, score, riskLevel, config),
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
      builder: (_, value, __) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: config.color.withAlpha((0.3 * 255).round()),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _ScoreCirclePainter(
              progress: value / 30,
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
                  const Text('Skor Anda'),
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
        colors: [config.color, config.color.withAlpha((0.7 * 255).round())],
      ),
      child: Column(
        children: [
          Icon(config.icon, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          const Text('Tingkat Risiko', style: TextStyle(color: Colors.white70)),
          Text(
            config.level,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(RiskConfig config) {
    return GlassCard(
      child: Text(config.recommendation, style: const TextStyle(fontSize: 15)),
    );
  }

  Widget _buildTipsCard(RiskConfig config) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: config.tips
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $e'),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return const Text(
      'Disclaimer: Ini hanya alat skrining, bukan diagnosis medis.',
      style: TextStyle(fontSize: 12),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButtons(BuildContext context, int score, String riskLevel, RiskConfig config) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final scaffold = ScaffoldMessenger.of(context);
                scaffold.showSnackBar(const SnackBar(content: Text('Membuat laporan...')));
                try {
                  final history = ref.read(historyProvider);
                  final bytes = await ref
                      .read(reportGeneratorProvider)
                      .generateFrom(
                        score: score,
                        riskLevel: riskLevel,
                        recommendation: config.recommendation,
                        history: history,
                      );

                  await ref.read(reportServiceProvider).sharePdf(
                        bytes,
                        filename: 'laporan_${DateTime.now().toIso8601String()}.pdf',
                      );

                  if (context.mounted) scaffold.showSnackBar(const SnackBar(content: Text('Laporan berhasil dibagikan/disimpan.')));
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat laporan: $e')));
                }
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Ekspor Laporan (PDF)'),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () {
                ref.read(questionnaireProvider.notifier).reset();
                ref.read(answersProvider.notifier).state = [];
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Mulai Ulang'),
            ),
          ],
        ),
      ],
    );
  }

  void _showRecommendationDialog(BuildContext context, RiskConfig config) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(config.level),
        content: Text(config.recommendation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// ✅ FIX UTAMA ADA DI SINI
  RiskConfig _getRiskConfig(String riskLevel) {
    switch (riskLevel) {
      case 'Risiko Tinggi':
        return RiskConfig(
          level: 'Tinggi',
          color: AppTheme.errorColor,
          icon: Icons.warning_rounded,
          recommendation: 'Risiko tinggi, segera konsultasi profesional.',
          tips: ['Hubungi psikolog', 'Kurangi stres', 'Istirahat cukup'],
        );
      case 'Risiko Sedang':
        return RiskConfig(
          level: 'Sedang',
          color: AppTheme.warningColor,
          icon: Icons.info_rounded,
          recommendation: 'Risiko sedang, jaga pola hidup sehat.',
          tips: ['Kelola stres', 'Tidur cukup', 'Relaksasi'],
        );
      default:
        return RiskConfig(
          level: 'Rendah',
          color: AppTheme.successColor,
          icon: Icons.check_circle,
          recommendation: 'Risiko rendah, pertahankan kebiasaan baik.',
          tips: ['Olahraga rutin', 'Pola makan sehat', 'Jaga mood'],
        );
    }
  }
}

class RiskConfig {
  final String level;
  final Color color;
  final IconData icon;
  final String recommendation;
  final List<String> tips;

  RiskConfig({
    required this.level,
    required this.color,
    required this.icon,
    required this.recommendation,
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

    final bgPaint = Paint()
      ..color = color.withAlpha((0.1 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 6, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
