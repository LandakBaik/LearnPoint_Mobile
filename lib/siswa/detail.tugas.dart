import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DetailTugasPage extends StatefulWidget {
  const DetailTugasPage({super.key});

  @override
  State<DetailTugasPage> createState() => _DetailTugasPageState();
}

class _DetailTugasPageState extends State<DetailTugasPage> {
  static const Color primary = Color(0xFF0369A1);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  PlatformFile? selectedFile;
  bool isSubmitting = false;

  Future<void> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'zip', 'rar'],
    );

    if (!mounted || result.isEmpty) return;

    final file = result.first;
    final fileSize = await file.length();

    if (!mounted) return;

    if (fileSize != null && fileSize > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ukuran file maksimal 5 MB.')),
      );
      return;
    }

    setState(() {
      selectedFile = file;
    });
  }

  Future<void> submitTask() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih file jawaban terlebih dahulu.')),
      );
      return;
    }

    // Hubungkan proses ini ke API/backend pengumpulan tugas.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File dipilih. Hubungkan API untuk mengirim tugas.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Detail Tugas',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBreadcrumb(),
                  const SizedBox(height: 18),
                  _buildTaskCard(),
                  const SizedBox(height: 16),
                  _buildSubmissionCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 7,
      runSpacing: 8,
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 15, color: textMuted),
                SizedBox(width: 7),
                Text(
                  'Kembali',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCBD5E1)),
        const Text(
          'Tugas',
          style: TextStyle(
            fontSize: 12,
            color: textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFE0F2FE)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_month_outlined, size: 15, color: primary),
                SizedBox(width: 7),
                Text(
                  'Deadline: 25 Okt 2024, 23:59',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Tugas 1: Studi Kasus Penyederhanaan Eksponensial Terapan',
            style: TextStyle(
              fontSize: 21,
              height: 1.4,
              fontWeight: FontWeight.w800,
              color: textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 15),
          _sectionTitle('DESKRIPSI TUGAS'),
          const SizedBox(height: 9),
          const Text(
            'Silakan pelajari materi penyederhanaan bentuk '
            'Pada tugas mandiri ini, peserta didik diharapkan mampu '
            'menerapkan kaidah eksponen untuk memecahkan estimasi '
            'pertumbuhan populasi bakteri yang diberikan pada berkas soal.',
            style: TextStyle(fontSize: 13, height: 1.8, color: textMuted),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 15),
          _sectionTitle('BERKAS LAMPIRAN'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: Color(0xFFE11D48),
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lampiran Tugas',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Modul_Studi_Kasus_Eksponensial_VII.pdf',
                        style: TextStyle(fontSize: 10, color: textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Tambahkan aksi unduh atau buka PDF di sini.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Hubungkan tombol ini ke URL lampiran PDF.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, color: primary),
                  tooltip: 'Unduh berkas',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: Color(0xFF059669),
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengumpulan Tugas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Kirimkan hasil pekerjaan kamu',
                      style: TextStyle(fontSize: 11, color: textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFFFE4E6)),
                ),
                child: const Text(
                  'Belum Terkirim',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(color: Color(0xFFF1F5F9)),
          ),
          _sectionTitle('UNGGAH BERKAS JAWABAN'),
          const SizedBox(height: 12),
          InkWell(
            onTap: pickFile,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: selectedFile == null
                      ? const Color(0xFFCBD5E1)
                      : primary,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 47,
                    height: 47,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: primary,
                      size: 25,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    selectedFile == null
                        ? 'Klik untuk memilih file'
                        : 'File berhasil dipilih',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Format PDF, DOC, DOCX',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Ukuran maksimal 5 MB',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE0F2FE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selectedFile == null
                              ? Icons.insert_drive_file_outlined
                              : Icons.check_circle_outline,
                          size: 15,
                          color: primary,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            selectedFile?.name ?? 'Belum ada file dipilih',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0F2FE)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: primary, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pastikan berkas jawaban sudah benar sebelum '
                    'dikirim. Format yang didukung adalah PDF, DOC, '
                    'DOCX, ZIP, dan RAR.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.7,
                      color: Color(0xFF075985),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : submitTask,
              icon: const Icon(Icons.send_rounded, size: 17),
              label: const Text(
                'Kirim Tugas Sekarang',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF94A3B8),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DetailTugasPage(),
  ));
}