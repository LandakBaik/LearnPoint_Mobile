
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:learnpoint_mobile/features/siswa/tugas/models/task_model.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/services/task_api_service.dart';

class DetailTugasPilganScreen extends StatefulWidget {
  final TaskModel task;

  const DetailTugasPilganScreen({
    super.key,
    required this.task,
  });

  @override
  State<DetailTugasPilganScreen> createState() =>
      _DetailTugasPilganScreenState();
}

class _DetailTugasPilganScreenState
    extends State<DetailTugasPilganScreen> {
  static const Color primary = Color(0xFF2864E8);
  static const Color background = Color(0xFFF6F8FC);
  static const Color textDark = Color(0xFF202D43);
  static const Color textMuted = Color(0xFF71809A);

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

  // MEMUAT DETAIL TUGAS

  Future<void> loadDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await TaskApiService.getPilganDetail(
        widget.task.id,
      );

      if (!mounted) return;

      final rawQuestions = result['soals'];

      final loadedQuestions = rawQuestions is List
          ? rawQuestions
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
          : <Map<String, dynamic>>[];

      loadedQuestions.sort((a, b) {
        final first = int.tryParse(a['urutan'].toString()) ?? 0;
        final second = int.tryParse(b['urutan'].toString()) ?? 0;
        return first.compareTo(second);
      });

      final submission = result['submission'];

      if (submission is Map) {
        final nilai = submission['nilai'];

        if (nilai != null) {
          score = double.tryParse(nilai.toString());
        }

        isSubmitted = true;
      }

      // Memuat jawaban siswa jika sudah dikumpulkan.
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
        taskData = result;
        questions = loadedQuestions;
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

  // FORMAT DEADLINE

  String formatDeadline(String value) {
    if (value.isEmpty) return 'Tidak ditentukan';

    try {
      final date = DateTime.parse(value).toLocal();

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr',
        'Mei', 'Jun', 'Jul', 'Agu',
        'Sep', 'Okt', 'Nov', 'Des',
      ];

      return '${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]} ${date.year}, '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  // FORMAT PILIHAN

  Map<String, dynamic> getChoices(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is String) {
      try {
        final decoded = Uri.decodeComponent(value);
        return {};
      } catch (_) {
        return {};
      }
    }

    return {};
  }

  // MEMILIH JAWABAN

  void selectAnswer(String questionId, String answer) {
    if (isSubmitted || isSubmitting) return;

    setState(() {
      answers[questionId] = answer.toLowerCase();
    });
  }

  // KONFIRMASI PENGUMPULAN

  Future<void> confirmSubmit() async {
    if (isSubmitted || isSubmitting) return;

    if (questions.isEmpty) {
      showMessage('Belum ada soal yang tersedia.');
      return;
    }

    if (answers.length < questions.length) {
      final unanswered = questions.where((question) {
        final id = question['id'].toString();
        return !answers.containsKey(id);
      }).length;

      showMessage(
        'Masih ada $unanswered soal yang belum dijawab.',
      );
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
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Pastikan seluruh jawaban sudah benar. '
            'Setelah dikumpulkan, jawaban tidak dapat diubah kembali.',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: textMuted,
            ),
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

  // MENGIRIM JAWABAN

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
        color: Colors.green,
      );

      // Ambil ulang detail untuk memastikan status dan nilai terbaru.
      await loadDetail();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      showMessage(e.toString());
    }
  }

  void showMessage(
    String message, {
    Color color = textDark,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // DEKORASI KARTU

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(
        color: const Color(0xFFE1E6EF),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // BUILD HALAMAN

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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Color(0xFFF1F5F9),
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primary),
              )
            : errorMessage != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  // ERROR

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 45,
              color: textMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat tugas',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: textMuted,
              ),
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

  // KONTEN

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTaskInfo(),
              const SizedBox(height: 18),
              _buildQuestionHeader(),
              const SizedBox(height: 12),

              if (questions.isEmpty)
                _buildEmptyQuestions()
              else
                ...questions.asMap().entries.map((entry) {
                  return _buildQuestionCard(
                    entry.value,
                    entry.key,
                  );
                }),

              if (questions.isNotEmpty) ...[
                const SizedBox(height: 8),
                if (isSubmitted)
                  _buildSubmittedNotice()
                else
                  _buildSubmitButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // INFORMASI TUGAS

  Widget _buildTaskInfo() {
    final title = taskData['judul']?.toString() ??
        widget.task.title;

    final description = taskData['deskripsi']?.toString() ??
        widget.task.description;

    final deadline = taskData['deadline']?.toString() ??
        widget.task.deadline;

    final subject = taskData['mapel']?.toString() ??
        widget.task.subject;

    final teacher = taskData['guru']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 14,
                  color: primary,
                ),
                SizedBox(width: 6),
                Text(
                  'Pilihan Ganda',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Deadline: ${formatDeadline(deadline)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (subject.isNotEmpty)
            Text(
              subject,
              style: const TextStyle(
                fontSize: 12,
                color: primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (teacher.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Guru: $teacher',
              style: const TextStyle(
                fontSize: 11,
                color: textMuted,
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(color: Color(0xFFF1F5F9)),
          ),
          const Text(
            'DESKRIPSI TUGAS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description.isEmpty
                ? 'Tidak ada deskripsi tugas.'
                : description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.6,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // HEADER SOAL

  Widget _buildQuestionHeader() {
    final answered = questions.where((question) {
      return answers.containsKey(question['id'].toString());
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Soal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${questions.length} soal tersedia',
                  style: const TextStyle(
                    fontSize: 11,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$answered/${questions.length}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  // KARTU SOAL

  Widget _buildQuestionCard(
    Map<String, dynamic> question,
    int index,
  ) {
    final questionId = question['id'].toString();

    final questionText =
        question['pertanyaan']?.toString() ?? '';

    final choices = _parseChoices(question['pilihan']);

    final selected = answers[questionId];

    final imageUrl = question['gambar_url']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'SOAL ${index + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ),
              Text(
                '${question['bobot'] ?? 0} poin',
                style: const TextStyle(
                  fontSize: 10,
                  color: textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            questionText,
            style: const TextStyle(
              fontSize: 13,
              height: 1.7,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Text(
                    'Gambar soal tidak dapat dimuat.',
                    style: TextStyle(
                      fontSize: 11,
                      color: textMuted,
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 15),
          if (choices.isEmpty)
            const Text(
              'Pilihan jawaban belum tersedia.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            )
          else
            ...['a', 'b', 'c', 'd', 'e']
                .where((key) =>
                    choices[key] != null &&
                    choices[key].toString().isNotEmpty)
                .map((key) {
              final isSelected = selected == key;

              return _buildChoice(
                questionId: questionId,
                keyAnswer: key,
                text: choices[key].toString(),
                isSelected: isSelected,
              );
            }),
        ],
      ),
    );
  }

  // NORMALISASI PILIHAN

  Map<String, dynamic> _parseChoices(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value.map(
          (key, value) => MapEntry(
            key.toString().toLowerCase(),
            value,
          ),
        ),
      );
    }

    // Jika pilihan berupa JSON string.
    if (value is String) {
      try {
        final decoded = Uri.decodeComponent(value);
        return {};
      } catch (_) {
        return {};
      }
    }

    return {};
  }

  // PILIHAN JAWABAN

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
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEFF6FF)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isSelected
                ? primary
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 29,
              height: 29,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? primary
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Text(
                keyAnswer.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : textMuted,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: isSelected ? primary : textDark,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 19,
                color: primary,
              ),
          ],
        ),
      ),
    );
  }

  // SOAL KOSONG

  Widget _buildEmptyQuestions() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: cardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 42,
            color: textMuted,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada soal tersedia',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Silakan hubungi guru untuk informasi lebih lanjut.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // TOMBOL KUMPULKAN

  Widget _buildSubmitButton() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: const Color(0xFFFDE68A),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Color(0xFFD97706),
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Pastikan semua soal telah dijawab sebelum mengumpulkan tugas.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isSubmitting ? null : confirmSubmit,
            icon: isSubmitting
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 17),
            label: Text(
              isSubmitting
                  ? 'Mengirim Jawaban...'
                  : 'Kumpulkan Jawaban',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF93B4F5),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // BERHASIL DIKUMPULKAN

  Widget _buildSubmittedNotice() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFD1FAE5),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            size: 32,
            color: Color(0xFF059669),
          ),
          const SizedBox(height: 9),
          const Text(
            'Tugas Berhasil Dikumpulkan!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF047857),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Jawaban kamu sudah tersimpan.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF065F46),
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(
                children: [
                  const Text(
                    'NILAI KAMU',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    score!.toStringAsFixed(
                      score! % 1 == 0 ? 0 : 2,
                    ),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
