import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/core/widgets/authenticated_file_preview_page.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/models/task_model.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/services/task_api_service.dart';

class DetailTugasPilganScreen extends StatefulWidget {
  final TaskModel task;

  const DetailTugasPilganScreen({super.key, required this.task});

  @override
  State<DetailTugasPilganScreen> createState() =>
      _DetailTugasPilganScreenState();
}

class _DetailTugasPilganScreenState extends State<DetailTugasPilganScreen> {
  static const Color primary = Color(0xFF4F46E5);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  bool isLoading = true;
  bool isSubmitting = false;
  bool isSubmitted = false;

  String? errorMessage;

  double? score;

  Map<String, dynamic> taskData = {};

  List<Map<String, dynamic>> questions = [];

  // ID soal -> jawaban siswa
  final Map<String, String> answers = {};

  @override
  void initState() {
    super.initState();

    isSubmitted = widget.task.isSubmitted;

    loadDetail();
  }

  // ============================================================
  //  DETAIL TUGAS
  // ============================================================

  Future<void> loadDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await TaskApiService.getPilganDetail(widget.task.id);

      if (!mounted) return;

      final loadedTaskData = Map<String, dynamic>.from(result);

      final rawQuestions = result['soals'];

      final loadedQuestions = rawQuestions is List
          ? rawQuestions
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      // Urutkan soal
      loadedQuestions.sort((a, b) {
        final first = int.tryParse(a['urutan']?.toString() ?? '') ?? 0;

        final second = int.tryParse(b['urutan']?.toString() ?? '') ?? 0;

        return first.compareTo(second);
      });

      // Reset jawaban sebelum mengambil data terbaru
      answers.clear();

      // DATA PENGUMPULAN
      final submission = result['submission'];

      double? loadedScore;

      bool submitted = submission is Map;

      if (submission is Map) {
        final nilai = submission['nilai'];

        if (nilai != null) {
          loadedScore = double.tryParse(nilai.toString());
        }
      }

      // JAWABAN SISWA
      final savedAnswers = result['jawaban_siswa'];

      if (savedAnswers is List) {
        for (final item in savedAnswers) {
          if (item is Map) {
            final questionId = item['soal_id']?.toString();

            final answer = item['jawaban_dipilih']?.toString();

            if (questionId != null && answer != null) {
              answers[questionId] = answer.toLowerCase();
            }
          }
        }
      }

      if (!mounted) return;

      setState(() {
        taskData = loadedTaskData;
        questions = loadedQuestions;
        score = loadedScore;
        isSubmitted = submitted || widget.task.isSubmitted;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // ============================================================
  // MENGAMBIL DATA TUGAS
  // ============================================================

  Map<String, dynamic> get taskInfo {
    final nested = taskData['tugas'];

    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }

    return taskData;
  }

  String getTaskValue(String key, String fallback) {
    final value = taskInfo[key];

    if (value == null || value.toString().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  String get teacherName {
    final direct = taskData['guru'] ?? taskInfo['guru'];

    if (direct != null && direct.toString().isNotEmpty) {
      return direct.toString();
    }

    final pengampu = taskInfo['pengampu_kelas'];

    if (pengampu is Map) {
      final guruMapel = pengampu['guru_mapel'];

      if (guruMapel is Map) {
        final guru = guruMapel['guru'];

        if (guru is Map) {
          final nama = guru['nama_guru'];

          if (nama != null && nama.toString().isNotEmpty) {
            return nama.toString();
          }
        }
      }
    }

    return 'Nama guru belum tersedia';
  }

  // ============================================================
  // FORMAT DEADLINE
  // ============================================================

  String formatDeadline(String value) {
    if (value.isEmpty || value == 'null') {
      return 'Tidak ditentukan';
    }

    try {
      final date = DateTime.parse(value).toLocal();

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];

      return '${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]} ${date.year}, '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  // ============================================================
  // PARSE PILIHAN JAWABAN
  // ============================================================

  Map<String, dynamic> parseChoices(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value.map(
          (key, value) => MapEntry(key.toString().toLowerCase(), value),
        ),
      );
    }

    if (value is String) {
      try {
        final decoded = jsonDecode(value);

        if (decoded is Map) {
          return Map<String, dynamic>.from(
            decoded.map(
              (key, value) => MapEntry(key.toString().toLowerCase(), value),
            ),
          );
        }
      } catch (_) {
        return {};
      }
    }

    return {};
  }

  // ============================================================
  // MEMILIH JAWABAN
  // ============================================================

  void selectAnswer(String questionId, String answer) {
    if (isSubmitted || isSubmitting) return;

    setState(() {
      answers[questionId] = answer.toLowerCase();
    });
  }

  // ============================================================
  // KONFIRMASI PENGUMPULAN
  // ============================================================

  Future<void> confirmSubmit() async {
    if (isSubmitted || isSubmitting) return;

    if (questions.isEmpty) {
      showMessage('Belum ada soal yang tersedia.');
      return;
    }

    final unanswered = questions.where((question) {
      final id = question['id']?.toString() ?? '';

      return !answers.containsKey(id);
    }).length;

    if (unanswered > 0) {
      showMessage('Masih ada $unanswered soal yang belum dijawab.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Kumpulkan Jawaban?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Pastikan seluruh jawaban sudah benar. '
            'Setelah dikumpulkan, jawaban tidak dapat diubah kembali.',
            style: TextStyle(fontSize: 13, height: 1.6, color: textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Periksa Lagi'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Kumpulkan'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await submitAnswers();
    }
  }

  // ============================================================
  // MENGIRIM JAWABAN
  // ============================================================

  Future<void> submitAnswers() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final result = await TaskApiService.submitPilgan(
        id: widget.task.id,
        answers: Map<String, String>.from(answers),
      );

      if (!mounted) return;

      final nilai = result['nilai'];

      setState(() {
        isSubmitted = true;
        isSubmitting = false;

        if (nilai != null) {
          score = double.tryParse(nilai.toString());
        }
      });

      showMessage(
        'Jawaban berhasil dikumpulkan!',
        color: const Color(0xFF059669),
      );

      await loadDetail();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      showMessage(e.toString());
    }
  }

  // ============================================================
  // NOTIFIKASI
  // ============================================================

  void showMessage(String message, {Color color = textDark}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // DEKORASI CARD
  // ============================================================

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          'Detail Tugas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),

        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
        ),
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: primary))
            : errorMessage != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 45, color: textMuted),

            const SizedBox(height: 12),

            const Text(
              'Gagal memuat tugas',
              style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
            ),

            const SizedBox(height: 8),

            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: textMuted),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: loadDetail,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // KONTEN UTAMA
  // ============================================================

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // INFORMASI TUGAS
              _buildTaskInfo(),

              const SizedBox(height: 16),

              // LAMPIRAN
              if (_hasAttachment()) ...[
                _buildAttachment(),
                const SizedBox(height: 18),
              ],

              // INFORMASI NILAI
              if (isSubmitted) ...[
                _buildSubmissionInfo(),
                const SizedBox(height: 20),
              ],

              // HEADER SOAL
              _buildQuestionHeader(),

              const SizedBox(height: 14),

              // DAFTAR SOAL
              if (questions.isEmpty)
                _buildEmptyQuestions()
              else
                ...questions.asMap().entries.map((entry) {
                  return _buildQuestionCard(entry.value, entry.key);
                }),

              const SizedBox(height: 2),

              // TOMBOL PENGUMPULAN
              if (questions.isNotEmpty) ...[
                if (isSubmitted)
                  _buildSubmittedNotice()
                else
                  _buildSubmitButton(),
              ],

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BADGE INFORMASI
  // ============================================================

  Widget _buildInfoBadge({
    IconData? icon,
    required String text,
    required Color foreground,
    required Color background,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMASI TUGAS
  // ============================================================

  Widget _buildTaskInfo() {
    final title = getTaskValue('judul', widget.task.title);

    final description = getTaskValue('deskripsi', widget.task.description);

    final deadline = getTaskValue('deadline', widget.task.deadline);

    final teacher = teacherName;

    return Container(
      padding: const EdgeInsets.all(21),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BADGE
          Wrap(
            spacing: 4,
            runSpacing: 3,
            children: [
              _buildInfoBadge(
                text: 'Deadline: ${formatDeadline(deadline)}',
                foreground: const Color(0xFF0369A1),
                background: const Color(0xFFF0F9FF),
                border: const Color(0xFFE0F2FE),
              ),

              _buildInfoBadge(
                icon: Icons.format_list_bulleted,
                text: 'Pilihan Ganda',
                foreground: const Color(0xFF4338CA),
                background: const Color(0xFFEEF2FF),
                border: const Color(0xFFE0E7FF),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // JUDUL
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              height: 1.3,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 19),

          // GURU PENGAMPU
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 21,
                  color: Color(0xFF4F46E5),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Guru Pengampu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      teacher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          const SizedBox(height: 17),

          // DESKRIPSI
          const Text(
            'DESKRIPSI TUGAS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: Color(0xFF94A3B8),
            ),
          ),

          const SizedBox(height: 9),

          Text(
            description.isEmpty ? 'Tidak ada deskripsi tugas.' : description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.7,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAMPIRAN GURU
  // ============================================================

  bool _hasAttachment() {
    final file = taskInfo['file_lampiran'] ?? taskData['file_lampiran'];

    return file != null && file.toString().isNotEmpty;
  }

  Widget _buildAttachment() {
    final file = (taskInfo['file_lampiran'] ?? taskData['file_lampiran'])
        .toString();

    final fileName = file.split('/').last;
    final rawUrl = (taskInfo['file_url'] ?? taskData['file_url'])?.toString();
    final taskId = int.tryParse(widget.task.id) ?? 0;
    final fileUrl = rawUrl != null && rawUrl.trim().isNotEmpty
        ? ApiConfig.resolveUrl(rawUrl)
        : (taskId > 0 ? ApiConfig.fileTugasEndpoint(taskId) : '');

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BERKAS LAMPIRAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: Color(0xFF94A3B8),
            ),
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: fileUrl.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AuthenticatedFilePreviewPage(
                          fileName: fileName.isNotEmpty
                              ? fileName
                              : 'Lampiran Tugas',
                          fileUrl: fileUrl,
                        ),
                      ),
                    );
                  },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Color(0xFFE11D48),
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lampiran Tugas',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Icon(
                    Icons.visibility_outlined,
                    color: primary,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMASI NILAI
  // ============================================================

  Widget _buildSubmissionInfo() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF059669),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tugas Selesai Dikerjakan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Jawaban berhasil dikumpulkan dan dinilai otomatis.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          // NILAI AKHIR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E7FF)),
            ),
            child: Column(
              children: [
                const Text(
                  'Nilai Akhir',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),

                const SizedBox(height: 4),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: score?.toStringAsFixed(2) ?? '-',
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4338CA),
                        ),
                      ),

                      const TextSpan(
                        text: ' / 100',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF818CF8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          // JAWABAN TERKUNCI
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFFD1FAE5)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 16, color: Color(0xFF059669)),

                SizedBox(width: 9),

                Expanded(
                  child: Text(
                    'Jawaban tugas sudah dikunci. Kamu tidak dapat mengubah atau mengerjakan ulang tugas ini setelah dikumpulkan.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.6,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER SOAL
  // ============================================================

  Widget _buildQuestionHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Soal Pilihan Ganda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                '${questions.length} soal tersedia. Pilih satu jawaban yang paling tepat.',
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isSubmitted
                ? const Color(0xFFECFDF5)
                : const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSubmitted
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFE0F2FE),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSubmitted ? Icons.check_circle : Icons.edit_note,
                size: 13,
                color: isSubmitted
                    ? const Color(0xFF047857)
                    : const Color(0xFF0369A1),
              ),

              const SizedBox(width: 5),

              Text(
                isSubmitted ? 'Sudah Dikumpulkan' : 'Belum Dikerjakan',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isSubmitted
                      ? const Color(0xFF047857)
                      : const Color(0xFF0369A1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARD SOAL
  // ============================================================

  Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
    final questionId = question['id']?.toString() ?? '';

    final questionText = question['pertanyaan']?.toString() ?? '';

    final choices = parseChoices(question['pilihan']);

    final selected = answers[questionId];

    final imageUrl = question['gambar_url']?.toString();

    final bobot = question['bobot'] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(19),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NOMOR DAN BOBOT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Soal ${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ),

              Text(
                'Bobot: $bobot',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // PERTANYAAN
          Text(
            questionText,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),

          // GAMBAR SOAL
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            const SizedBox(height: 13),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gambar Soal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 9),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      ApiConfig.publicAssetUrl(imageUrl),
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Gambar soal tidak dapat dimuat.',
                            style: TextStyle(fontSize: 11, color: textMuted),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // PILIHAN JAWABAN
          if (choices.isEmpty)
            const Text(
              'Pilihan jawaban belum tersedia.',
              style: TextStyle(fontSize: 12, color: Colors.red),
            )
          else
            ...['a', 'b', 'c', 'd', 'e']
                .where((key) {
                  final value = choices[key];

                  return value != null && value.toString().isNotEmpty;
                })
                .map((key) {
                  return _buildChoice(
                    questionId: questionId,
                    keyAnswer: key,
                    text: choices[key].toString(),
                    isSelected: selected == key,
                  );
                }),
        ],
      ),
    );
  }

  // ============================================================
  // PILIHAN JAWABAN
  // ============================================================

  Widget _buildChoice({
    required String questionId,
    required String keyAnswer,
    required String text,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: isSubmitted || isSubmitting
          ? null
          : () => selectAnswer(questionId, keyAnswer),
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF38BDF8)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                keyAnswer.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                ),
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            if (isSelected) ...[
              const SizedBox(width: 7),

              const Icon(
                Icons.check_circle,
                size: 18,
                color: Color(0xFF0284C7),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SOAL KOSONG
  // ============================================================

  Widget _buildEmptyQuestions() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: cardDecoration(),
      child: const Column(
        children: [
          Icon(Icons.quiz_outlined, size: 45, color: Color(0xFF94A3B8)),

          SizedBox(height: 12),

          Text(
            'Belum ada soal tersedia',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Guru belum menambahkan soal untuk tugas ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOMBOL KUMPULKAN
  // ============================================================

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: cardDecoration(),
      child: Column(
        children: [
          // INFORMASI
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFFE0F2FE)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 17, color: Color(0xFF0284C7)),

                SizedBox(width: 9),

                Expanded(
                  child: Text(
                    'Periksa kembali seluruh jawaban sebelum mengumpulkan. Setelah dikirim, jawaban tidak dapat diubah atau dikerjakan ulang. Nilai akan dihitung secara otomatis oleh sistem.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.6,
                      color: Color(0xFF075985),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // TOMBOL KIRIM
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : confirmSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF818CF8),
                    elevation: 2,
                    shadowColor: primary.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Kirim Jawaban',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUDAH DIKUMPULKAN
  // ============================================================

  Widget _buildSubmittedNotice() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 17, color: Color(0xFF059669)),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Kamu sudah menyelesaikan tugas ini. Jawaban tidak dapat diubah kembali.',
              style: TextStyle(
                fontSize: 11,
                height: 1.6,
                color: Color(0xFF065F46),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
