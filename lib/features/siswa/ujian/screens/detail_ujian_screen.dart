import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/models/ujian_model.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/hasil_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/soal_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/services/ujian_api_service.dart';

class DetailUjianPage extends StatefulWidget {
  final int ujianId;

  const DetailUjianPage({super.key, required this.ujianId});

  @override
  State<DetailUjianPage> createState() => _DetailUjianPageState();
}

class _DetailUjianPageState extends State<DetailUjianPage> {
  static const Color bgScaffold = Color(0xFFF0F6FE);
  static const Color primaryBlue = Color(0xFF1D61E7);

  UjianDetail? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final result = await UjianApiService.getUjianDetail(widget.ujianId);
      if (!mounted) return;
      setState(() {
        _detail = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Belum dijadwalkan';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatHour(String? raw) {
    if (raw == null || raw.isEmpty) return '--:--';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _countdownText(String? rawStart) {
    if (rawStart == null || rawStart.isEmpty) return '-';
    final start = DateTime.tryParse(rawStart)?.toLocal();
    if (start == null) return '-';
    final diff = start.difference(DateTime.now());
    if (diff.isNegative) return 'Sudah Dibuka';
    if (diff.inDays > 0) {
      return '${diff.inDays} Hari ${diff.inHours % 24} Jam Lagi';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} Jam ${diff.inMinutes % 60} Menit Lagi';
    }
    return '${diff.inMinutes} Menit Lagi';
  }

  Future<void> _bukaDialogToken(UjianDetail detail) async {
    if (detail.sudahMulai) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizStartPage(ujianId: detail.id)),
      );
      if (mounted) _loadDetail();
      return;
    }

    final controller = TextEditingController();
    String? err;
    bool submitting = false;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            'Validasi Token Ujian',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Masukkan token Sesi ${detail.sesi} dari pengawas untuk mulai mengerjakan.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                decoration: InputDecoration(
                  hintText: 'S1-XXXX',
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (err != null) ...[
                const SizedBox(height: 8),
                Text(err!, style: const TextStyle(fontSize: 11.5, color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (controller.text.trim().isEmpty) {
                        setDialogState(() => err = 'Token wajib diisi.');
                        return;
                      }
                      setDialogState(() {
                        submitting = true;
                        err = null;
                      });
                      try {
                        await UjianApiService.validasiToken(
                          ujianId: detail.id,
                          token: controller.text.trim(),
                        );
                        if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                      } catch (e) {
                        setDialogState(() {
                          submitting = false;
                          err = e.toString().replaceFirst('Exception: ', '');
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mulai'),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
    if (ok == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizStartPage(ujianId: detail.id)),
      );
      if (mounted) _loadDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 22, color: Color(0xFF1E293B)),
        ),
        title: const Text(
          'Detail Ujian',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : _errorMessage != null || _detail == null
              ? _buildErrorView()
              : _buildBody(_detail!),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 46, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Detail ujian tidak ditemukan.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(UjianDetail detail) {
    final pgCount = detail.singleChoiceCount + detail.multipleChoiceCount;
    final totalSoal = detail.totalSoal > 0 ? detail.totalSoal : (pgCount + detail.essayCount);
    final pgPersen = totalSoal > 0 ? ((pgCount / totalSoal) * 100).round() : 0;
    final essayPersen = totalSoal > 0 ? ((detail.essayCount / totalSoal) * 100).round() : 0;

    return RefreshIndicator(
      onRefresh: _loadDetail,
      color: primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header Ujian
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6E8FE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_outlined, size: 13, color: primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          '${detail.jenisUjian.toUpperCase()} • SESI ${detail.sesi}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.judul,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${detail.mapel} • Kelas ${detail.kelas} • ${detail.guru}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2EDFE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.assignment_outlined, color: primaryBlue, size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F6FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18, color: primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tanggal', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              Text(
                                _formatDate(detail.waktuMulai),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 26, color: const Color(0xFFCBD5E1)),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, size: 18, color: primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Jam & Durasi', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              Text(
                                '${_formatHour(detail.waktuMulaiSesi)} - ${_formatHour(detail.batasAkhirSesi)} (${detail.durasiMenit}m)',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EDFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              detail.sudahDikerjakan ? 'Sudah Selesai' : detail.statusLabel,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          detail.status == 'scheduled'
                              ? _countdownText(detail.waktuMulai)
                              : (detail.sudahDikerjakan ? 'Selesai' : 'Aktif'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Spesifikasi & Format Soal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Spesifikasi & Format Soal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Text(
                  'Standar KKM: ${detail.kkm.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Soal',
                    icon: Icons.assignment_outlined,
                    iconBg: const Color(0xFFE2EDFE),
                    iconColor: primaryBlue,
                    value: '$totalSoal',
                    subtitle: 'Total ${detail.totalPoin.toStringAsFixed(0)} Poin',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Nilai Target (KKM)',
                    icon: Icons.military_tech_outlined,
                    iconBg: const Color(0xFFD1FAE5),
                    iconColor: const Color(0xFF10B981),
                    value: '${detail.kkm.toStringAsFixed(0)} / 100',
                    valueColor: const Color(0xFF047857),
                    subtitle: 'Batas Minimal Lulus',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pilihan Ganda',
                    tag: '$pgPersen%',
                    tagBg: const Color(0xFFDCE7FF),
                    tagColor: primaryBlue,
                    value: '$pgCount Soal',
                    subtitle: 'Tunggal: ${detail.singleChoiceCount} • Kompleks: ${detail.multipleChoiceCount}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Uraian / Esai',
                    tag: '$essayPersen%',
                    tagBg: const Color(0xFFD6F2FE),
                    tagColor: const Color(0xFF0284C7),
                    value: '${detail.essayCount} Soal',
                    subtitle: 'Dinilai oleh Guru Pengampu',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Kisi-kisi Materi
            const Text(
              'Kisi-Kisi Materi Ujian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                (detail.kisiKisi != null && detail.kisiKisi!.trim().isNotEmpty)
                    ? detail.kisiKisi!
                    : 'Guru belum menambahkan rincian kisi-kisi khusus untuk ujian ini.',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF334155),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Card Persiapan Sebelum Ujian
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF1EA1F2),
                    child: Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tata Tertib & Anti-Curang',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pastikan koneksi internet stabil. Jangan berpindah aplikasi saat ujian berlangsung — pelanggaran 3 kali akan mengunci sesi secara otomatis.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Aksi Utama
            if (detail.sudahDikerjakan)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HasilUjianPage(ujianId: detail.id)),
                    );
                  },
                  icon: const Icon(Icons.bar_chart_rounded),
                  label: const Text('Lihat Hasil Ujian', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007E59),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            else if (detail.status == 'published')
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _bukaDialogToken(detail),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    detail.sudahMulai ? 'Lanjutkan Mengerjakan' : 'Masukkan Token & Mulai Ujian',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildMetricCard({
    required String title,
    IconData? icon,
    Color? iconBg,
    Color? iconColor,
    String? tag,
    Color? tagBg,
    Color? tagColor,
    required String value,
    Color valueColor = const Color(0xFF0F172A),
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, size: 14, color: iconColor),
                ),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    tag,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}