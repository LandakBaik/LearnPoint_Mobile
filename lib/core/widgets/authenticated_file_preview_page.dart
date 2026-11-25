import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:docx_viewer/docx_viewer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:learnpoint_mobile/core/config/api_config.dart';

/// Halaman pratinjau berkas terautentikasi di dalam aplikasi.
///
/// Mengambil berkas privat dari endpoint Laravel (`/api/file/materi/{id}`,
/// `/api/file/tugas/{id}`, `/api/file/jawaban/{id}`) menggunakan `ApiConfig.dio`
/// (otomatis menyertakan header `Authorization: Bearer <token>` dan
/// `Accept: application/json`), sehingga tidak gagal atau ter-redirect ke
/// halaman login versi web.
class AuthenticatedFilePreviewPage extends StatefulWidget {
  final String fileName;
  final String? fileUrl;
  final Uint8List? fileBytes;
  final String? localFilePath;
  final String? extensionHint;

  const AuthenticatedFilePreviewPage({
    super.key,
    required this.fileName,
    this.fileUrl,
    this.fileBytes,
    this.localFilePath,
    this.extensionHint,
  });

  @override
  State<AuthenticatedFilePreviewPage> createState() =>
      _AuthenticatedFilePreviewPageState();
}

class _AuthenticatedFilePreviewPageState
    extends State<AuthenticatedFilePreviewPage> {
  static const Color _primary = Color(0xFF4F46E5);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  Uint8List? _bytes;
  late String _resolvedFileName;
  late String _resolvedExtension;

  @override
  void initState() {
    super.initState();
    _resolvedFileName = widget.fileName.trim().isNotEmpty
        ? widget.fileName.trim()
        : 'Berkas';
    _resolvedExtension = _normalizeExt(
      widget.extensionHint ?? _extractExtension(_resolvedFileName),
    );
    _loadFile();
  }

  Future<void> _loadFile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Jika bytes sudah tersedia di memori (misal file lokal dari FilePicker)
      if (widget.fileBytes != null && widget.fileBytes!.isNotEmpty) {
        final bytes = widget.fileBytes!;
        final ext = _resolvedExtension.isNotEmpty
            ? _resolvedExtension
            : _detectExtensionFromBytes(bytes);
        if (!mounted) return;
        setState(() {
          _bytes = bytes;
          _resolvedExtension = ext;
          _isLoading = false;
        });
        return;
      }

      // 2. Jika sudah diunduh secara lokal (mode offline materi)
      if (!kIsWeb &&
          widget.localFilePath != null &&
          widget.localFilePath!.trim().isNotEmpty) {
        final localFile = File(widget.localFilePath!);
        if (await localFile.exists()) {
          final bytes = await localFile.readAsBytes();
          if (bytes.isNotEmpty) {
            final ext = _resolvedExtension.isNotEmpty
                ? _resolvedExtension
                : _extractExtension(localFile.path).isNotEmpty
                ? _extractExtension(localFile.path)
                : _detectExtensionFromBytes(bytes);
            if (!mounted) return;
            setState(() {
              _bytes = bytes;
              _resolvedExtension = ext;
              _isLoading = false;
            });
            return;
          }
        }
      }

      // 3. Unduh dari server Laravel memakai ApiConfig.dio (terautentikasi Sanctum)
      final rawUrl = widget.fileUrl?.trim() ?? '';
      if (rawUrl.isEmpty) {
        throw Exception('Lokasi berkas tidak ditemukan.');
      }

      final resolvedUrl = ApiConfig.resolveUrl(rawUrl);
      final response = await ApiConfig.dio.get<List<int>>(
        resolvedUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final statusCode = response.statusCode ?? 0;
      final contentType =
          response.headers.value('content-type')?.toLowerCase() ?? '';
      final contentDisposition =
          response.headers.value('content-disposition') ?? '';

      if (statusCode == 401) {
        throw Exception('Sesi login berakhir. Silakan login kembali.');
      }
      if (statusCode == 403) {
        throw Exception(
          _extractJsonError(response.data) ??
              'Anda tidak memiliki akses untuk melihat berkas ini.',
        );
      }
      if (statusCode == 404) {
        throw Exception(
          _extractJsonError(response.data) ??
              'Berkas tidak ditemukan di server.',
        );
      }
      if (statusCode >= 300 || statusCode < 200) {
        throw Exception(
          _extractJsonError(response.data) ??
              'Gagal memuat berkas dari server (Kode $statusCode).',
        );
      }

      if (contentType.contains('text/html')) {
        throw Exception(
          'Server mengembalikan halaman HTML, bukan berkas. '
          'Pastikan sesi login Anda masih aktif.',
        );
      }
      if (contentType.contains('application/json')) {
        throw Exception(
          _extractJsonError(response.data) ??
              'Gagal memuat berkas dari server.',
        );
      }

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw Exception('Berkas kosong atau gagal diunduh.');
      }

      final bytes = Uint8List.fromList(data);

      // Deteksi nama berkas & ekstensi dari header Content-Disposition / Content-Type / magic bytes
      final headerFileName = _parseFileNameFromDisposition(contentDisposition);
      String finalName = _resolvedFileName;
      if (headerFileName != null && headerFileName.isNotEmpty) {
        if (_extractExtension(finalName).isEmpty ||
            finalName == 'Berkas' ||
            finalName == 'Berkas Jawaban' ||
            finalName == 'Berkas Lampiran' ||
            finalName == 'jawaban_tugas') {
          finalName = headerFileName;
        }
      }

      String finalExt = _resolvedExtension;
      if (finalExt.isEmpty) {
        finalExt = _extractExtension(finalName);
      }
      if (finalExt.isEmpty && headerFileName != null) {
        finalExt = _extractExtension(headerFileName);
      }
      if (finalExt.isEmpty) {
        finalExt = _extensionFromContentType(contentType);
      }
      if (finalExt.isEmpty) {
        finalExt = _detectExtensionFromBytes(bytes);
      }

      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _resolvedFileName = finalName;
        _resolvedExtension = finalExt;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final statusCode = e.response?.statusCode;
      String message = 'Gagal memuat berkas dari server.';
      if (statusCode == 401) {
        message = 'Sesi login berakhir. Silakan login kembali.';
      } else if (statusCode == 403) {
        message =
            _extractJsonError(e.response?.data) ??
            'Anda tidak memiliki akses ke berkas ini.';
      } else if (statusCode == 404) {
        message =
            _extractJsonError(e.response?.data) ??
            'Berkas tidak ditemukan di server.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        message = 'Koneksi ke server timeout. Silakan coba lagi.';
      } else if (e.type == DioExceptionType.connectionError) {
        message =
            'Tidak dapat terhubung ke server (${ApiConfig.baseUrl}). '
            'Periksa koneksi internet Anda.';
      } else {
        message = _extractJsonError(e.response?.data) ?? message;
      }

      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToDevice() async {
    if (kIsWeb || _bytes == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory(p.join(dir.path, 'saved_files'));
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final sanitized = _resolvedFileName.replaceAll(RegExp(r'[^\w.\- ]'), '_');
      final hasExt = _extractExtension(sanitized).isNotEmpty;
      final fileName = hasExt || _resolvedExtension.isEmpty
          ? sanitized
          : '$sanitized.$_resolvedExtension';

      final filePath = p.join(downloadsDir.path, fileName);
      await File(filePath).writeAsBytes(_bytes!, flush: true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berkas "$fileName" berhasil disimpan ke perangkat.'),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan berkas: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  static String? _extractJsonError(dynamic rawData) {
    try {
      if (rawData is Map) {
        return rawData['message']?.toString();
      }
      if (rawData is List<int>) {
        final decoded = jsonDecode(utf8.decode(rawData, allowMalformed: true));
        if (decoded is Map && decoded['message'] != null) {
          return decoded['message'].toString();
        }
      }
      if (rawData is String && rawData.isNotEmpty) {
        final decoded = jsonDecode(rawData);
        if (decoded is Map && decoded['message'] != null) {
          return decoded['message'].toString();
        }
      }
    } catch (_) {}
    return null;
  }

  static String? _parseFileNameFromDisposition(String header) {
    if (header.isEmpty) return null;

    final utf8Match = RegExp(
      r"filename\*=UTF-8''([^;\r\n]+)",
      caseSensitive: false,
    ).firstMatch(header);
    if (utf8Match != null) {
      return Uri.decodeComponent(utf8Match.group(1)!.trim());
    }

    final quotedMatch = RegExp(
      r'filename="([^"]+)"',
      caseSensitive: false,
    ).firstMatch(header);
    if (quotedMatch != null) {
      return quotedMatch.group(1)!.trim();
    }

    final plainMatch = RegExp(
      r'filename=([^;\r\n]+)',
      caseSensitive: false,
    ).firstMatch(header);
    if (plainMatch != null) {
      return plainMatch.group(1)!.trim();
    }

    return null;
  }

  static String _normalizeExt(String ext) =>
      ext.trim().toLowerCase().replaceFirst('.', '');

  static String _extractExtension(String name) {
    final clean = name.split('?').first.trim();
    final dotIndex = clean.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == clean.length - 1) return '';
    final ext = clean.substring(dotIndex + 1).toLowerCase();
    // Hindari angka murni atau string panjang yang bukan ekstensi
    if (ext.length > 6 || RegExp(r'^\d+$').hasMatch(ext)) return '';
    return ext;
  }

  static String _extensionFromContentType(String contentType) {
    if (contentType.contains('pdf')) return 'pdf';
    if (contentType.contains('jpeg') || contentType.contains('jpg')) {
      return 'jpg';
    }
    if (contentType.contains('png')) return 'png';
    if (contentType.contains('webp')) return 'webp';
    if (contentType.contains('gif')) return 'gif';
    if (contentType.contains('wordprocessingml')) return 'docx';
    if (contentType.contains('presentationml')) return 'pptx';
    if (contentType.contains('ms-powerpoint')) return 'ppt';
    if (contentType.contains('zip')) return 'zip';
    return '';
  }

  static String _detectExtensionFromBytes(Uint8List bytes) {
    if (bytes.length >= 4) {
      // %PDF
      if (bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46) {
        return 'pdf';
      }
      // PNG: 89 50 4E 47
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return 'png';
      }
      // JPEG: FF D8 FF
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return 'jpg';
      }
      // GIF: 47 49 46 38
      if (bytes[0] == 0x47 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x38) {
        return 'gif';
      }
    }
    return '';
  }

  String _formatBytes(int length) {
    if (length < 1024) return '$length B';
    if (length < 1024 * 1024) {
      return '${(length / 1024).toStringAsFixed(1)} KB';
    }
    return '${(length / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Widget _buildUnsupportedPreview(Uint8List bytes) {
    final extLabel = _resolvedExtension.isNotEmpty
        ? '.${_resolvedExtension.toUpperCase()}'
        : 'Berkas';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.insert_drive_file_rounded,
                  size: 32,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _resolvedFileName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$extLabel • ${_formatBytes(bytes.length)}',
                style: const TextStyle(fontSize: 12, color: _textMuted),
              ),
              const SizedBox(height: 14),
              Text(
                'Pratinjau langsung untuk format $extLabel belum didukung di dalam aplikasi. '
                'Berkas sudah berhasil diunduh dari server dan dapat disimpan ke perangkat.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: _textMuted,
                ),
              ),
              if (!kIsWeb) ...[
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveToDevice,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    _isSaving ? 'Menyimpan...' : 'Simpan ke Perangkat',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFile,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _primary),
            SizedBox(height: 14),
            Text(
              'Memuat berkas...',
              style: TextStyle(fontSize: 13, color: _textMuted),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorView(_errorMessage!);
    }

    final bytes = _bytes;
    if (bytes == null || bytes.isEmpty) {
      return _buildErrorView('Berkas tidak dapat ditampilkan.');
    }

    if (_resolvedExtension == 'pdf') {
      return SfPdfViewer.memory(
        bytes,
        canShowScrollHead: true,
        canShowScrollStatus: true,
      );
    }

    if (_resolvedExtension == 'docx') {
      return DocxView(
        bytes: bytes,
        fontSize: 14,
        onError: (error) {
          debugPrint('Gagal menampilkan DOCX: $error');
        },
      );
    }

    if (const ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(_resolvedExtension)) {
      return Container(
        color: const Color(0xFFF1F5F9),
        alignment: Alignment.center,
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                _buildErrorView('Gagal menampilkan gambar.'),
          ),
        ),
      );
    }

    return _buildUnsupportedPreview(bytes);
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
          icon: const Icon(Icons.arrow_back_rounded, color: _textDark),
        ),
        title: Text(
          _resolvedFileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!kIsWeb && !_isLoading && _bytes != null)
            IconButton(
              onPressed: _isSaving ? null : _saveToDevice,
              tooltip: 'Simpan ke perangkat',
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _primary,
                      ),
                    )
                  : const Icon(Icons.download_rounded, color: _textDark),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _borderColor),
        ),
      ),
      body: _buildPreviewBody(),
    );
  }
}
