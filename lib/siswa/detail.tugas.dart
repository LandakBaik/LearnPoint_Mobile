import 'dart:async';
import 'package:flutter/material.dart';

class TugasDetailPage extends StatefulWidget {
  const TugasDetailPage({super.key});

  @override
  State<TugasDetailPage> createState() => _TugasDetailPageState();
}

class _TugasDetailPageState extends State<TugasDetailPage> {
  // Ubah tanggal ini sesuai deadline tugas
  DateTime deadline = DateTime(2026, 10, 5, 23, 59);

  Timer? timer;
  Duration remaining = Duration.zero;

  bool get isLate => DateTime.now().isAfter(deadline);

  @override
  void initState() {
    super.initState();

    updateCountdown();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => updateCountdown(),
    );
  }

  void updateCountdown() {
    final now = DateTime.now();

    if (now.isBefore(deadline)) {
      setState(() {
        remaining = deadline.difference(now);
      });
    } else {
      setState(() {
        remaining = Duration.zero;
      });
    }
  }

  String twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  String countdownText() {
    if (isLate) {
      return 'Terlambat';
    }

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    if (days > 0) {
      return '$days Hari ${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }

    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFEC1747);
    const background = Color(0xFFF7F9FC);
    const textDark = Color(0xFF202733);
    const textGrey = Color(0xFF8992A3);

    return Scaffold(
      backgroundColor: background,

      // =========================
      // BOTTOM BUTTON
      // =========================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLate ? null : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isLate
                        ? 'Tugas Terlambat'
                        : 'Kirim Tugas Sekarang  →',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 7),

              Text(
                isLate
                    ? 'Pengumpulan sudah melewati tenggat'
                    : 'Simpan sebagai draft?',
                style: const TextStyle(
                  fontSize: 11,
                  color: textGrey,
                ),
              ),
            ],
          ),
        ),
      ),

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: textDark,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 0,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengumpulan Tugas',
              style: TextStyle(
                color: textDark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Pengumpulan Tugas • Bahasa...',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: textDark,
            ),
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================================================
            // CARD INFORMASI TUGAS
            // =========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // STATUS
                  Row(
                    children: [
                      statusBadge(
                        isLate ? 'TERLAMBAT' : 'AKTIF',
                        isLate ? const Color(0xFFFFE8ED) : const Color(0xFFFFE9EF),
                        primary,
                      ),

                      const SizedBox(width: 7),

                      const Text(
                        '•',
                        style: TextStyle(
                          color: textGrey,
                        ),
                      ),

                      const SizedBox(width: 7),

                      const Text(
                        'Bahasa Indonesia',
                        style: TextStyle(
                          fontSize: 10,
                          color: textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const Spacer(),

                      statusBadge(
                        isLate ? 'TERLAMBAT' : 'MENDESAK',
                        isLate
                            ? const Color(0xFFFFE8ED)
                            : const Color(0xFFFFE8ED),
                        primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // JUDUL
                  const Text(
                    'Latihan Soal: Penggunaan Python...',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 13),

                  // DEADLINE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE7ED),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            size: 15,
                            color: primary,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Batas waktu pengumpulan',
                              style: TextStyle(
                                fontSize: 9,
                                color: textGrey,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              '05 Okt 2026, 23:59 WIB',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isLate
                                    ? primary
                                    : primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 17),

                  const Text(
                    'Petunjuk Pengerjaan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  instruction(
                    '1.',
                    'Buat program Python sederhana sesuai instruksi yang diberikan.',
                  ),

                  instruction(
                    '2.',
                    'Tuliskan source code dengan rapi dan mudah dipahami.',
                  ),

                  instruction(
                    '3.',
                    'Simpan program dalam format file Python (.py) kemudian upload.',
                  ),

                  const SizedBox(height: 12),

                  // FILE MATERI
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9FF),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: const Color(0xFFE2EBF8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE7ED),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'PDF',
                              style: TextStyle(
                                color: primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modul_Soal_Penggunaan_Python.pdf',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: textDark,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '2.4 MB • PDF',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.download_rounded,
                          size: 18,
                          color: Color(0xFF5790E8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // =========================================================
            // FILE YANG SUDAH DIUPLOAD
            // =========================================================
            sectionCard(
              title: 'UNGGAH BERKAS JAWABAN',
              icon: Icons.upload_file_rounded,
              child: Column(
                children: [

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 37,
                          height: 37,
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'PY',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 9),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jawaban_Penggunaan_Python.py',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              SizedBox(height: 3),

                              Text(
                                '2.8 KB  •  Terupload',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF22A879),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.close_rounded,
                          size: 17,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // PROGRESS
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE6E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF20B58A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  // TAMBAH FILE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFD9E0E8),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: Color(0xFF9AA4B2),
                          size: 22,
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Tambahkan atau pilih file',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7C8796),
                          ),
                        ),

                        const SizedBox(height: 2),

                        const Text(
                          'PDF, DOCX, PPTX • Maks. 10 MB',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFFADB5C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // =========================================================
            // CATATAN
            // =========================================================
            sectionCard(
              title: 'CATATAN UNTUK GURU',
              icon: Icons.edit_note_rounded,
              child: Container(
                width: double.infinity,
                height: 78,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Text(
                  'Tuliskan catatan atau pesan untuk guru...',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFADB5C0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =========================================================
            // PERINGATAN
            // =========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: const Color(0xFFF8E8A7),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFE5A900),
                    size: 17,
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      isLate
                          ? 'Tugas ini sudah melewati batas waktu pengumpulan.'
                          : 'Pastikan file yang diunggah sudah benar sebelum mengirim tugas. Setelah dikirim, pengumpulan tidak dapat diubah.',
                      style: const TextStyle(
                        fontSize: 9,
                        height: 1.4,
                        color: Color(0xFF75651F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =========================================================
            // COUNTDOWN
            // =========================================================
            Center(
              child: Column(
                children: [
                  Text(
                    isLate
                        ? 'STATUS PENGUMPULAN'
                        : 'WAKTU TERSISA',
                    style: const TextStyle(
                      fontSize: 9,
                      color: textGrey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    countdownText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isLate ? primary : textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // STATUS BADGE
  // ===============================================================
  Widget statusBadge(
    String text,
    Color background,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }

  // ===============================================================
  // INSTRUCTION
  // ===============================================================
  Widget instruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF687386),
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                height: 1.35,
                color: Color(0xFF687386),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SECTION CARD
  // ===============================================================
  Widget sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: const Color(0xFFEC1747),
              ),

              const SizedBox(width: 7),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF303846),
                ),
              ),

              const Spacer(),

              if (title == 'UNGGAH BERKAS JAWABAN')
                const Text(
                  '1 file',
                  style: TextStyle(
                    fontSize: 8,
                    color: Color(0xFF9AA4B2),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }
}