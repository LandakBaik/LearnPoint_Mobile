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
  // ============================================================
  // KONSTANTA WARNA
  // ============================================================

  static const Color primary = Color(0xFF0284C7);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static const int maxFileSize = 10 * 1024 * 1024;

  static const List<String> allowedExtensions = [
    'pdf',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];

  // ============================================================
  // STATE
  // ============================================================

  PlatformFile? selectedFile;

  bool isSubmitting = false;
  bool isLoadingSubmission = false;

  late bool isSubmitted;

  bool isGraded = false;
  double? score;

  String? submittedFileName;
  String? submittedFileUrl;

  int? selectedFileSize;

  @override
  void initState() {
    super.initState();

    isSubmitted = widget.task.isSubmitted;

    if (isSubmitted) {
      _loadSubmissionDetails();
    }
  }

  // ============================================================
  // HELPER
  // ============================================================

  void _showMessage(String message, {Color backgroundColor = textDark}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
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

  // ============================================================
  // MEMUAT DATA PENGUMPULAN DARI API
  // ============================================================

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

      final submission = data['submission'];

      if (submission is! Map) return;

      final fileUrl = submission['file_jawaban_url']?.toString();

      if (!mounted) return;

      setState(() {
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
    final extension = _getExtension(fileName);

    if (!allowedExtensions.contains(extension)) {
      _showMessage('Format file tidak didukung.');
      return;
    }

    Uint8List? fileBytes;

    // Baca file lokal, termasuk DOCX.
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

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: SizedBox(
            width: 700,
            height: MediaQuery.of(dialogContext).size.height * 0.75,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pratinjau Berkas',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    fileName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildFilePreview(
                        extension: extension,
                        fileBytes: fileBytes,
                        fileUrl: fileUrl,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // KONTEN PREVIEW BERDASARKAN FORMAT FILE
  // ============================================================

  Widget _buildFilePreview({
    required String extension,
    Uint8List? fileBytes,
    String? fileUrl,
  }) {
    // PDF
    if (extension == 'pdf') {
      if (fileBytes != null && fileBytes.isNotEmpty) {
        return SfPdfViewer.memory(fileBytes);
      }

      if (fileUrl != null && fileUrl.isNotEmpty) {
        return SfPdfViewer.network(
          fileUrl,
          canShowScrollHead: true,
          canShowScrollStatus: true,
        );
      }

      return const Center(child: Text('File PDF tidak dapat dibaca.'));
    }

    // DOCX
    if (extension == 'docx') {
      if (fileBytes != null) {
        return DocxView(
          bytes: fileBytes,
          fontSize: 14,
          onError: (error) {
            debugPrint('Gagal menampilkan DOCX: $error');
          },
        );
      }

      if (fileUrl != null) {
        return DocxView(
          filePath: fileUrl,
          fontSize: 14,
          onError: (error) {
            debugPrint('Gagal menampilkan DOCX: $error');
          },
        );
      }
    }

    // GAMBAR
    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      final image = fileBytes != null
          ? Image.memory(
              fileBytes,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return _previewError('Gagal menampilkan gambar.');
              },
            )
          : Image.network(
              fileUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return _previewError('Gagal memuat gambar.');
              },
            );

      return Container(
        color: const Color(0xFFF1F5F9),
        alignment: Alignment.center,
        child: InteractiveViewer(minScale: 0.5, maxScale: 4, child: image),
      );
    }

    return _previewError('File tidak dapat ditampilkan.');
  }

  Widget _previewError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.insert_drive_file_outlined,
              size: 42,
              color: textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // KIRIM TUGAS KE API
  // ============================================================

  Future<void> submitTask() async {
    final file = selectedFile;

    if (file == null || isSubmitting || isGraded) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      // Baca isi file.
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('File yang dipilih kosong.');
      }

      if (bytes.length > maxFileSize) {
        throw Exception('Ukuran file maksimal 10 MB.');
      }

      // Buat multipart dari bytes agar tidak bergantung pada path.
      final multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);

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
      } else {
        _showMessage('Tugas gagal dikumpulkan.');
      }
    } on DioException catch (e) {
      if (!mounted) return;

      String message = 'Gagal mengirim tugas.';

      final responseData = e.response?.data;

      if (responseData is Map) {
        message = responseData['message']?.toString() ?? message;

        // Ambil pesan validasi Laravel jika tersedia.
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
        title: Text(
          widget.task.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTaskInfoCard(),
                  const SizedBox(height: 20),
                  _buildSubmissionSectionCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // KARTU INFORMASI TUGAS
  // ============================================================

  Widget _buildTaskInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFE0F2FE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Deadline: ${formatDeadline(widget.task.deadline)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.task.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFF1F5F9)),
          ),
          const Text(
            'DESKRIPSI TUGAS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.task.description.isNotEmpty
                ? widget.task.description
                : 'Tidak ada deskripsi tugas.',
            style: const TextStyle(fontSize: 13, height: 1.6, color: textMuted),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KARTU PENGUMPULAN TUGAS
  // ============================================================

  Widget _buildSubmissionSectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: Color(0xFF059669),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
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
                      SizedBox(height: 2),
                      Text(
                        'Kirimkan hasil pekerjaan kamu',
                        style: TextStyle(fontSize: 11, color: textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              _buildStatusBadge(),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFF1F5F9)),
          ),

          if (!isSubmitted) ...[
            const Text(
              'UNGGAH BERKAS JAWABAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 10),

            if (selectedFile == null)
              _buildUploadArea()
            else
              _buildSelectedFileCard(),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selectedFile == null || isSubmitting
                    ? null
                    : submitTask,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 16),
                label: Text(
                  isSubmitting ? 'Mengirim...' : 'Kirim Tugas Sekarang',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ] else ...[
            _buildSubmittedNotice(),
            const SizedBox(height: 16),
            _buildSubmittedFileCard(),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // AREA PILIH FILE
  // ============================================================

  Widget _buildUploadArea() {
    return InkWell(
      onTap: isSubmitting ? null : pickFile,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        ),
        child: const Column(
          children: [
            Icon(Icons.cloud_upload_outlined, size: 32, color: primary),
            SizedBox(height: 10),
            Text(
              'Klik untuk memilih file',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Format PDF, DOCX, JPG, atau PNG (Maks. 10 MB)',
              style: TextStyle(fontSize: 11, color: textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // KARTU FILE YANG DIPILIH
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insert_drive_file,
                  color: primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedFileSize != null
                          ? formatFileSize(selectedFileSize!)
                          : '',
                      style: const TextStyle(fontSize: 11, color: textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFE0F2FE)),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showFilePreviewModal(
                      fileName: file.name,
                      localFile: selectedFile,
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
                  label: const Text('Lihat File'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textDark,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSubmitting ? null : pickFile,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Ganti File'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textDark,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: isSubmitting ? null : removeSelectedFile,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                tooltip: 'Hapus file',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFIKASI TUGAS BERHASIL DIKUMPULKAN
  // ============================================================

  Widget _buildSubmittedNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF059669), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tugas berhasil dikumpulkan!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Berkas sudah tersimpan dan dikirim kepada guru.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF065F46)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KARTU FILE YANG SUDAH DIKUMPULKAN
  // ============================================================

  Widget _buildSubmittedFileCard() {
    final fileName = submittedFileName ?? 'jawaban_tugas';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.description, color: Color(0xFF4F46E5), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Berkas Tugas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fileName,
                  style: const TextStyle(fontSize: 11, color: textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: isLoadingSubmission && submittedFileUrl == null
                ? null
                : () {
                    showFilePreviewModal(
                      fileName: fileName,
                      fileUrl: submittedFileUrl,
                    );
                  },
            icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
            label: const Text('Lihat File'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4F46E5),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BADGE STATUS PENGUMPULAN
  // ============================================================

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSubmitted ? const Color(0xFFF0F9FF) : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSubmitted
              ? const Color(0xFFE0F2FE)
              : const Color(0xFFFFE4E6),
        ),
      ),
      child: Text(
        isSubmitted ? 'Sudah Terkirim' : 'Belum Terkirim',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isSubmitted ? primary : const Color(0xFFE11D48),
        ),
      ),
    );
  }

  // ============================================================
  // DEKORASI KARTU
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.01),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
