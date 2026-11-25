import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/core/widgets/authenticated_file_preview_page.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/models/task_model.dart';

class DetailTugasPage extends StatefulWidget {
  final TaskModel task;

  const DetailTugasPage({super.key, required this.task});

  @override
  State<DetailTugasPage> createState() => _DetailTugasPageState();
}

class _DetailTugasPageState extends State<DetailTugasPage> {
  static const Color primary = Color(0xFF4F46E5);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  static const int maxFileSize = 10 * 1024 * 1024;

  static const List<String> allowedExtensions = [
    'pdf',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];

  bool isLoading = true;
  bool isSubmitting = false;
  bool isSubmitted = false;
  bool isGraded = false;

  String? errorMessage;

  double? score;

  Map<String, dynamic> taskData = {};

  PlatformFile? selectedFile;
  int? selectedFileSize;

  String? submittedFileName;
  String? submittedFileUrl;
  String? submittedAt;

  String? attachmentName;
  String? attachmentUrl;

  @override
  void initState() {
    super.initState();

    isSubmitted = widget.task.isSubmitted;
    loadDetail();
  }

  // ============================================================
  // DETAIL TUGAS
  // ============================================================

  Future<void> loadDetail() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiConfig.dio.get(
        '/siswa/tugas/${widget.task.id}',
      );

      final responseBody = response.data;

      if (responseBody is! Map) {
        throw Exception('Format respons server tidak valid.');
      }

      final rawData = responseBody['data'];

      if (rawData is! Map) {
        throw Exception('Data tugas tidak ditemukan.');
      }

      final result = Map<String, dynamic>.from(rawData);

      final submission = result['submission'];

      final lampiran = result['file_lampiran'];
      final lampiranUrl = result['file_url'] ?? result['file_lampiran_url'];

      String? newSubmittedFileName;
      String? newSubmittedFileUrl;
      String? newSubmittedAt;

      double? newScore;

      bool newIsSubmitted = false;
      bool newIsGraded = false;

      if (submission is Map) {
        final fileUrl = submission['file_jawaban_url']?.toString();
        final filePath = submission['file_jawaban']?.toString();
        final fileName = submission['nama_file']?.toString();

        if (fileUrl != null && fileUrl.isNotEmpty) {
          newSubmittedFileUrl = ApiConfig.resolveUrl(fileUrl);
          final parsedFromUrl = getFileNameFromUrl(fileUrl);
          if (fileName != null && fileName.isNotEmpty) {
            newSubmittedFileName = fileName;
          } else if (filePath != null && filePath.isNotEmpty) {
            newSubmittedFileName = getFileNameFromUrl(filePath);
          } else if (RegExp(r'^\d+$').hasMatch(parsedFromUrl)) {
            newSubmittedFileName = 'Berkas Jawaban';
          } else {
            newSubmittedFileName = parsedFromUrl;
          }
          newIsSubmitted = true;
        } else if (filePath != null && filePath.isNotEmpty) {
          newSubmittedFileName = getFileNameFromUrl(filePath);
          newIsSubmitted = true;
        } else if (fileName != null && fileName.isNotEmpty) {
          newSubmittedFileName = fileName;
          newIsSubmitted = true;
        }

        newSubmittedAt = submission['submitted_at']?.toString();
        final nilai = submission['nilai'];

        if (nilai != null) {
          newScore = double.tryParse(nilai.toString());
          newIsGraded = newScore != null;
        }
      }

      if (!mounted) return;

      final resolvedAttachmentUrl =
          lampiranUrl != null && lampiranUrl.toString().trim().isNotEmpty
          ? ApiConfig.resolveUrl(lampiranUrl.toString())
          : (lampiran != null && lampiran.toString().trim().isNotEmpty
                ? ApiConfig.fileTugasEndpoint(
                    int.tryParse(widget.task.id) ?? 0,
                  )
                : null);

      setState(() {
        taskData = result;

        submittedFileName = newSubmittedFileName;
        submittedFileUrl = newSubmittedFileUrl;
        submittedAt = newSubmittedAt;

        score = newScore;
        isGraded = newIsGraded;

        isSubmitted = newIsSubmitted || widget.task.isSubmitted;

        attachmentUrl = resolvedAttachmentUrl;

        if (lampiran != null && lampiran.toString().isNotEmpty) {
          attachmentName = getFileNameFromUrl(lampiran.toString());
        } else if (attachmentUrl != null && attachmentUrl!.isNotEmpty) {
          final parsed = getFileNameFromUrl(attachmentUrl!);
          attachmentName = RegExp(r'^\d+$').hasMatch(parsed)
              ? 'Berkas Lampiran'
              : parsed;
        }

        isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.response?.data is Map
            ? e.response?.data['message']?.toString()
            : 'Gagal memuat detail tugas.';

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }
  // ============================================================
  // GETTER DATA TUGAS
  // ============================================================

  Map<String, dynamic> get taskInfo {
    final tugas = taskData['tugas'];

    if (tugas is Map) {
      return Map<String, dynamic>.from(tugas);
    }

    return taskData;
  }

  dynamic getTaskValue(String key, [dynamic fallback]) {
    return taskInfo[key] ?? fallback;
  }

  String get teacherName {
    final directGuru = taskData['guru'] ?? taskInfo['guru'];

    if (directGuru is String && directGuru.trim().isNotEmpty) {
      return directGuru;
    }
    if (directGuru is Map) {
      final name =
          directGuru['nama'] ?? directGuru['nama_guru'] ?? directGuru['name'];

      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }
    final pengampu = taskInfo['pengampu_kelas'];

    if (pengampu is Map) {
      final guruMapel = pengampu['guru_mapel'];

      if (guruMapel is Map) {
        final guru = guruMapel['guru'];

        if (guru is Map) {
          final name = guru['nama'] ?? guru['nama_guru'] ?? guru['name'];

          if (name != null && name.toString().trim().isNotEmpty) {
            return name.toString();
          }
        }
      }
    }

    return 'Nama guru belum tersedia';
  }
  // ============================================================
  // FORMAT TANGGAL DAN FILE
  // ============================================================

  String formatDeadline(String value) {
    if (value.isEmpty) return 'Tidak ditentukan';

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

      final day = date.day.toString().padLeft(2, '0');
      final month = months[date.month - 1];
      final year = date.year;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day $month $year, $hour:$minute';
    } catch (_) {
      return value;
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String getExtension(String fileName) {
    final parts = fileName.split('.');

    if (parts.length < 2) return '';

    return parts.last.toLowerCase();
  }

  String getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = Uri.decodeComponent(uri.path);

      return path.split('/').last;
    } catch (_) {
      return 'jawaban_tugas';
    }
  }

  // ============================================================
  // PILIH FILE
  // ============================================================

  Future<void> pickFile() async {
    if (isGraded || isSubmitting) return;

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (!mounted || result.isEmpty) {
        return;
      }

      final file = result.first;

      // Ambil ukuran file (kompatibel dengan versi 12 dan 13)
      final fileSize = (await file.length()) ?? 0;

      if (fileSize == 0) {
        showMessage(
          'File tidak dapat dibaca. Silakan pilih ulang.',
          color: Colors.red,
        );
        return;
      }

      if (fileSize > maxFileSize) {
        showMessage('Ukuran file maksimal 10 MB.', color: Colors.red);
        return;
      }

      setState(() {
        selectedFile = file;
        selectedFileSize = fileSize;
      });
    } catch (e) {
      showMessage('Gagal memilih file: $e');
    }
  }
  // ============================================================
  // HAPUS FILE TERPILIH
  // ============================================================

  void removeSelectedFile() {
    if (isSubmitting) return;

    setState(() {
      selectedFile = null;
      selectedFileSize = null;
    });
  }

  // ============================================================
  // PREVIEW FILE
  // ============================================================

  Future<void> showFilePreviewModal({
    required String fileName,
    String? fileUrl,
    PlatformFile? localFile,
  }) async {
    final extension = getExtension(fileName);

    if (localFile != null && !allowedExtensions.contains(extension)) {
      showMessage('Format file tidak didukung.');
      return;
    }

    Uint8List? fileBytes;

    if (localFile != null) {
      try {
        fileBytes = await localFile.readAsBytes();

        if (fileBytes.isEmpty) {
          showMessage('File tidak memiliki isi.');
          return;
        }
      } catch (e) {
        showMessage('Gagal membaca file: $e');
        return;
      }
    }

    if (localFile == null && (fileUrl == null || fileUrl.isEmpty)) {
      showMessage('Lokasi file tidak ditemukan.');
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthenticatedFilePreviewPage(
          fileName: fileName,
          fileUrl: fileUrl,
          fileBytes: fileBytes,
          extensionHint: extension.isNotEmpty ? extension : null,
        ),
      ),
    );
  }

  // ============================================================
  // KUMPULKAN TUGAS / SIMPAN REVISI
  // ============================================================

  Future<void> submitTask() async {
    final file = selectedFile;

    if (file == null || isSubmitting || isGraded) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      // MEMBACA FILE MENJADI BYTES
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('File yang dipilih kosong.');
      }

      if (bytes.length > maxFileSize) {
        throw Exception('Ukuran file maksimal 10 MB.');
      }

      // MEMBUAT MULTIPART FILE DARI BYTES
      final multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);

      // MEMBUAT FORM DATA
      final formData = FormData.fromMap({'file_jawaban': multipartFile});

      final response = await ApiConfig.dio.post(
        '/siswa/tugas/${widget.task.id}/kumpulkan',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isSubmitted = true;
          submittedFileName = file.name;
          selectedFile = null;
          selectedFileSize = null;
        });

        showMessage('Tugas berhasil dikumpulkan!', color: Colors.green);

        await loadDetail();
      } else {
        showMessage('Tugas gagal dikumpulkan.');
      }
    } on DioException catch (e) {
      if (!mounted) return;

      String message = 'Gagal mengirim tugas.';

      final responseData = e.response?.data;

      if (responseData is Map) {
        message = responseData['message']?.toString() ?? message;

        final errors = responseData['errors'];

        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;

          if (firstError is List && firstError.isNotEmpty) {
            message = firstError.first.toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        message = 'Koneksi timeout. Silakan coba lagi.';
      }

      showMessage(message);
    } catch (e) {
      if (!mounted) return;

      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // NOTIFIKASI
  // ============================================================

  void showMessage(String message, {Color color = textDark}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // DECORATION CARD
  // ============================================================

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.025),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Color fileColor(String fileName) {
    final ext = getExtension(fileName);

    if (ext == 'pdf') {
      return const Color(0xFFE11D48);
    }

    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      return const Color(0xFF0284C7);
    }

    return primary;
  }

  IconData fileIcon(String fileName) {
    final ext = getExtension(fileName);

    if (ext == 'pdf') {
      return Icons.picture_as_pdf_rounded;
    }

    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      return Icons.image_rounded;
    }

    return Icons.description_rounded;
  }

  Widget fileIconBox(String fileName, {double size = 46}) {
    final color = fileColor(fileName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(fileIcon(fileName), color: color, size: size * 0.52),
    );
  }

  Widget sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget statusBadge() {
    final Color color;
    final Color fill;
    final String label;

    if (isGraded) {
      color = const Color(0xFF059669);
      fill = const Color(0xFFECFDF5);
      label = 'Sudah Dinilai';
    } else if (isSubmitted) {
      color = const Color(0xFF0284C7);
      fill = const Color(0xFFF0F9FF);
      label = 'Sudah Terkirim';
    } else {
      color = const Color(0xFFE11D48);
      fill = const Color(0xFFFFF1F2);
      label = 'Belum Terkirim';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // INFORMASI GURU
  // ============================================================

  Widget _buildTeacherInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Guru Pengampu',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                ),
                const SizedBox(height: 3),
                Text(
                  teacherName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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
  // INFORMASI TUGAS
  // ============================================================

  Widget _buildTaskInfo() {
    final deadline =
        getTaskValue('deadline', widget.task.deadline)?.toString() ?? '';

    final title = getTaskValue('judul', widget.task.title)?.toString() ?? '';

    final description =
        getTaskValue('deskripsi', widget.task.description)?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(21),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Deadline: ${formatDeadline(deadline)}',
                  style: const TextStyle(
                    color: Color(0xFF0369A1),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      size: 13,
                      color: Color(0xFF4338CA),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Upload',
                      style: TextStyle(
                        color: Color(0xFF4338CA),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          _buildTeacherInfo(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          sectionLabel('DESKRIPSI TUGAS'),
          const SizedBox(height: 9),
          Text(
            description.isNotEmpty ? description : 'Tidak ada deskripsi tugas.',
            style: const TextStyle(
              fontSize: 12,
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

  Widget _buildAttachment() {
    if (attachmentUrl == null || attachmentUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    final name = attachmentName ?? 'Berkas Lampiran';

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel('BERKAS LAMPIRAN'),
          const SizedBox(height: 13),
          Row(
            children: [
              fileIconBox(name, size: 40),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: textDark),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  showFilePreviewModal(fileName: name, fileUrl: attachmentUrl);
                },
                icon: const Icon(Icons.visibility_outlined, size: 14),
                label: const Text(
                  'Lihat Berkas',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PENGUMPULAN TUGAS
  // ============================================================

  Widget _buildSubmissionInfo() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: Color(0xFF059669),
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengumpulan Tugas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Kirimkan hasil pekerjaan kamu',
                      style: TextStyle(fontSize: 10, color: textMuted),
                    ),
                  ],
                ),
              ),
              statusBadge(),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: borderColor),
          ),
          if (!isSubmitted) ...[
            sectionLabel('UNGGAH BERKAS JAWABAN'),
            const SizedBox(height: 12),
            if (selectedFile == null)
              _buildUploadArea()
            else
              _buildSelectedFileCard(),
            const SizedBox(height: 14),
            _buildInfoBox(),
            const SizedBox(height: 17),
            _buildSubmitButton(),
          ] else ...[
            _buildSubmittedNotice(),
            const SizedBox(height: 15),
            _buildSubmittedFileCard(),
            if (isGraded) ...[
              const SizedBox(height: 16),
              _buildScoreCard(),
              const SizedBox(height: 12),
              _buildLockedNotice(),
            ] else ...[
              const SizedBox(height: 15),
              _buildRevisionSection(),
            ],
          ],
        ],
      ),
    );
  }

  // ============================================================
  // AREA UPLOAD
  // ============================================================

  Widget _buildUploadArea() {
    return InkWell(
      onTap: isSubmitting ? null : pickFile,
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        painter: DashedRoundedRectPainter(
          color: const Color(0xFFCBD5E1),
          radius: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 27, horizontal: 16),
          child: const Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                color: Color(0xFF0284C7),
                size: 35,
              ),
              SizedBox(height: 12),
              Text(
                'Klik untuk memilih file',
                style: TextStyle(
                  color: Color(0xFF0369A1),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Format PDF, DOCX, JPG, JPEG, PNG',
                style: TextStyle(fontSize: 10, color: textMuted),
              ),
              SizedBox(height: 4),
              Text(
                'Ukuran maksimal 10 MB',
                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILE TERPILIH
  // ============================================================

  Widget _buildSelectedFileCard() {
    final file = selectedFile!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              fileIconBox(file.name, size: 44),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatFileSize(selectedFileSize ?? 0),
                      style: const TextStyle(fontSize: 10, color: textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(height: 1, color: Color(0xFFDBEAFE)),
          ),
          Wrap(
            spacing: 5,
            children: [
              TextButton.icon(
                onPressed: () {
                  showFilePreviewModal(fileName: file.name, localFile: file);
                },
                icon: const Icon(Icons.visibility_outlined, size: 14),
                label: const Text('Lihat File'),
              ),
              TextButton.icon(
                onPressed: isSubmitting ? null : pickFile,
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Ganti'),
              ),
              TextButton.icon(
                onPressed: isSubmitting ? null : removeSelectedFile,
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text('Hapus'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMASI UPLOAD
  // ============================================================

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Periksa kembali berkas tugas sebelum dikirim. '
              'Kamu dapat melihat pratinjau file terlebih dahulu. '
              'Ukuran maksimal file adalah 10 MB.',
              style: TextStyle(
                color: Color(0xFF1D4ED8),
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOMBOL KUMPULKAN
  // ============================================================

  Widget _buildSubmitButton() {
    return Center(
      child: SizedBox(
        width: 190,
        height: 47,
        child: ElevatedButton(
          onPressed: selectedFile == null || isSubmitting ? null : submitTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFA5B4FC),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Kirim Jawaban',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }

  // ============================================================
  // NOTIFIKASI SUDAH TERKUMPUL
  // ============================================================

  Widget _buildSubmittedNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tugas berhasil dikumpulkan!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF047857),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Berkas tugas kamu sudah tersimpan dan '
                  'berhasil dikirim kepada guru.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: Color(0xFF047857),
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
  // FILE TERKUMPUL
  // ============================================================

  Widget _buildSubmittedFileCard() {
    final fileName = submittedFileName ?? 'jawaban_tugas';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              fileIconBox(fileName, size: 46),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Berkas Tugas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 19,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(height: 1, color: borderColor),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dikirim pada',
                      style: TextStyle(fontSize: 10, color: textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      submittedAt != null ? formatDeadline(submittedAt!) : '-',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: submittedFileUrl == null
                    ? null
                    : () {
                        showFilePreviewModal(
                          fileName: fileName,
                          fileUrl: submittedFileUrl,
                        );
                      },
                icon: const Icon(Icons.visibility_outlined, size: 14),
                label: const Text('Lihat File', style: TextStyle(fontSize: 10)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  backgroundColor: const Color(0xFFEEF2FF),
                  side: const BorderSide(color: Color(0xFFE0E7FF)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVISI BERKAS
  // ============================================================

  Widget _buildRevisionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.access_time_rounded,
                color: Color(0xFFD97706),
                size: 18,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tugas sedang menunggu pemeriksaan guru. '
                  'Kamu masih dapat melakukan revisi jika diperlukan.',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 11,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.refresh_rounded, color: primary, size: 17),
                  SizedBox(width: 8),
                  Text(
                    'Ganti Berkas Jawaban',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Pilih berkas baru jika ingin mengganti tugas sebelumnya.',
                style: TextStyle(fontSize: 11, color: textMuted),
              ),
              const SizedBox(height: 13),
              if (selectedFile == null)
                _buildUploadArea()
              else
                _buildSelectedFileCard(),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: selectedFile == null || isSubmitting
                      ? null
                      : submitTask,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(isSubmitting ? 'Menyimpan...' : 'Simpan Revisi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFA5B4FC),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NILAI TUGAS
  // ============================================================

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nilai dari Guru',
                  style: TextStyle(
                    color: Color(0xFF4338CA),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Hasil penilaian tugas kamu',
                  style: TextStyle(color: Color(0xFF6366F1), fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            score?.toStringAsFixed(0) ?? '-',
            style: const TextStyle(
              color: primary,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            ' / 100',
            style: TextStyle(color: Color(0xFF818CF8), fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TUGAS SUDAH DINILAI
  // ============================================================

  Widget _buildLockedNotice() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: Color(0xFF047857), size: 17),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Tugas sudah dinilai. Berkas tidak dapat diubah lagi.',
              style: TextStyle(
                color: Color(0xFF047857),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD HALAMAN
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Detail Tugas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: borderColor),
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
            const Icon(
              Icons.error_outline_rounded,
              size: 45,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: textMuted, fontSize: 12),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: loadDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: loadDetail,
      color: primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTaskInfo(),
                if (attachmentUrl != null && attachmentUrl!.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  _buildAttachment(),
                ],
                const SizedBox(height: 15),
                _buildSubmissionInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOM PAINTER BORDER PUTUS-PUTUS
// ============================================================

class DashedRoundedRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  DashedRoundedRectPainter({required this.color, this.radius = 12});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final rect = Rect.fromLTWH(0.7, 0.7, size.width - 1.4, size.height - 1.4);

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;

      while (distance < metric.length) {
        final end = (distance + 7).clamp(0.0, metric.length);

        canvas.drawPath(metric.extractPath(distance, end), paint);

        distance = end + 5;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
