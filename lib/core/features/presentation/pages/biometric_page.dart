import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_dari_ppt/core/features/data/repositories/models/feature_vector.dart';
import 'package:tugas_dari_ppt/core/theme/app_theme.dart';
import 'package:tugas_dari_ppt/core/widgets/custom_widgets.dart';
import '../providers/sensors_provider.dart';
import '../providers/ppg_provider.dart';
import '../providers/score_provider.dart';
import 'ai_result_page.dart';

class BiometricPage extends ConsumerStatefulWidget {
  const BiometricPage({super.key});

  @override
  ConsumerState<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends ConsumerState<BiometricPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Fungsi aman untuk memulai kamera dengan penanganan error
  Future<void> _handleStartCapture() async {
    try {
      await ref.read(ppgProvider.notifier).startCapture();
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Gagal membuka kamera.';
      String errorDetail = e.toString();

      // Deteksi penyebab error agar pesan lebih jelas
      if (errorDetail.contains('cameraNotReadable') ||
          errorDetail.contains('CameraException')) {
        errorMessage =
            'Hardware kamera tidak terbaca atau sedang digunakan aplikasi lain (Zoom/Meet).';
      } else if (errorDetail.contains('Permission denied') ||
          errorDetail.contains('permission')) {
        errorMessage =
            'Izin kamera ditolak oleh browser. Cek ikon gembok/kamera di address bar.';
      } else if (errorDetail.contains('NotAllowedError')) {
        errorMessage =
            'Akses ditolak. Pastikan website menggunakan HTTPS atau localhost.';
      }

      _showErrorDialog(errorMessage);
    }
  }

  /// Dialog Error yang SUDAH DIPERBAIKI (Anti Overflow)
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            // [FIX] Menggunakan Expanded agar teks judul wrap ke bawah jika kepanjangan
            Expanded(
              child: Text(
                'Akses Kamera Bermasalah',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // [FIX] Text content akan otomatis wrap, tapi title di dalam Row butuh Expanded
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accelFeat = ref.watch(accelFeatureProvider);
    final ppg = ref.watch(ppgProvider);
    final score = ref.watch(scoreProvider);

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
              // App Bar
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.secondaryColor, AppTheme.accentColor],
                      ),
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
                                    color: Colors.white.withAlpha((0.2 * 255).round()),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.sensors,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sensor & Biometrik',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'AI-Powered Analysis',
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

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Screening Score Card
                      _buildScoreCard(score),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Data Sensor',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (ppg.samples.isNotEmpty || accelFeat.mean != 0)
                            TextButton.icon(
                              onPressed: () {
                                ref.read(ppgProvider.notifier).reset();
                                ref.read(accelFeatureProvider.notifier).reset();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Data sensor telah direset'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Reset Data'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.errorColor,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Accelerometer Card
                      _buildAccelerometerCard(accelFeat),

                      const SizedBox(height: 16),

                      // PPG Camera Card
                      _buildPPGCard(ppg),

                      const SizedBox(height: 32),

                      // Instructions
                      _buildInstructions(ppg),

                      const SizedBox(height: 24),

                      // Predict Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Hitung Prediksi AI',
                          icon: Icons.auto_awesome,
                          isLoading: _isProcessing,
                          onPressed: ppg.samples.length >= 30
                              ? () => _processPrediction(score, accelFeat, ppg)
                              : null,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (ppg.samples.length < 30)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.warningColor.withAlpha((0.3 * 255).round()),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.warningColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Kumpulkan minimal 30 sampel PPG (${ppg.samples.length}/30)',
                                  style: const TextStyle(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(int score) {
    return GradientCard(
      gradient: AppTheme.primaryGradient,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.quiz, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skor Screening',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Dari Kuisioner',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            score.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccelerometerCard(AccelFeature accelFeat) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.speed,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accelerometer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Motion Sensor',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const InfoBadge(
                text: 'Aktif',
                color: AppTheme.successColor,
                icon: Icons.check_circle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Mean',
                  accelFeat.mean.toStringAsFixed(4),
                  Icons.show_chart,
                  AppTheme.accentColor,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade300),
              Expanded(
                child: _buildMetricItem(
                  'Variance',
                  accelFeat.variance.toStringAsFixed(4),
                  Icons.analytics,
                  AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPPGCard(PpgState ppg) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppTheme.errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PPG via Kamera',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Photoplethysmography',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              InfoBadge(
                text: ppg.capturing ? 'Aktif' : 'Siap',
                color: ppg.capturing
                    ? AppTheme.successColor
                    : AppTheme.textSecondary,
                icon: ppg.capturing ? Icons.videocam : Icons.videocam_off,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Mean Y',
                  ppg.mean.toStringAsFixed(2),
                  Icons.show_chart,
                  AppTheme.errorColor,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade300),
              Expanded(
                child: _buildMetricItem(
                  'Variance',
                  ppg.variance.toStringAsFixed(2),
                  Icons.analytics,
                  AppTheme.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sampel Terkumpul',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${ppg.samples.length} / 300',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ppg.samples.length / 300,
                  backgroundColor: Colors.grey.shade200,
                  color: AppTheme.primaryColor,
                  minHeight: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Capture button
          SizedBox(
            width: double.infinity,
            child: ppg.capturing
                ? FilledButton.icon(
                    onPressed: () {
                      ref.read(ppgProvider.notifier).stopCapture();
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Capture'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                    ),
                  )
                : FilledButton.icon(
                    // [MODIFIKASI] Panggil fungsi yang aman
                    onPressed: _handleStartCapture,
                    icon: ppg.capturing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1 + (_pulseController.value * 0.2),
                                child: const Icon(Icons.play_arrow),
                              );
                            },
                          ),
                    label: const Text('Start Capture'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildInstructions(PpgState ppg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withAlpha((0.1 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Cara Penggunaan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            '1',
            'Tekan tombol "Start Capture" pada kartu PPG',
          ),
          _buildInstructionItem('2', 'Tutup kamera belakang dengan jari Anda'),
          _buildInstructionItem(
            '3',
            'Tahan stabil hingga terkumpul minimal 30 sampel',
          ),
          _buildInstructionItem('4', 'Tekan "Hitung Prediksi AI" untuk hasil'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPrediction(
    int score,
    AccelFeature accelFeat,
    PpgState ppg,
  ) async {
    setState(() => _isProcessing = true);

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    final fv = FeatureVector(
      screeningScore: score.toDouble(),
      activityMean: accelFeat.mean,
      activityVar: accelFeat.variance,
      ppgMean: ppg.mean,
      ppgVar: ppg.variance,
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AIResultPage(fv: fv)),
      );
    }
  }
}
