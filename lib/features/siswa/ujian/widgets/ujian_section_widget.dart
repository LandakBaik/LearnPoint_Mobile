import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/materi_error_state_widget.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/models/ujian_model.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/detail_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/hasil_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/soal_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/widgets/ujian_token_dialog_widget.dart';

class UjianSectionWidget extends StatelessWidget {
  final String subjectName;
  final List<UjianItem> ujianList;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onRefreshNeeded;

  const UjianSectionWidget({
    super.key,
    required this.subjectName,
    required this.ujianList,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onRefreshNeeded,
  });

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'Sesuai Jadwal';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day ${months[dt.month - 1]} ${dt.year}, $hour:$minute WIB';
  }

  Future<void> _handleMulaiUjian(BuildContext context, UjianItem item) async {
    if (item.sudahMulai && !item.sudahDikerjakan) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizStartPage(ujianId: item.id)),
      );
      onRefreshNeeded();
      return;
    }

    final berhasil = await UjianTokenDialogWidget.show(context, item);

    if (berhasil == true && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizStartPage(ujianId: item.id)),
      );
      onRefreshNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: MateriErrorStateWidget(
          message: errorMessage!,
          onRetry: onRetry,
        ),
      );
    }

    if (ujianList.isEmpty) {
      return Center(
        child: MateriErrorStateWidget.empty(
          message: 'Belum ada ujian yang dijadwalkan untuk mata pelajaran ini.',
          onRetry: onRetry,
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < ujianList.length; i++) ...[
          _buildUjianCardFromApi(context, ujianList[i]),
          if (i < ujianList.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildUjianCardFromApi(BuildContext context, UjianItem item) {
    final bool isCompleted = item.sudahDikerjakan;
    final bool isScheduled = !isCompleted && item.status == 'scheduled';
    final bool isExpired = !isCompleted && item.status == 'completed';
    final bool isActive = !isCompleted && item.status == 'published';

    final String typeTag = item.jenisUjian == 'remidi'
        ? 'REMIDI'
        : (item.jenisUjian == 'susulan' ? 'SUSULAN' : 'UJIAN');

    final Color iconColor = isCompleted
        ? const Color(0xFF00A875)
        : (isScheduled
            ? const Color(0xFF0088B5)
            : (isExpired ? const Color(0xFF64748B) : const Color(0xFFFF5C5C)));

    final Color iconBg = isCompleted
        ? const Color(0xFFBFFFE7)
        : (isScheduled
            ? const Color(0xFFD4F0FF)
            : (isExpired ? const Color(0xFFE2E8F0) : const Color(0xFFFFD9D9)));

    final String statusText = isCompleted
        ? (item.tampilkanNilai && item.nilaiSiswa != null
            ? 'Nilai: ${item.nilaiSiswa!.toStringAsFixed(0)}'
            : 'Selesai')
        : (isScheduled
            ? 'Terjadwal'
            : (isExpired
                ? 'Waktu Habis'
                : (item.sudahMulai ? 'Sedang Dikerjakan' : 'Belum dikerjakan')));

    final Color statusBg = isCompleted
        ? const Color(0xFFE7F7F1)
        : (isScheduled
            ? const Color(0xFFE4EDFA)
            : (isExpired ? const Color(0xFFF1F5F9) : const Color(0xFFDDEBFF)));

    final String buttonText = isCompleted
        ? 'Lihat Hasil'
        : (isActive
            ? (item.sudahMulai ? 'Lanjutkan' : 'Mulai Ujian')
            : 'Lihat Detail');

    final IconData buttonIcon = isCompleted
        ? Icons.check
        : (isActive ? Icons.play_arrow : Icons.info_outline);

    final String bottomInfo = isCompleted
        ? 'Selesai pada ${_formatDateTime(item.waktuSelesai)}'
        : (isScheduled
            ? 'Jadwal: ${_formatDateTime(item.waktuMulai)}'
            : 'Batas: ${_formatDateTime(item.deadline)}');

    final Color bottomColor = isCompleted
        ? const Color(0xFF007A58)
        : (isScheduled ? const Color(0xFF0072A8) : Colors.red);

    return _buildQuizCard(
      context: context,
      item: item,
      type: typeTag,
      subject: item.mapel.isNotEmpty ? item.mapel : subjectName,
      grade: 'Kelas ${item.kelas} • Sesi ${item.sesi}',
      title: item.judul,
      icon: isCompleted
          ? Icons.insights_outlined
          : (isScheduled ? Icons.assignment_outlined : Icons.quiz_outlined),
      iconColor: iconColor,
      iconBackground: iconBg,
      info1: '${item.totalSoal} Butir Soal',
      info2: '${item.durasiMenit} Menit • KKM ${item.kkm.toStringAsFixed(0)}',
      infoIcon1: isCompleted ? Icons.check_circle_outline : Icons.quiz_outlined,
      infoIcon2: Icons.access_time,
      bottomInfo: bottomInfo,
      bottomIcon: isCompleted
          ? Icons.check_circle_outline
          : (isScheduled
              ? Icons.calendar_month_outlined
              : Icons.event_busy_outlined),
      bottomColor: bottomColor,
      status: statusText,
      statusColor: statusBg,
      buttonText: buttonText,
      buttonIcon: buttonIcon,
      buttonEnabled: true,
      completed: isCompleted,
    );
  }

  Widget _buildQuizCard({
    required BuildContext context,
    required UjianItem item,
    required String type,
    required String subject,
    required String grade,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String info1,
    required String info2,
    required IconData infoIcon1,
    required IconData infoIcon2,
    required String bottomInfo,
    required IconData bottomIcon,
    required Color bottomColor,
    required String status,
    required Color statusColor,
    required String buttonText,
    required IconData buttonIcon,
    required bool buttonEnabled,
    bool completed = false,
  }) {
    const Color primaryBlue = Color(0xFF0757C9);
    const Color darkText = Color(0xFF13233A);
    const Color secondaryText = Color(0xFF596579);
    const Color cardBlue = Color(0xFFF0F5FF);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE1E6EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 3,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: iconBackground,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: iconColor,
                            ),
                          ),
                        ),
                        Text(
                          '$subject • $grade',
                          style: const TextStyle(
                            fontSize: 9,
                            color: secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
            decoration: BoxDecoration(
              color: cardBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _infoItem(infoIcon1, info1)),
                    Expanded(child: _infoItem(infoIcon2, info2)),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(bottomIcon, size: 15, color: bottomColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        bottomInfo,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: bottomColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      completed ? Icons.visibility_outlined : Icons.circle,
                      size: completed ? 14 : 7,
                      color: completed
                          ? const Color(0xFF007A58)
                          : const Color(0xFF6D778A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: completed
                            ? const Color(0xFF007A58)
                            : const Color(0xFF596579),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (buttonText.isNotEmpty)
                SizedBox(
                  height: 34,
                  child: TextButton(
                    onPressed: buttonEnabled
                        ? () async {
                            if (completed) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HasilUjianPage(ujianId: item.id),
                                ),
                              );
                              onRefreshNeeded();
                            } else if (buttonText == 'Mulai Ujian' ||
                                buttonText == 'Lanjutkan') {
                              await _handleMulaiUjian(context, item);
                            } else {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailUjianPage(ujianId: item.id),
                                ),
                              );
                              onRefreshNeeded();
                            }
                          }
                        : null,
                    style: TextButton.styleFrom(
                      backgroundColor: buttonEnabled
                          ? primaryBlue
                          : const Color(0xFFD7E5FF),
                      foregroundColor: buttonEnabled
                          ? Colors.white
                          : primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: buttonEnabled ? Colors.white : primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          buttonIcon,
                          size: 16,
                          color: buttonEnabled ? Colors.white : primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF0757C9)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF596579),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
