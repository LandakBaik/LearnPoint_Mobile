import 'dart:math';
import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/models/ujian_model.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/services/ujian_api_service.dart';

class HasilUjianPage extends StatefulWidget {
  final int ujianId;

  const HasilUjianPage({super.key, required this.ujianId});

  @override
  State<HasilUjianPage> createState() => _HasilUjianPageState();
}

class _HasilUjianPageState extends State<HasilUjianPage> {
  UjianHasilData? _hasil;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHasil();
  }

  Future<void> _loadHasil() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final res = await UjianApiService.getHasilUjian(widget.ujianId);
      if (!mounted) return;
      setState(() {
        _hasil = res;
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

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$d ${months[dt.month - 1]} ${dt.year}, $h:$m WIB';
  }

  String _formatDurasi(int? detik) {
    if (detik == null || detik <= 0) return '-';
    final menit = detik ~/ 60;
    final sisaDetik = detik % 60;
    if (menit > 0) return '${menit}m ${sisaDetik}d';
    return '${sisaDetik}d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hasil Ujian',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0056D2)))
          : _errorMessage != null || _hasil == null
              ? _buildErrorView()
              : _buildBody(_hasil!),
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
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Hasil ujian tidak ditemukan.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _loadHasil,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0056D2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(UjianHasilData hasil) {
    final bool showScore = hasil.tampilkanNilai && hasil.nilai != null;
    final double nilaiAngka = hasil.nilai ?? 0;
    final double progress = (nilaiAngka / 100).clamp(0.0, 1.0);
    final Color gaugeColor = hasil.essayBelumDinilai
        ? const Color(0xFFD97706)
        : (hasil.tuntas ? const Color(0xFF007E59) : const Color(0xFFD32F2F));

    return RefreshIndicator(
      onRefresh: _loadHasil,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            // Top Score Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF1F8F6), Colors.white],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0EFFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${hasil.mapel} • Kelas ${hasil.kelas}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B63E5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hasil.judul,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 5),
                      Text(
                        'Selesai pada ${_formatDateTime(hasil.waktuSelesai)}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (showScore) ...[
                    CustomPaint(
                      painter: CircleGaugePainter(
                        progress: progress,
                        activeColor: gaugeColor,
                        trackColor: const Color(0xFFE2E8F0),
                        strokeWidth: 9,
                      ),
                      child: SizedBox(
                        width: 124,
                        height: 124,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                nilaiAngka.toStringAsFixed(nilaiAngka % 1 == 0 ? 0 : 1),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'KKM: ${hasil.kkm.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: hasil.essayBelumDinilai
                            ? const Color(0xFFFEF3C7)
                            : (hasil.tuntas ? const Color(0xFFD6EFE5) : const Color(0xFFFFE5E5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasil.essayBelumDinilai
                                ? Icons.hourglass_bottom_rounded
                                : (hasil.tuntas ? Icons.verified : Icons.info_outline),
                            size: 16,
                            color: gaugeColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasil.essayBelumDinilai
                                ? 'MENUNGGU KOREKSI ESAI'
                                : (hasil.tuntas ? 'LULUS / TUNTAS' : 'BELUM TUNTAS'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: gaugeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        hasil.essayBelumDinilai
                            ? 'Nilai sementara baru menghitung soal Pilihan Ganda. Nilai akhir akan diperbarui setelah guru mengoreksi jawaban esai.'
                            : (hasil.tuntas
                                ? 'Hebat! Nilaimu telah melampaui batas ketuntasan minimum (KKM).'
                                : 'Tetap semangat! Pelajari kembali materinya untuk persiapan remidi.'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.4),
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6EFE5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, size: 40, color: Color(0xFF007E59)),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Jawaban Berhasil Dikirim',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Guru memilih untuk menyembunyikan skor ujian sementara. Nilai akan diumumkan langsung oleh guru pengampu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.45),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2x2 Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.quiz_outlined,
                    iconColor: const Color(0xFF0D6EFD),
                    iconBgColor: const Color(0xFFE2EFFF),
                    title: 'Total Soal',
                    value: '${hasil.totalSoal}',
                    suffix: 'Butir',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.timer_outlined,
                    iconColor: const Color(0xFF0D6EFD),
                    iconBgColor: const Color(0xFFE2EFFF),
                    title: 'Durasi',
                    value: _formatDurasi(hasil.durasiDetik),
                  ),
                ),
              ],
            ),
            if (showScore) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.check,
                      iconColor: const Color(0xFF0B7B53),
                      iconBgColor: const Color(0xFFD6F0E4),
                      title: 'Benar',
                      value: '${hasil.totalBenar}',
                      suffix: 'Soal',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.close,
                      iconColor: const Color(0xFFD32F2F),
                      iconBgColor: const Color(0xFFFFE5E5),
                      title: 'Salah / Belum',
                      value: '${hasil.totalSalah}',
                      suffix: 'Soal',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Kembali ke Daftar Ujian',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: iconBgColor,
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                    children: suffix != null
                        ? [
                            TextSpan(
                              text: ' $suffix',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ]
                        : [],
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

class CircleGaugePainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  CircleGaugePainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircleGaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.activeColor != activeColor;
}