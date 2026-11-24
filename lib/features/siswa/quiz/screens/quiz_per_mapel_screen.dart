import 'package:flutter/material.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/config/quiz_assets.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/screens/quiz_level_screen.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/models/quiz_per_mapel_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_back_header_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_per_mapel/quiz_evaporating_hand_decoration_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_per_mapel/quiz_per_mapel_background_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_per_mapel/quiz_theme_list_section_widget.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizPerMapel extends StatefulWidget {
  final MateriModel? subject;

  const QuizPerMapel({super.key, this.subject});

  @override
  State<QuizPerMapel> createState() => _QuizPerMapelState();
}

class _QuizPerMapelState extends State<QuizPerMapel>
    with WidgetsBindingObserver {
  static const double _defaultBgmVolume = 0.4;
  late final AudioPlayer _bgmPlayer;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bgmPlayer = AudioPlayer();
    _initBgm();
  }

  Future<void> _initBgm() async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(_defaultBgmVolume);
      await _bgmPlayer.play(AssetSource('audio/bgm/The_Last_Threshold.mp3'));
    } catch (e) {
      debugPrint('Gagal memutar BGM: $e');
    }
  }

  Future<void> _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    if (_isMuted) {
      await _bgmPlayer.setVolume(0.0);
      await _bgmPlayer.pause();
    } else {
      await _bgmPlayer.setVolume(_defaultBgmVolume);
      await _bgmPlayer.resume();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _bgmPlayer.pause();
    } else if (state == AppLifecycleState.resumed && !_isMuted) {
      _bgmPlayer.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgmPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawTitle = widget.subject?.materi ?? 'Matematika';
    final subjectTitle = rawTitle.isNotEmpty
        ? '${rawTitle[0].toUpperCase()}${rawTitle.substring(1)}'
        : rawTitle;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 51, 60),
      body: Stack(
        children: [
          // 1. Layer Background: Satu warna sesuai planet (sedikit lebih gelap)
          //    + efek kabut gelap bergelombang di atas dan bawah layar
          const Positioned.fill(
            child: QuizPerMapelBackgroundWidget(
              baseColor: Color.fromARGB(255, 5, 58, 67),
            ),
          ),

          // 2. Layer Hiasan hand1.png dengan efek animasi menguap
          const Positioned.fill(
            child: QuizEvaporatingHandDecorationWidget(),
          ),

          // 3. Layer Konten Utama
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Atas: Tombol Back, Judul Mapel & Tombol Musik
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: QuizBackHeaderWidget(
                    title: subjectTitle,
                    trailing: InkWell(
                      onTap: _toggleMute,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isMuted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // Area Radial Menu (Planet + Ring Bergelombang + Pilihan Tema)
                Expanded(
                  child: QuizThemeListSectionWidget(
                    subject: widget.subject,
                    subjectTitle: subjectTitle,
                    themes: quizMapel,
                    onThemeTap: (item) async {
                      await _bgmPlayer.pause();
                      if (!context.mounted) return;
                      final planetAsset = widget.subject?.planetImageAsset ?? '';
                      final String? sceneThemeOverride =
                          QuizAssets.resolveSceneThemeForPlanet(planetAsset);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizLevel(
                            themeItem: item,
                            sceneThemeOverride: sceneThemeOverride,
                          ),
                        ),
                      );
                      if (mounted && !_isMuted) {
                        await _bgmPlayer.resume();
                      }
                    },
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
