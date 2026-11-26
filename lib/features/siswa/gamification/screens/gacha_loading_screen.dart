import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:learnpoint_mobile/core/utils/dot_lottie_decoder.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/data/gacha_service.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/screens/gacha_screen.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/config/quiz_assets.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_per_mapel_loading_screen.dart';

/// Layar loading yang tampil saat berpindah dari halaman Quiz ke Gacha
/// maupun ketika kembali dari Gacha ke Quiz.
class GachaLoadingScreen extends StatefulWidget {
  /// Jika true, layar loading ini dipakai saat kembali dari Gacha ke Quiz.
  /// Setelah jeda loading selesai, halaman langsung di-pop kembali ke Quiz.
  final bool isReturning;

  const GachaLoadingScreen({
    super.key,
    this.isReturning = false,
  });

  @override
  State<GachaLoadingScreen> createState() => _GachaLoadingScreenState();
}

/// Animasi loading bintang (format dotLottie / .lottie).
const String _loadingLottieAsset = 'assets/lottie/loading_bintang.lottie';

class _GachaLoadingScreenState extends State<GachaLoadingScreen> {
  /// Durasi minimum loading saat masuk ke Gacha.
  static const Duration _minimumDuration = Duration(milliseconds: 900);

  /// Durasi loading saat kembali ke halaman utama Quiz.
  static const Duration _returnDuration = Duration(milliseconds: 750);

  /// Batas waktu request API agar loading tidak menggantung selamanya.
  static const Duration _apiTimeout = Duration(seconds: 10);

  /// Warna dasar latar belakang yang senada dengan tema Gacha luar angkasa.
  static const Color _gachaBaseColor = Color(0xFF14182D);

  bool _started = false;

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

  Future<GachaStatusModel?> _fetchGachaStatus() async {
    try {
      return await GachaService.fetchGachaStatus().timeout(_apiTimeout);
    } catch (_) {
      return null;
    }
  }

  Future<void> _precacheGachaAssets() async {
    const paths = <String>{
      QuizAssets.gachaMainBg,
      QuizAssets.gachaSpiral,
      QuizAssets.gachaBigStars,
      QuizAssets.gachaStars,
      QuizAssets.gachaMist,
      QuizAssets.gachaLightPath,
      QuizAssets.gachaGroundStarsLight,
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
      _fetchGachaStatus(),
      _precacheGachaAssets(),
      Future<void>.delayed(_minimumDuration),
    ]);

    if (!mounted) return;
    final initialStatus = results[0] as GachaStatusModel?;

    await Navigator.of(context).pushReplacement(
      quizSlideRoute<void>(
        Gacha(initialStatus: initialStatus),
        duration: const Duration(milliseconds: 550),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusText =
        widget.isReturning ? 'Kembali ke daftar kuis...' : 'Memuat gacha...';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _gachaBaseColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color.lerp(_gachaBaseColor, const Color(0xFF4F46E5), 0.25)!,
                _gachaBaseColor,
                Color.lerp(_gachaBaseColor, Colors.black, 0.55)!,
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
                      Icons.auto_awesome_rounded,
                      size: 120,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Gacha',
                  style: TextStyle(
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
