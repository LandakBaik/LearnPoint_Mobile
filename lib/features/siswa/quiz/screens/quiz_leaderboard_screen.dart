import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/quiz/models/leaderboard_entry_model.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/services/quiz_api_service.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_leaderboard/leaderboard_app_bar_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_leaderboard/leaderboard_podium_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_leaderboard/leaderboard_rank_tile_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_leaderboard/leaderboard_state_widgets.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_leaderboard/leaderboard_sticky_my_rank_widget.dart';
import 'package:learnpoint_mobile/features/siswa/quiz/widgets/quiz_leaderboard/leaderboard_subject_filter_widget.dart';

class QuizLeaderboardScreen extends StatefulWidget {
  final int? initialMapelId;

  const QuizLeaderboardScreen({super.key, this.initialMapelId});

  @override
  State<QuizLeaderboardScreen> createState() => _QuizLeaderboardScreenState();
}

class _QuizLeaderboardScreenState extends State<QuizLeaderboardScreen> {
  int? _selectedMapelId;
  bool _isLoading = true;
  String? _errorMessage;

  QuizLeaderboardResponseModel? _data;
  List<LeaderboardMapelOptionModel> _cachedFilterMapels = const [];

  @override
  void initState() {
    super.initState();
    _selectedMapelId = widget.initialMapelId;
    _loadLeaderboard(mapelId: _selectedMapelId);
  }

  Future<void> _loadLeaderboard({int? mapelId, bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await QuizApiService.fetchLeaderboard(
        mapelId: mapelId,
      );
      if (!mounted) return;
      setState(() {
        _data = result;
        if (result.filterMapels.isNotEmpty) {
          _cachedFilterMapels = result.filterMapels;
        }
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSelectMapel(int? mapelId) {
    if (_selectedMapelId == mapelId && _errorMessage == null) return;
    setState(() {
      _selectedMapelId = mapelId;
    });
    _loadLeaderboard(mapelId: mapelId);
  }

  @override
  Widget build(BuildContext context) {
    final filterMapels = (_data?.filterMapels.isNotEmpty ?? false)
        ? _data!.filterMapels
        : _cachedFilterMapels;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1026),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1026), Color(0xFF151C42), Color(0xFF1A2250)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              LeaderboardAppBarWidget(
                tingkatan: _data?.tingkatan,
                periodeLabel: _data?.periodeLabel ?? 'Periode Aktif',
                selectedMapelName: _data?.selectedMapel?.namaMapel,
              ),
              if (filterMapels.isNotEmpty) ...[
                LeaderboardSubjectFilterWidget(
                  mapels: filterMapels,
                  selectedMapelId: _selectedMapelId,
                  onSelectMapel: _onSelectMapel,
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: _buildBodyContent(),
              ),
              if (!_isLoading && _errorMessage == null && _data != null)
                LeaderboardStickyMyRankWidget(myRank: _data!.myRank),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const LeaderboardLoadingStateWidget();
    }

    if (_errorMessage != null) {
      return LeaderboardErrorStateWidget(
        errorMessage: _errorMessage!,
        onRetry: () => _loadLeaderboard(mapelId: _selectedMapelId),
      );
    }

    final data = _data;
    if (data == null || data.leaderboard.isEmpty) {
      return LeaderboardEmptyStateWidget(
        tingkatan: data?.tingkatan,
        selectedMapelName: data?.selectedMapel?.namaMapel,
        onRefresh: () =>
            _loadLeaderboard(mapelId: _selectedMapelId, showLoading: false),
      );
    }

    final topThree = data.topThree;
    final restEntries = data.restRankings;

    return RefreshIndicator(
      color: const Color(0xFF38BDF8),
      onRefresh: () =>
          _loadLeaderboard(mapelId: _selectedMapelId, showLoading: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        children: [
          LeaderboardPodiumWidget(topThree: topThree),
          if (restEntries.isNotEmpty) ...[
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data.tingkatan != null
                        ? 'Daftar Peringkat Tingkatan ${data.tingkatan}'
                        : 'Daftar Peringkat Selanjutnya',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Total ${data.leaderboard.length} Siswa',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ...restEntries.map(
              (entry) => LeaderboardRankTileWidget(entry: entry),
            ),
          ],
        ],
      ),
    );
  }
}
