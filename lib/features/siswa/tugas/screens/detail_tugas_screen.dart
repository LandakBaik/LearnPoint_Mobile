import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:docx_viewer/docx_viewer.dart';

import 'package:learnpoint_mobile/features/siswa/tugas/models/task_model.dart';
import 'package:learnpoint_mobile/core/config/api_config.dart';

class DetailTugasPage extends StatefulWidget {
  final TaskModel task;

  const DetailTugasPage({super.key, required this.task});

  @override
  State<DetailTugasPage> createState() => _DetailTugasPageState();
}

class _DetailTugasPageState extends State<DetailTugasPage> {
  static const Color primary = Color(0xFF0284C7);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  static const int maxFileSize = 10 * 1024 * 1024;

  static const List<String> allowedExtensions = [
    'pdf',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];

  PlatformFile? selectedFile;

  bool isSubmitting = false;
  bool isLoadingSubmission = false;

  late bool isSubmitted;

  bool isGraded = false;
  double? score;

  String? submittedFileName;
  String? submittedFileUrl;

  String? teacherName;
  String? attachmentName;
  String? attachmentUrl;

  int? selectedFileSize;

  @override
  void initState() {
    super.initState();

    isSubmitted = widget.task.isSubmitted;

    if (isSubmitted) {
      _loadSubmissionDetails();
    } else {
      // Ambil informasi guru dan lampiran dari endpoint detail yang sama.
      _loadSubmissionDetails();
    }
  }

  // HELPER //

  void _showMessage(
    String message, {
    Color backgroundColor = textDark,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  String _getExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return '';
    return parts.last.toLowerCase();
  }

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = Uri.decodeComponent(uri.path);
      return path.split('/').last;
    } catch (_) {
      return 'jawaban_tugas';
    }
  }

  String formatDeadline(String value) {
    if (value.isEmpty) return 'Tidak ditentukan';

    try {
      final date = DateTime.parse(value).toLocal();

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
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

  String _formatSubmittedDate(String? value) {
    if (value == null || value.isEmpty) return '';

    try {
      return formatDeadline(value);
    } catch (_) {
      return value;
    }
  }

  // MEMUAT DATA PENGUMPULAN DARI API // 

  Future<void> _loadSubmissionDetails() async {
    if (isLoadingSubmission) return;

    setState(() {
      isLoadingSubmission = true;
    });

    try {
      final response = await ApiConfig.dio.get(
        '/siswa/tugas/${widget.task.id}',
      );

      final responseBody = response.data;

      if (responseBody is! Map) return;

      final data = responseBody['data'];

      if (data is! Map) return;

      // Informasi guru dan lampiran dari detail tugas.
      final guru = data['guru'];
      final lampiran = data['file_lampiran'];
      final lampiranUrl = data['file_url'] ?? data['file_lampiran_url'];

      final namaGuru = guru is Map
          ? guru['nama_guru']?.toString() ?? guru['name']?.toString()
          : null;

      final namaLampiran = lampiran?.toString();
      final urlLampiran = lampiranUrl?.toString();

      final submission = data['submission'];

      if (!mounted) return;

      setState(() {
        if (namaGuru != null && namaGuru.isNotEmpty) {
          teacherName = namaGuru;
        }

        if (urlLampiran != null && urlLampiran.isNotEmpty) {
          attachmentUrl = urlLampiran;
        }

        if (namaLampiran != null && namaLampiran.isNotEmpty) {
          attachmentName = _getFileNameFromUrl(namaLampiran);
        } else if (urlLampiran != null && urlLampiran.isNotEmpty) {
          attachmentName = _getFileNameFromUrl(urlLampiran);
        }

        if (submission is Map) {
          final fileUrl = submission['file_jawaban_url']?.toString();

          if (fileUrl != null && fileUrl.isNotEmpty) {
            submittedFileUrl = fileUrl;
            submittedFileName = _getFileNameFromUrl(fileUrl);
            isSubmitted = true;
          }

          final nilai = submission['nilai'];

          if (nilai != null) {
            score = double.tryParse(nilai.toString());
            isGraded = true;
          }
        }
      });
    } on DioException catch (e) {
      debugPrint('Gagal mengambil detail pengumpulan: ${e.message}');
    } catch (e) {
      debugPrint('Kesalahan detail pengumpulan: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSubmission = false;
        });
      }
    }
  }

  // PILIH FILE //

  Future<void> pickFile() async {
    if (isGraded || isSubmitting) return;

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (!mounted || result.isEmpty) return;

      final file = result.first;
      final fileSize = await file.length();

      if (!mounted) return;

      if (fileSize == null) {
        _showMessage('Ukuran file tidak dapat dibaca.');
        return;
      }

      if (fileSize > maxFileSize) {
        _showMessage(
          'Ukuran file maksimal 10 MB.',
          backgroundColor: Colors.red,
        );
        return;
      }

      if (fileSize == 0) {
        _showMessage('File yang dipilih kosong.');
        return;
      }

      setState(() {
        selectedFile = file;
        selectedFileSize = fileSize;
      });
    } catch (e) {
      _showMessage('Gagal memilih file: $e');
    }
  }

  // HAPUS FILE TERPILIH //

  void removeSelectedFile() {
    if (isSubmitting) return;

    setState(() {
      selectedFile = null;
      selectedFileSize = null;
    });
  }

  // PREVIEW FILE // 

  Future<void> showFilePreviewModal({
    required String fileName,
    String? fileUrl,
    PlatformFile? localFile,
  }) async {
    final extension = _getExtension(fileName);

    if (!allowedExtensions.contains(extension)) {
      _showMessage('Format file tidak didukung.');
      return;
    }

    Uint8List? fileBytes;

    if (localFile != null) {
      try {
        fileBytes = await localFile.readAsBytes();

        if (fileBytes.isEmpty) {
          _showMessage('File tidak memiliki isi.');
          return;
        }
      } catch (e) {
        _showMessage('Gagal membaca file: $e');
        return;
      }
    }

    if (localFile == null && (fileUrl == null || fileUrl.isEmpty)) {
      _showMessage('Lokasi file tidak ditemukan.');
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFilePreviewPage(
          fileName: fileName,
          extension: extension,
          fileBytes: fileBytes,
          fileUrl: fileUrl,
        ),
      ),
    );
  }

  // ============================================================
  // KIRIM TUGAS KE API - ALUR ASLI
  // ============================================================

  Future<void> submitTask() async {
    final file = selectedFile;

    if (file == null || isSubmitting || isGraded) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('File yang dipilih kosong.');
      }

      if (bytes.length > maxFileSize) {
        throw Exception('Ukuran file maksimal 10 MB.');
      }

      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: file.name,
      );

      final formData = FormData.fromMap({
        'file_jawaban': multipartFile,
      });

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

      final responseBody = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = responseBody is Map ? responseBody['data'] : null;

        final fileUrl = data is Map
            ? data['file_jawaban_url']?.toString()
            : null;

        setState(() {
          isSubmitted = true;
          submittedFileName = file.name;
          submittedFileUrl = fileUrl;
          selectedFile = null;
          selectedFileSize = null;
        });

        _showMessage(
          'Tugas berhasil dikumpulkan!',
          backgroundColor: Colors.green,
        );

        // Segarkan informasi pengumpulan dari API.
        _loadSubmissionDetails();
      } else {
        _showMessage('Tugas gagal dikumpulkan.');
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

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // STYLE HELPER //

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.025),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Color _fileColor(String fileName) {
    final ext = _getExtension(fileName);

    if (ext == 'pdf') return const Color(0xFFE11D48);
    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      return const Color(0xFF0284C7);
    }

    return const Color(0xFF4F46E5);
  }

  IconData _fileIcon(String fileName) {
    final ext = _getExtension(fileName);

    if (ext == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      return Icons.image_rounded;
    }

    return Icons.description_rounded;
  }

  Widget _fileIconBox(String fileName, {double size = 46}) {
    final color = _fileColor(fileName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _fileIcon(fileName),
        color: color,
        size: size * 0.52,
      ),
    );
  }

  Widget _sectionLabel(String text) {
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

  Widget _statusBadge() {
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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
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

  // INFORMASI GURU //

  Widget _buildTeacherInfo() {
    if (teacherName == null || teacherName!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Guru Pengampu',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  teacherName!,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 12,
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

  // CARD INFORMASI TUGAS//

  Widget _buildTaskInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 14,
                  color: primary,
                ),
                const SizedBox(width: 7),
                Text(
                  'Deadline: ${formatDeadline(widget.task.deadline)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Text(
            widget.task.title,
            style: const TextStyle(
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),

          _buildTeacherInfo(),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 17),
            child: Divider(height: 1, color: border),
          ),

          _sectionLabel('DESKRIPSI TUGAS'),

          const SizedBox(height: 9),

          Text(
            widget.task.description.isNotEmpty
                ? widget.task.description
                : 'Tidak ada deskripsi tugas.',
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

  // KARTU BERKAS LAMPIRAN //

  Widget _buildAttachmentCard() {
    if (attachmentUrl == null || attachmentUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    final name = attachmentName ?? 'Berkas Lampiran';

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('BERKAS LAMPIRAN'),
          const SizedBox(height: 13),
          Row(
            children: [
              _fileIconBox(name),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Berkas dari guru pengampu',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              TextButton.icon(
                onPressed: () {
                  showFilePreviewModal(
                    fileName: name,
                    fileUrl: attachmentUrl,
                  );
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 15,
                ),
                label: const Text(
                  'Lihat',
                  style: TextStyle(fontSize: 11),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // KARTU PENGUMPULAN TUGAS //

  Widget _buildSubmissionSectionCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: _cardDecoration(),
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
                      style: TextStyle(
                        fontSize: 10,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: border),
          ),

          _statusBadge(),

          const SizedBox(height: 17),

          if (!isSubmitted) ...[
            _sectionLabel('UNGGAH BERKAS JAWABAN'),
            const SizedBox(height: 11),

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

            _sectionLabel('BERKAS YANG DIKUMPULKAN'),

            const SizedBox(height: 10),

            _buildSubmittedFileCard(),

            if (isGraded) ...[
              const SizedBox(height: 16),
              _buildScoreCard(),
              const SizedBox(height: 12),
              _buildLockedNotice(),
            ] else ...[
              const SizedBox(height: 15),
              _buildWaitingNotice(),
            ],
          ],
        ],
      ),
    );
  }

  // AREA PILIH FILE //

  Widget _buildUploadArea() {
    return InkWell(
      onTap: isSubmitting ? null : pickFile,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 25,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFCBD5E1),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih Berkas Jawaban',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Ketuk untuk memilih file dari perangkat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 11),
            const Text(
              'PDF, DOCX, JPG, PNG • Maks. 10 MB',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // KARTU FILE TERPILIH //

  Widget _buildSelectedFileCard() {
    final file = selectedFile!;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _fileIconBox(file.name),
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
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedFileSize != null
                          ? formatFileSize(selectedFileSize!)
                          : '',
                      style: const TextStyle(
                        fontSize: 10,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF059669),
                size: 20,
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 11),
            child: Divider(height: 1, color: border),
          ),

          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    showFilePreviewModal(
                      fileName: file.name,
                      localFile: selectedFile,
                    );
                  },
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 15,
                  ),
                  label: const Text(
                    'Preview',
                    style: TextStyle(fontSize: 11),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: isSubmitting ? null : pickFile,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 15,
                  ),
                  label: const Text(
                    'Ganti File',
                    style: TextStyle(fontSize: 11),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: textMuted,
                  ),
                ),
              ),
              IconButton(
                onPressed: isSubmitting ? null : removeSelectedFile,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE11D48),
                  size: 19,
                ),
                tooltip: 'Hapus file',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // INFO PENGUMPULAN //

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2563EB),
            size: 18,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Pastikan berkas jawaban sudah benar dan dapat dibuka '
              'sebelum kamu mengumpulkan tugas.',
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

  // TOMBOL KIRIM //

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 49,
      child: ElevatedButton.icon(
        onPressed: selectedFile == null || isSubmitting
            ? null
            : submitTask,
        icon: isSubmitting
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.send_rounded,
                size: 17,
              ),
        label: Text(
          isSubmitting ? 'Mengirim...' : 'Kirim Tugas Sekarang',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFA5B4FC),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // NOTIFIKASI SUDAH TERKUMPUL // 

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
          Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF059669),
            size: 20,
          ),
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
                  'Berkas jawabanmu sudah diterima dan tersimpan.',
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

  // KARTU FILE TERKUMPUL //

  Widget _buildSubmittedFileCard() {
    final fileName = submittedFileName ?? 'jawaban_tugas';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          _fileIconBox(fileName),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Berkas jawaban',
                  style: TextStyle(
                    fontSize: 10,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: submittedFileUrl == null
                ? null
                : () {
                    showFilePreviewModal(
                      fileName: fileName,
                      fileUrl: submittedFileUrl,
                    );
                  },
            icon: const Icon(
              Icons.visibility_outlined,
              color: primary,
              size: 21,
            ),
            tooltip: 'Lihat berkas',
          ),
        ],
      ),
    );
  }

  // MENUNGGU PENILAIAN //

  Widget _buildWaitingNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEF3C7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            color: Color(0xFFD97706),
            size: 19,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menunggu Penilaian',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB45309),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Guru belum memberikan nilai untuk tugas ini.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NILAI TUGAS //

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Column(
        children: [
          const Text(
            'NILAI TUGAS',
            style: TextStyle(
              color: Color(0xFF15803D),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            score?.toStringAsFixed(
                  score == score?.roundToDouble() ? 0 : 2,
                ) ??
                '-',
            style: const TextStyle(
              color: Color(0xFF166534),
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'dari 100',
            style: TextStyle(
              color: Color(0xFF15803D),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedNotice() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: textMuted,
            size: 18,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Tugas sudah dinilai. Pengumpulan berkas telah ditutup.',
              style: TextStyle(
                color: textMuted,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BUILD HALAMAN //

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
          child: Divider(height: 1, color: border),
        ),
      ),
      body: SafeArea(
        child: isLoadingSubmission && !isSubmitted
            ? const Center(
                child: CircularProgressIndicator(color: primary),
              )
            : RefreshIndicator(
                onRefresh: _loadSubmissionDetails,
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
                          Row(
                            children: [
                              const Text(
                                'Beranda',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 7),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 15,
                                ),
                              ),
                              const Text(
                                'Tugas',
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _buildTaskInfoCard(),

                          if (attachmentUrl != null &&
                              attachmentUrl!.isNotEmpty) ...[
                            const SizedBox(height: 15),
                            _buildAttachmentCard(),
                          ],

                          const SizedBox(height: 15),

                          _buildSubmissionSectionCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// HALAMAN PREVIEW BERKAS //

class TaskFilePreviewPage extends StatelessWidget {
  final String fileName;
  final String extension;
  final Uint8List? fileBytes;
  final String? fileUrl;

  const TaskFilePreviewPage({
    super.key,
    required this.fileName,
    required this.extension,
    this.fileBytes,
    this.fileUrl,
  });

  Widget _previewError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (extension == 'pdf') {
      if (fileBytes != null) {
        return SfPdfViewer.memory(fileBytes!);
      }

      if (fileUrl != null) {
        return SfPdfViewer.network(
          fileUrl!,
          canShowScrollHead: true,
          canShowScrollStatus: true,
        );
      }
    }

    if (extension == 'docx') {
      if (fileBytes != null) {
        return DocxView(
          bytes: fileBytes!,
          fontSize: 14,
          onError: (error) {
            debugPrint('Gagal menampilkan DOCX: $error');
          },
        );
      }

      if (fileUrl != null) {
        return DocxView(
          filePath: fileUrl!,
          fontSize: 14,
          onError: (error) {
            debugPrint('Gagal menampilkan DOCX: $error');
          },
        );
      }
    }

    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      final image = fileBytes != null
          ? Image.memory(
              fileBytes!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  _previewError('Gagal menampilkan gambar.'),
            )
          : Image.network(
              fileUrl!,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (_, __, ___) =>
                  _previewError('Gagal memuat gambar.'),
            );

      return Container(
        color: const Color(0xFFF1F5F9),
        alignment: Alignment.center,
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: image,
        ),
      );
    }

    return _previewError('File tidak dapat ditampilkan.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF0F172A),
          ),
        ),
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: _buildPreview(),
    );
  }
}