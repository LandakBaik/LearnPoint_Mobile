import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:learnpoint_mobile/core/utils/dot_lottie_decoder.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/config/quiz_assets.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_per_mapel_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_per_mapel_screen.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/services/quiz_api_service.dart';

/// Route slide vertikal dari bawah ke atas (Offset(0.0, 1.0) -> Offset.zero)
/// yang dipakai untuk transisi Quiz <-> Loading <-> QuizPerMapel.
Route<T> quizSlideRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 450),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

/// Layar loading yang menutupi layar selama data & aset QuizPerMapel disiapkan,
/// atau ketika kembali dari QuizPerMapel ke halaman utama Quiz.
class QuizPerMapelLoadingScreen extends StatefulWidget {
  final MateriModel subject;

  /// Jika true, layar loading ini dipakai saat kembali dari QuizPerMapel ke Quiz.
  /// Setelah jeda loading selesai, halaman langsung di-pop kembali ke Quiz.
  final bool isReturning;

  const QuizPerMapelLoadingScreen({
    super.key,
    required this.subject,
    this.isReturning = false,
  });

  @override
  State<QuizPerMapelLoadingScreen> createState() =>
      _QuizPerMapelLoadingScreenState();
}

/// Animasi loading bintang (format dotLottie / .lottie).
const String _loadingLottieAsset = 'assets/lottie/loading_bintang.lottie';

class _QuizPerMapelLoadingScreenState
    extends State<QuizPerMapelLoadingScreen> {
  /// Durasi minimum loading saat masuk ke QuizPerMapel.
  static const Duration _minimumDuration = Duration(milliseconds: 900);

  /// Durasi loading saat kembali ke halaman utama Quiz.
  static const Duration _returnDuration = Duration(milliseconds: 750);

  /// Batas waktu request API agar loading tidak menggantung selamanya.
  static const Duration _apiTimeout = Duration(seconds: 10);

  bool _started = false;

  QuizPlanetAssetGroup get _planetGroup => widget.subject.planetGroup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      if (widget.isReturning) {
        _prepareAndReturn();
      } else {
        _prepareAndOpen();
      }
    }
  }

  Future<void> _prepareAndReturn() async {
    await Future<void>.delayed(_returnDuration);
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<List<QuizPerMapelM>?> _fetchThemes() async {
    try {
      final quizzes = await QuizApiService.fetchQuizzes(
        mapelId: widget.subject.id,
      ).timeout(_apiTimeout);
      return quizzes.isEmpty ? null : quizzes;
    } catch (_) {
      // Gagal/offline -> QuizPerMapel memakai fallback `quizMapel`
      return null;
    }
  }

  Future<void> _precacheAssets() async {
    final group = _planetGroup;
    final paths = <String>{
      group.planetAsset,
      group.menuShardAsset,
      group.handDecorAsset,
    };
    await Future.wait(
      paths.map(
        (path) => precacheImage(
          AssetImage(path),
          context,
          onError: (_, _) {},
        ),
      ),
    );
  }

  Future<void> _prepareAndOpen() async {
    final results = await Future.wait<dynamic>([
      _fetchThemes(),
      _precacheAssets(),
      Future<void>.delayed(_minimumDuration),
    ]);

    if (!mounted) return;
    final themes = results[0] as List<QuizPerMapelM>?;

    await Navigator.of(context).pushReplacement(
      quizSlideRoute<void>(
        QuizPerMapel(subject: widget.subject, initialThemes: themes),
        duration: const Duration(milliseconds: 550),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = _planetGroup;
    final rawTitle = widget.subject.materi;
    final title = rawTitle.isNotEmpty
        ? '${rawTitle[0].toUpperCase()}${rawTitle.substring(1)}'
        : rawTitle;
    final statusText =
        widget.isReturning ? 'Kembali ke daftar kuis...' : 'Memuat kuis...';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: group.radialBgColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color.lerp(group.radialBgColor, Colors.white, 0.12)!,
                group.radialBgColor,
                Color.lerp(group.radialBgColor, Colors.black, 0.45)!,
              ],
              stops: const [0.0, 0.55, 1.0],
              radius: 1.1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Lottie.asset(
                    _loadingLottieAsset,
                    decoder: decodeDotLottie,
                    repeat: true,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.star_rounded,
                      size: 120,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  statusText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
