import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskCardWidget extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onSeeAll;
  final ValueChanged<Map<String, dynamic>> onTapTask;

  const TaskCardWidget({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onSeeAll,
    required this.onTapTask,
  });

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  int _currentTaskIndex = 0;

  // Tugas dalam rentang 7 hari terakhir.
  // Tanggal kosong / tidak terbaca tetap ditampilkan
  // agar tugas tidak hilang hanya karena format tanggal.
  List<Map<String, dynamic>> get _recentTasks {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final recent = widget.tasks.where((task) {
      final rawDate = task['created_at']?.toString();

      if (rawDate == null || rawDate.isEmpty) {
        return true;
      }

      final createdAt = DateTime.tryParse(rawDate);

      if (createdAt == null) {
        return true;
      }

      final localCreatedAt = createdAt.toLocal();

      return !localCreatedAt.isBefore(sevenDaysAgo) &&
          !localCreatedAt.isAfter(now);
    }).toList();

    // Tugas terbaru ditampilkan terlebih dahulu.
    // Tugas dengan tanggal yang tidak diketahui berada di bagian bawah.
    recent.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at']?.toString() ?? '');

      final dateB = DateTime.tryParse(b['created_at']?.toString() ?? '');

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    return recent;
  }

  @override
  void didUpdateWidget(covariant TaskCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tasks != widget.tasks) {
      _currentTaskIndex = 0;
    }

    // Amankan index jika jumlah tugas berubah.
    if (_currentTaskIndex >= _recentTasks.length) {
      _currentTaskIndex = 0;
    }
  }

  void _nextTask() {
    if (_currentTaskIndex < _recentTasks.length - 1) {
      setState(() {
        _currentTaskIndex++;
      });
    }
  }

  void _previousTask() {
    if (_currentTaskIndex > 0) {
      setState(() {
        _currentTaskIndex--;
      });
    }
  }

  TextStyle _textStyle({
    double fontSize = 13,
    Color color = const Color(0xFF1E1B4B),
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Loading
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 24, bottom: 30),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
        ),
      );
    }

    // 2. Error
    if (widget.error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 10),
                Text(
                  'Gagal memuat tugas',
                  style: _textStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.error!,
                  textAlign: TextAlign.center,
                  style: _textStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: widget.onRetry,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Ambil daftar tugas terbaru.
    final tasks = _recentTasks;

    // 3. Empty state
    if (tasks.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildEmptyHeader(),
          const SizedBox(height: 12),
          _buildEmptyCard(),
        ],
      );
    }

    // Index aman agar tidak error ketika data berubah.
    final safeIndex = _currentTaskIndex.clamp(0, tasks.length - 1);
    final currentTask = tasks[safeIndex];

    // 4. Card tugas
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tugas Terbaru',
              style: _textStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ).copyWith(letterSpacing: -0.3),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${safeIndex + 1} / ${tasks.length}',
                    style: _textStyle(
                      fontSize: 12,
                      color: const Color(0xFF374151),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: widget.onSeeAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Lihat Semua ›',
                      style: _textStyle(
                        fontSize: 13,
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Card dengan gesture swipe
        GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;

            if (velocity < -200) {
              _nextTask();
            } else if (velocity > 200) {
              _previousTask();
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Container(
              key: ValueKey(currentTask['id'] ?? safeIndex),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge mapel dan deadline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: _buildSubjectBadge(currentTask)),
                      const SizedBox(width: 8),
                      _buildRemainingBadge(currentTask),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Judul
                  Text(
                    currentTask['title']?.toString() ?? 'Tugas tanpa judul',
                    style: _textStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ).copyWith(height: 1.35),
                  ),

                  const SizedBox(height: 6),

                  // Deadline
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF5B6275),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          currentTask['deadline']?.toString() ??
                              'Batas: Tidak tersedia',
                          style: _textStyle(
                            fontSize: 13,
                            color: const Color(0xFF5B6275),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  const Divider(color: Color(0xFFE5E7EB), height: 1),

                  const SizedBox(height: 14),

                  // Status dan tombol kerjakan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.list_alt_rounded,
                              size: 16,
                              color: Color(0xFF5B6275),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                currentTask['progressText']?.toString() ??
                                    'Belum dikumpulkan',
                                overflow: TextOverflow.ellipsis,
                                style: _textStyle(
                                  fontSize: 13,
                                  color: const Color(0xFF5B6275),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      ElevatedButton.icon(
                        onPressed: () => widget.onTapTask(currentTask),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        label: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                        icon: const Text('Kerjakan'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Indikator dan tombol navigasi
                  _buildPagination(safeIndex, tasks.length),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Header empty state
  Widget _buildEmptyHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tugas Terbaru',
          style: _textStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        InkWell(
          onTap: widget.onSeeAll,
          child: Text(
            'Lihat Semua ›',
            style: _textStyle(
              fontSize: 12,
              color: const Color(0xFF4F46E5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // Empty card
  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8E7F5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEAFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.assignment_turned_in_rounded,
              size: 38,
              color: Color(0xFF6255E8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeay, tugasmu kosong!',
                  style: _textStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  'Belum ada tugas baru untuk dikerjakan. '
                  'Nikmati waktu belajarmu!',
                  style: _textStyle(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ).copyWith(height: 1.5),
                ),
                const SizedBox(height: 7),
                Text(
                  'Semangat belajar ✨',
                  style: _textStyle(
                    fontSize: 11,
                    color: const Color(0xFF6255E8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Badge mapel
  Widget _buildSubjectBadge(Map<String, dynamic> task) {
    final subjectBg = task['subjectBg'] as Color? ?? const Color(0xFFF3E8FF);

    final subjectColor =
        task['subjectColor'] as Color? ?? const Color(0xFF7E22CE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: subjectBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded, size: 14, color: subjectColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              task['subject']?.toString() ?? 'Mata Pelajaran',
              overflow: TextOverflow.ellipsis,
              style: _textStyle(
                fontSize: 12,
                color: subjectColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Badge waktu tersisa
  Widget _buildRemainingBadge(Map<String, dynamic> task) {
    final remainingBg =
        task['remainingBg'] as Color? ?? const Color(0xFFFEE2E2);

    final remainingColor =
        task['remainingColor'] as Color? ?? const Color(0xFF9F1239);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: remainingBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: remainingColor),
          const SizedBox(width: 5),
          Text(
            task['remaining']?.toString() ?? 'Deadline',
            style: _textStyle(
              fontSize: 12,
              color: remainingColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Dot indikator dan tombol sebelumnya/berikutnya
  Widget _buildPagination(int currentIndex, int totalTasks) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Indikator dot
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(totalTasks, (index) {
                final isActive = index == currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: 6),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Tombol navigasi
        Row(
          children: [
            _buildNavigationButton(
              isEnabled: currentIndex > 0,
              icon: Icons.chevron_left_rounded,
              onTap: _previousTask,
            ),
            const SizedBox(width: 8),
            _buildNavigationButton(
              isEnabled: currentIndex < totalTasks - 1,
              icon: Icons.chevron_right_rounded,
              onTap: _nextTask,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required bool isEnabled,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
          size: 22,
        ),
      ),
    );
  }
}
