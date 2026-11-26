import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:learnpoint_mobile/core/utils/dot_lottie_decoder.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/core/widgets/inverted_top_curve_clipper.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_subject_item_card_widget.dart';

class QuizSubjectListSectionWidget extends StatelessWidget {
  static const String _loadingLottieAsset =
      'assets/lottie/loading_black.lottie';

  final List<MateriModel> subjects;
  final ValueChanged<MateriModel>? onSubjectTap;

  /// true selama data mapel dari API belum selesai dimuat.
  final bool isLoading;

  /// Pesan error jika gagal memuat data (null = tidak ada error).
  final String? errorMessage;

  /// Dipanggil saat tombol "Coba Lagi" ditekan.
  final VoidCallback? onRetry;

  const QuizSubjectListSectionWidget({
    super.key,
    required this.subjects,
    this.onSubjectTap,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  Widget _buildLoading() {
    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: Lottie.asset(
          _loadingLottieAsset,
          decoder: decodeDotLottie,
          repeat: true,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String message,
    bool showRetry = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.black38),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(double cardHorizontalMargin) {
    if (isLoading) return _buildLoading();

    if (errorMessage != null) {
      return _buildMessage(
        icon: Icons.cloud_off_rounded,
        message: errorMessage!,
        showRetry: true,
      );
    }

    if (subjects.isEmpty) {
      return _buildMessage(
        icon: Icons.menu_book_rounded,
        message: 'Belum ada mata pelajaran.',
        showRetry: true,
      );
    }

    return ListView.builder(
      itemCount: subjects.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final sub = subjects[index];
        final isCircleOnLeft = index % 2 == 0;

        return QuizSubjectItemCardWidget(
          subject: sub,
          isCircleOnLeft: isCircleOnLeft,
          horizontalMargin: cardHorizontalMargin,
          onTap: () => onSubjectTap?.call(sub),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const InvertedTopCurveClipper(
        cornerRadius: 15,
        curveDepth: 20,
        centerX: 0.5,
        curveHalfWidth: 0.52,
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.fromLTRB(0, 45, 0, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHorizontalMargin = constraints.maxWidth < 360
                ? 12.0
                : 20.0;

            return _buildContent(cardHorizontalMargin);
          },
        ),
      ),
    );
  }
}
