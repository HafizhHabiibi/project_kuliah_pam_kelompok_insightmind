import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_dari_ppt/core/theme/app_theme.dart';
import 'package:tugas_dari_ppt/core/widgets/custom_widgets.dart';
import '../../domain/entities/qusetion.dart';
import '../providers/questionnaire_provider.dart';
import '../providers/score_provider.dart';
import 'result_page.dart';

class ScreeningPage extends ConsumerStatefulWidget {
  const ScreeningPage({super.key});

  @override
  ConsumerState<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends ConsumerState<ScreeningPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < defaultQuestions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);

    final answered = qState.answers.length;
    final total = questions.length;
    final progress = total > 0 ? answered / total : 0.0;

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
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(context, progress, answered, total),

              // Page View dengan Pertanyaan
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    _animController.forward(from: 0);
                  },
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final selected = qState.answers[question.id];

                    return FadeTransition(
                      opacity: _animController,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animController,
                                curve: Curves.easeOut,
                              ),
                            ),
                        child: _buildQuestionCard(
                          context,
                          question,
                          selected,
                          index + 1,
                          total,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Navigation Buttons
              _buildNavigationButtons(context, qState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    double progress,
    int answered,
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                color: AppTheme.primaryColor,
              ),
              const Expanded(
                child: Text(
                  'Screening Kuisioner',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () => _showResetDialog(context),
                icon: const Icon(Icons.refresh),
                color: AppTheme.errorColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '$answered / $total',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        tween: Tween(begin: 0, end: progress),
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.grey.shade200,
                            color: AppTheme.primaryColor,
                            minHeight: 10,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    Question question,
    int? selected,
    int number,
    int total,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Number Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Pertanyaan $number dari $total',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Question Card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Options
                ...question.options.map((option) {
                  final isSelected = selected == option.score;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(questionnaireProvider.notifier)
                            .selectAnswer(
                              questionId: question.id,
                              score: option.score,
                            );
                        // Auto next setelah 300ms
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (_currentPage < total - 1) {
                            _nextPage();
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withAlpha((0.3 * 255).round()),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: AppTheme.primaryColor,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option.label,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                if (selected != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Pertanyaan terjawab',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    QuestionnaireState qState,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Opacity(
              opacity: _currentPage > 0 ? 1 : 0,
              child: IgnorePointer(
                ignoring: _currentPage == 0,
                child: OutlinedButton.icon(
                  onPressed: _previousPage,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Sebelumnya'),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _currentPage == defaultQuestions.length - 1
                ? CustomButton(
                    text: 'Lihat Hasil',
                    icon: Icons.check_circle,
                    onPressed: qState.isComplete
                        ? () => _showSummaryDialog(context, qState)
                        : null,
                  )
                : CustomButton(
                    text: 'Selanjutnya',
                    icon: Icons.arrow_forward,
                    onPressed:
                        qState.answers.containsKey(
                          defaultQuestions[_currentPage].id,
                        )
                        ? _nextPage
                        : null,
                  ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
            SizedBox(width: 12),
            Text('Reset Jawaban'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua jawaban? '
          'Tindakan ini tidak dapat dibatalkan.',
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
              _pageController.jumpToPage(0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jawaban telah direset'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showSummaryDialog(BuildContext context, QuestionnaireState qState) {
    const questions = defaultQuestions;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.summarize, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('Ringkasan Jawaban'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: questions.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final q = questions[index];
              final answer = qState.answers[q.id];
              final option = q.options.firstWhere((opt) => opt.score == answer);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${index + 1}: ${q.text}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            option.label,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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
              ref.read(answersProvider.notifier).state = orderedAnswers;

              // Navigasi ke hasil
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ResultPage()),
              );
            },
            child: const Text('Lanjut ke Hasil'),
          ),
        ],
      ),
    );
  }
}
