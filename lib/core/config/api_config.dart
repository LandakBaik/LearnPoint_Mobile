import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:learnpoint_mobile/core/services/storage_service.dart';

class ApiConfig {
  /// Default base URL berdasarkan platform:
  /// - Android Emulator: 10.0.2.2 merujuk ke localhost pada mesin host
  /// - iOS Simulator / Desktop / Web: 127.0.0.1 atau localhost
  /// Catatan: Jika menggunakan Device Fisik (HP asli), ubah ke IP Laptop/PC Anda
  /// (contoh: http://192.168.1.10:8000/api)
  static String? _customBaseUrl;
  static bool _isBaseUrlLoadedFromStorage = false;

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://192.168.100.46:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  } 

  static String get baseUrl => _customBaseUrl ?? defaultBaseUrl;

  static set customBaseUrl(String? url) {
    if (url != null && url.trim().isNotEmpty) {
      // Hapus trailing slash jika ada
      _customBaseUrl = url.trim().endsWith('/')
          ? url.trim().substring(0, url.trim().length - 1)
          : url.trim();
    } else {
      _customBaseUrl = null;
    }
    _isBaseUrlLoadedFromStorage = true;
    _dio?.options.baseUrl = baseUrl;
  }

  // ==========================================
  // Endpoints Auth & Identity
  // ==========================================
  static String get loginEndpoint => '$baseUrl/login';
  static String get logoutEndpoint => '$baseUrl/logout';
  static String get meEndpoint => '$baseUrl/me';
  static String get userEndpoint => '$baseUrl/user';

  // ==========================================
  // Endpoints Berkas Privat Terautentikasi
  // ==========================================
  static String fileMateriEndpoint(int materiId) =>
      '$baseUrl/file/materi/$materiId';
  static String fileTugasEndpoint(int tugasId) =>
      '$baseUrl/file/tugas/$tugasId';
  static String fileJawabanEndpoint(int nilaiId) =>
      '$baseUrl/file/jawaban/$nilaiId';

  // ==========================================
  // Endpoints Profile (Guru & Siswa)
  // ==========================================
  static String get profileEndpoint => '$baseUrl/profile';
  static String get profilePasswordEndpoint => '$baseUrl/profile/password';

  // ==========================================
  // Endpoints Notifikasi Interaktif
  // ==========================================
  static String get notifikasiEndpoint => '$baseUrl/notifikasi';
  static String notifikasiToggleEndpoint(int notifikasiId) =>
      '$baseUrl/notifikasi/$notifikasiId/toggle';
  static String notifikasiReadEndpoint(int notifikasiId) =>
      '$baseUrl/notifikasi/$notifikasiId/read';
  static String get notifikasiMarkAllReadEndpoint =>
      '$baseUrl/notifikasi/mark-all-read';
  static String get notifikasiTandaiSemuaDibacaEndpoint =>
      '$baseUrl/notifikasi/tandai-semua-dibaca';
  static String notifikasiDeleteEndpoint(int notifikasiId) =>
      '$baseUrl/notifikasi/$notifikasiId';
  static String get notifikasiClearAllEndpoint => '$baseUrl/notifikasi';

  // ==========================================
  // Endpoints Siswa
  // ==========================================
  static String get siswaDashboardEndpoint => '$baseUrl/siswa/dashboard';
  static String get siswaJadwalEndpoint => '$baseUrl/siswa/jadwal';

  // Mata Pelajaran & Materi Pembelajaran Siswa (routes/api.php: /siswa/mapel)
  static String get siswaMapelEndpoint => '$baseUrl/siswa/mapel';
  static String siswaMapelDetailEndpoint(int mapelId) =>
      '$baseUrl/siswa/mapel/$mapelId';
  // Alias backward-compatible untuk kode lama
  static String get siswaMateriEndpoint => siswaMapelEndpoint;
  static String siswaMateriByMapelEndpoint(int mapelId) =>
      siswaMapelDetailEndpoint(mapelId);

  // Tugas Siswa
  static String get siswaTugasEndpoint => '$baseUrl/siswa/tugas';
  static String siswaTugasDetailEndpoint(dynamic id) =>
      '$baseUrl/siswa/tugas/$id';
  static String siswaTugasKumpulkanEndpoint(dynamic id) =>
      '$baseUrl/siswa/tugas/$id/kumpulkan';

  // Kuis Petualangan & Power Siswa
  static String get siswaKuisEndpoint => '$baseUrl/siswa/kuis';
  static String get siswaKuisPanduanEndpoint => '$baseUrl/siswa/kuis/panduan';
  static String siswaKuisDetailEndpoint(int quizId) =>
      '$baseUrl/siswa/kuis/$quizId';
  static String siswaKuisKerjakanEndpoint(int quizId) =>
      '$baseUrl/siswa/kuis/$quizId/kerjakan';
  static String siswaKuisSimpanDraftEndpoint(int quizId) =>
      '$baseUrl/siswa/kuis/$quizId/simpan-draft';
  static String siswaKuisSubmitEndpoint(int quizId) =>
      '$baseUrl/siswa/kuis/$quizId/submit';
  static String siswaKuisHasilEndpoint(int quizId) =>
      '$baseUrl/siswa/kuis/$quizId/hasil';
  static String siswaKuisHasilPetualanganEndpoint(int quizId) =>
      '$baseUrl/siswa/kuis/$quizId/hasil-petualangan';
  static String siswaKuisPowersEndpoint(int quizId) =>
      '$baseUrl/siswa/kuis/$quizId/powers';
  static String siswaKuisPowersUseEndpoint(int quizId) =>
      '$baseUrl/siswa/kuis/$quizId/powers/use';
  static String siswaKuisPowersSecondChanceEndpoint(int quizId) =>
      '$baseUrl/siswa/kuis/$quizId/powers/second-chance';

  // Gacha & Inventory Banner Siswa
  static String get siswaGachaStatusEndpoint => '$baseUrl/siswa/gacha';
  static String get siswaGachaPanduanEndpoint => '$baseUrl/siswa/gacha/panduan';
  static String get siswaGachaPullEndpoint => '$baseUrl/siswa/gacha/pull';
  static String get siswaBannerEquipEndpoint => '$baseUrl/siswa/banner/equip';

  // Ujian Evaluasi Siswa (CBT)
  static String get siswaUjianEndpoint => '$baseUrl/siswa/ujian';
  static String siswaUjianDetailEndpoint(int ujianId) =>
      '$baseUrl/siswa/ujian/$ujianId';
  static String siswaUjianKonfirmasiEndpoint(int ujianId) =>
      '$baseUrl/siswa/ujian/$ujianId/konfirmasi';
  static String siswaUjianValidasiTokenEndpoint(int ujianId) =>
      '$baseUrl/siswa/ujian/$ujianId/validasi-token';
  static String siswaUjianKerjakanEndpoint(int ujianId) =>
      '$baseUrl/siswa/ujian/$ujianId/kerjakan';
  static String siswaUjianSimpanJawabanEndpoint(int ujianId) =>
      '$baseUrl/siswa/ujian/$ujianId/simpan-jawaban';
  static String siswaUjianSubmitEndpoint(int ujianId) =>
      '$baseUrl/siswa/ujian/$ujianId/submit';
  static String siswaUjianHasilEndpoint(int ujianId) =>
      '$baseUrl/siswa/ujian/$ujianId/hasil';
  static String siswaUjianPelanggaranEndpoint(int ujianId) =>
      '$baseUrl/siswa/ujian/$ujianId/pelanggaran';
  static String siswaUjianStatusSesiEndpoint(int ujianId) =>
      '$baseUrl/siswa/ujian/$ujianId/status-sesi';
  static String siswaUjianBukaKunciKodeEndpoint(int ujianId) =>
      '$baseUrl/siswa/ujian/$ujianId/buka-kunci-kode';

  // ==========================================
  // Endpoints Guru
  // ==========================================
  static String get guruDashboardEndpoint => '$baseUrl/guru/dashboard';
  static String get guruJadwalEndpoint => '$baseUrl/guru/jadwal';

  // Materi Guru
  static String get guruMateriEndpoint => '$baseUrl/guru/materi';
  static String get guruMateriOptionsEndpoint =>
      '$baseUrl/guru/materi/options';
  static String guruMateriDetailEndpoint(String idGrubMateri) =>
      '$baseUrl/guru/materi/$idGrubMateri';

  // Tugas Guru
  static String get guruTugasEndpoint => '$baseUrl/guru/tugas';
  static String get guruTugasOptionsEndpoint => '$baseUrl/guru/tugas/options';
  static String guruTugasDetailEndpoint(dynamic id) =>
      '$baseUrl/guru/tugas/$id';
  static String guruTugasKunciJawabanEndpoint(dynamic id) =>
      '$baseUrl/guru/tugas/$id/kunci-jawaban';
  static String guruTugasJawabanSiswaEndpoint(
    dynamic id,
    dynamic pengumpulanId,
  ) =>
      '$baseUrl/guru/tugas/$id/jawaban-siswa/$pengumpulanId';
  static String guruTugasNilaiEndpoint(dynamic id) =>
      '$baseUrl/guru/tugas/$id/nilai';
  static String guruPengumpulanNilaiEndpoint(dynamic id) =>
      '$baseUrl/guru/pengumpulan/$id/nilai';

  // Kuis Guru
  static String get guruKuisEndpoint => '$baseUrl/guru/kuis';
  static String get guruKuisOptionsEndpoint => '$baseUrl/guru/kuis/options';
  static String get guruKuisBulkDestroyEndpoint =>
      '$baseUrl/guru/kuis/bulk-destroy';
  static String guruKuisDetailEndpoint(int quizId) =>
      '$baseUrl/guru/kuis/$quizId';
  static String guruKuisToggleStatusEndpoint(int quizId) =>
      '$baseUrl/guru/kuis/$quizId/toggle-status';
  static String guruKuisSoalEndpoint(int quizId) =>
      '$baseUrl/guru/kuis/$quizId/soal';
  static String guruKuisSoalDetailEndpoint(int quizId, int soalId) =>
      '$baseUrl/guru/kuis/$quizId/soal/$soalId';

  // Ujian Guru
  static String get guruUjianEndpoint => '$baseUrl/guru/ujian';
  static String get guruUjianOptionsEndpoint => '$baseUrl/guru/ujian/options';
  static String get guruUjianStatusRealtimeEndpoint =>
      '$baseUrl/guru/ujian/status-realtime';
  static String get guruUjianLaporanEndpoint => '$baseUrl/guru/ujian-laporan';
  static String guruUjianDetailEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId';
  static String guruUjianPublishEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/publish';
  static String guruUjianScheduleEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/schedule';
  static String guruUjianUnpublishEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/unpublish';
  static String guruUjianDuplicateEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/duplicate';
  static String guruUjianToggleArchiveEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/toggle-archive';
  static String guruUjianMonitoringEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/monitoring';
  static String guruUjianMonitoringDataEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/monitoring/data';
  static String guruUjianUnlockPesertaEndpoint(int ujianId, int seleksiId) =>
      '$baseUrl/guru/ujian/$ujianId/peserta/$seleksiId/unlock';
  static String guruUjianForceSubmitPesertaEndpoint(
    int ujianId,
    int seleksiId,
  ) =>
      '$baseUrl/guru/ujian/$ujianId/peserta/$seleksiId/force-submit';
  static String guruUjianReopenPesertaEndpoint(int ujianId, int seleksiId) =>
      '$baseUrl/guru/ujian/$ujianId/peserta/$seleksiId/reopen';
  static String guruUjianResetTokenEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/reset-token';
  static String guruUjianAturSesiEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/atur-sesi';
  static String guruUjianRefreshUnlockCodeEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/refresh-unlock-code';
  static String guruUjianRekapEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/rekap';
  static String guruUjianKoreksiEssayEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/koreksi-essay';
  static String guruUjianSimpanNilaiEssayEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/simpan-nilai-essay';
  static String guruUjianDetailJawabanSiswaEndpoint(int ujianId, int siswaId) =>
      '$baseUrl/guru/ujian/$ujianId/peserta/$siswaId/jawaban';
  static String guruUjianBuatRemidiSusulanEndpoint(int ujianId) =>
      '$baseUrl/guru/ujian/$ujianId/buat-remidi-susulan';

  // Relokasi Aktivitas Guru
  static String get guruRelokasiEndpoint => '$baseUrl/guru/relokasi';

  /// Menyamakan scheme, host, dan port URL dari Laravel (misal `/api/file/...`
  /// atau `http://localhost:8000/api/file/...`) dengan [baseUrl] aktif agar
  /// selalu dapat diakses dari emulator maupun perangkat fisik.
  static String resolveUrl(String? rawUrl) => publicAssetUrl(rawUrl);

  /// Mengubah path aset publik relatif (misal: 'images/Banner/space-hero.gif')
  /// menjadi URL penuh '{BASE_URL}/{asset_path}' (tanpa '/api').
  static String publicAssetUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final clean = path.trim();
    final apiUri = Uri.tryParse(baseUrl);

    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      final assetUri = Uri.tryParse(clean);
      if (apiUri != null && assetUri != null && apiUri.host.isNotEmpty) {
        return assetUri
            .replace(
              scheme: apiUri.scheme,
              host: apiUri.host,
              port: apiUri.hasPort ? apiUri.port : null,
            )
            .toString();
      }
      return clean;
    }

    final rootUrl = baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    final normalizedPath = clean.startsWith('/') ? clean.substring(1) : clean;
    return '$rootUrl/$normalizedPath';
  }

  static String get gachaSummonGifUrl =>
      publicAssetUrl('images/Banner/pov-astronot-mendarat.gif');

  // Standar HTTP Headers
  static Map<String, String> defaultHeaders({String? token}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Instance Dio terpusat dengan Interceptor otomatis
  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: defaultHeaders(),
          responseType: ResponseType.json,
        ),
      );

      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Pastikan customBaseUrl dari storage sudah dimuat pada request pertama
            if (!_isBaseUrlLoadedFromStorage) {
              final savedBaseUrl = await StorageService.getCustomBaseUrl();
              if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
                customBaseUrl = savedBaseUrl;
              }
              _isBaseUrlLoadedFromStorage = true;
            }

            // Sinkronkan baseUrl terbaru
            options.baseUrl = baseUrl;

            // Sisipkan token Bearer secara otomatis jika belum diset manual
            if (!options.headers.containsKey('Authorization')) {
              final token = await StorageService.getToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }

            handler.next(options);
          },
        ),
      );
    }
    return _dio!;
  }
}
