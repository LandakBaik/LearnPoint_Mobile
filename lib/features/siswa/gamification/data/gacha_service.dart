import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/core/services/storage_service.dart';
import 'package:learnpoint_mobile/features/siswa/gamification/models/item_model.dart';

class GachaException implements Exception {
  final String message;
  final int? statusCode;

  const GachaException(this.message, {this.statusCode});

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

class GachaService {
  static const String _powerQtyCacheKey = 'cached_student_power_qty_v1';
  static int? _cachedQuizIdForPowers;
  static bool _isCacheLoaded = false;

  /// State reaktif agar saldo koin, banner aktif, koleksi banner, dan stok power
  /// otomatis tersinkronisasi antara Gacha, Inventory, dan Dashboard Siswa.
  static final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<BannerItemModel?> activeBannerNotifier =
      ValueNotifier<BannerItemModel?>(null);
  static final ValueNotifier<List<BannerItemModel>> bannersNotifier =
      ValueNotifier<List<BannerItemModel>>(const []);
  static final ValueNotifier<List<ItemModel>> powersNotifier =
      ValueNotifier<List<ItemModel>>(List<ItemModel>.from(item));

  /// Mengambil status gacha, saldo koin, pity counter, active_banner, & banners_list
  /// dari GET /api/siswa/gacha, serta memuat jumlah stok item Power riil siswa.
  static Future<GachaStatusModel> fetchGachaStatus({
    bool includePanduanPowers = false,
  }) async {
    await _loadCachedPowerQuantities();

    final body = await _get('/siswa/gacha');
    final data = _extractDataMap(body);
    final status = GachaStatusModel.fromJson(data);

    coinsNotifier.value = status.koin;
    if (status.activeBanner != null) {
      activeBannerNotifier.value = status.activeBanner;
    }
    if (status.bannersList.isNotEmpty) {
      bannersNotifier.value = status.bannersList;
    }

    final bool hasRealPowerQtyInGacha =
        status.powersList.any((p) => p.qty > 0) ||
        _rawContainsExplicitQty(data['powers_list']) ||
        _rawContainsExplicitQty(data['powers']) ||
        _rawContainsExplicitQty(data['inventories']);

    if (status.powersList.isNotEmpty) {
      _mergePowersList(
        status.powersList,
        overwriteZeroQty: hasRealPowerQtyInGacha,
      );
      if (hasRealPowerQtyInGacha) {
        await _saveCachedPowerQuantities();
      }
    }

    if (includePanduanPowers || !hasRealPowerQtyInGacha) {
      // 1. Muat katalog deskripsi power dari /siswa/gacha/panduan
      try {
        await fetchGachaPanduan();
      } catch (_) {}

      // 2. Karena stok riil (qty/jumlah dari tabel inventories) berada di endpoint
      //    GET /api/siswa/kuis/{quizId}/powers, ambil stok riil dari sana.
      try {
        await fetchStudentPowerInventory();
      } catch (_) {}
    }

    return status;
  }

  /// Mengambil stok riil 5 Item Power siswa (`qty` / `jumlah`) dari tabel `inventories`
  /// melalui endpoint `GET /api/siswa/kuis/{quizId}/powers` (atau `/siswa/kuis`).
  static Future<List<ItemModel>> fetchStudentPowerInventory({
    int? quizId,
  }) async {
    await _loadCachedPowerQuantities();

    int? targetQuizId = quizId ?? _cachedQuizIdForPowers;

    // Jika belum tahu quizId yang valid di database, cari dari GET /api/siswa/kuis
    if (targetQuizId == null) {
      targetQuizId = await _resolveAnyValidQuizId();
    }

    // Kumpulkan kandidat quizId untuk dicoba (targetQuizId dari API kuis, lalu fallback ID 1)
    final candidateIds = <int>{
      if (targetQuizId != null && targetQuizId > 0) targetQuizId,
      1,
    };

    for (final id in candidateIds) {
      try {
        final body = await _get('/siswa/kuis/$id/powers');
        final data = _extractDataMap(body);
        final rawPowers = data['powers'];
        if (rawPowers is List && rawPowers.isNotEmpty) {
          _cachedQuizIdForPowers = id;
          final parsedPowers = rawPowers
              .whereType<Map<String, dynamic>>()
              .map(ItemModel.fromJson)
              .toList();

          _mergePowersList(parsedPowers, overwriteZeroQty: true);
          await _saveCachedPowerQuantities();
          return powersNotifier.value;
        }
      } catch (_) {
        // Lanjut coba kandidat berikutnya jika quizId tidak ditemukan
      }
    }

    return powersNotifier.value;
  }

  /// Mencari satu `quizId` yang valid dari `GET /api/siswa/kuis` agar bisa
  /// memanggil `GET /api/siswa/kuis/{quizId}/powers`.
  static Future<int?> _resolveAnyValidQuizId() async {
    try {
      final body = await _get('/siswa/kuis');
      final foundId = _findQuizIdRecursively(body['data'] ?? body);
      if (foundId != null && foundId > 0) {
        _cachedQuizIdForPowers = foundId;
        return foundId;
      }
    } catch (_) {}
    return null;
  }

  static int? _findQuizIdRecursively(dynamic node) {
    if (node is List) {
      for (final element in node) {
        final found = _findQuizIdRecursively(element);
        if (found != null) return found;
      }
    } else if (node is Map) {
      // Cek key eksplisit quiz_id / kuis_id terlebih dahulu
      for (final key in ['quiz_id', 'kuis_id', 'id_kuis']) {
        final val = int.tryParse((node[key] ?? '').toString());
        if (val != null && val > 0) return val;
      }

      // Jika objek ini adalah objek kuis (punya judul/title/total_soal/levels/arcs dan id)
      final hasQuizSignature = node.containsKey('judul') ||
          node.containsKey('judul_kuis') ||
          node.containsKey('total_soal') ||
          node.containsKey('jumlah_soal') ||
          node.containsKey('durasi') ||
          node.containsKey('arcs') ||
          node.containsKey('levels');
      if (hasQuizSignature && node['id'] != null) {
        final val = int.tryParse(node['id'].toString());
        if (val != null && val > 0) return val;
      }

      // Telusuri nested list seperti 'quizzes', 'kuis', 'items', 'planets', 'mapels'
      for (final entry in node.entries) {
        if (entry.value is List || entry.value is Map) {
          final found = _findQuizIdRecursively(entry.value);
          if (found != null) return found;
        }
      }

      // Fallback terakhir jika map di dalam list punya 'id'
      if (node['id'] != null) {
        final val = int.tryParse(node['id'].toString());
        if (val != null && val > 0) return val;
      }
    }
    return null;
  }

  /// Mengambil panduan & katalog item gacha (Power & Banner)
  /// dari GET /api/siswa/gacha/panduan.
  static Future<GachaPanduanModel> fetchGachaPanduan() async {
    await _loadCachedPowerQuantities();

    final body = await _get('/siswa/gacha/panduan');
    final data = _extractDataMap(body);
    final panduan = GachaPanduanModel.fromJson(data);

    if (panduan.powers.isNotEmpty) {
      final hasExplicitQty = _rawContainsExplicitQty(data['powers']);
      _mergePowersList(
        panduan.powers,
        overwriteZeroQty: hasExplicitQty,
      );
      if (hasExplicitQty) {
        await _saveCachedPowerQuantities();
      }
    }
    if (bannersNotifier.value.isEmpty && panduan.banners.isNotEmpty) {
      bannersNotifier.value = panduan.banners;
    }

    return panduan;
  }

  /// Melakukan tarik / pull gacha (1x atau 10x) ke POST /api/siswa/gacha/pull.
  static Future<GachaPullResponseModel> pullGacha(int rolls) async {
    await _loadCachedPowerQuantities();

    final body = await _post(
      '/siswa/gacha/pull',
      data: {'rolls': rolls},
    );
    final data = _extractDataMap(body);
    final result = GachaPullResponseModel.fromJson(data);

    // Sinkronkan sisa koin terbaru
    coinsNotifier.value = result.sisaKoin;

    // Perbarui stok power dan status unlock banner berdasarkan hasil pull
    final updatedPowers = List<ItemModel>.from(powersNotifier.value);
    final updatedBanners = List<BannerItemModel>.from(bannersNotifier.value);

    for (final pulled in result.items) {
      if (pulled.power != null) {
        final p = pulled.power!;
        final idx = updatedPowers.indexWhere(
          (existing) =>
              (existing.kode.isNotEmpty && existing.kode == p.kode) ||
              (existing.id != 0 && existing.id == p.id),
        );
        if (idx != -1) {
          updatedPowers[idx] = updatedPowers[idx].copyWith(
            qty: p.qty > 0 ? p.qty : updatedPowers[idx].qty + 1,
            isOwned: true,
          );
        } else {
          updatedPowers.add(p.copyWith(isOwned: true));
        }
      }

      if (pulled.banner != null) {
        final b = pulled.banner!;
        final bIdx =
            updatedBanners.indexWhere((existing) => existing.kode == b.kode);
        if (bIdx != -1) {
          updatedBanners[bIdx] =
              updatedBanners[bIdx].copyWith(isUnlocked: true);
        } else {
          updatedBanners.add(b.copyWith(isUnlocked: true));
        }
      }
    }

    powersNotifier.value = updatedPowers;
    if (updatedBanners.isNotEmpty) {
      bannersNotifier.value = updatedBanners;
    }

    await _saveCachedPowerQuantities();

    return result;
  }

  /// Memasang (equip) banner dashboard via POST /api/siswa/banner/equip.
  static Future<BannerItemModel?> equipBanner(String bannerCode) async {
    final body = await _post(
      '/siswa/banner/equip',
      data: {'banner_code': bannerCode},
    );
    final data = _extractDataMap(body);
    final equippedCode = (data['equipped_banner'] ?? bannerCode).toString();

    BannerItemModel? equippedBanner;
    if (data['banner_data'] is Map<String, dynamic>) {
      equippedBanner = BannerItemModel.fromJson(
        data['banner_data'] as Map<String, dynamic>,
      ).copyWith(isUnlocked: true, isEquipped: true);
    }

    // Perbarui daftar banner di notifier
    final currentList = bannersNotifier.value;
    if (currentList.isNotEmpty) {
      final updatedList = currentList.map((b) {
        final isMatch = b.kode == equippedCode;
        if (isMatch && equippedBanner == null) {
          equippedBanner = b.copyWith(isEquipped: true, isUnlocked: true);
        }
        return b.copyWith(isEquipped: isMatch);
      }).toList();
      bannersNotifier.value = updatedList;
    }

    if (equippedBanner != null) {
      activeBannerNotifier.value = equippedBanner;
    }

    return equippedBanner;
  }

  static bool _rawContainsExplicitQty(dynamic rawList) {
    if (rawList is! List || rawList.isEmpty) return false;
    for (final item in rawList) {
      if (item is Map) {
        if (item.containsKey('qty') ||
            item.containsKey('jumlah') ||
            item.containsKey('new_qty') ||
            item.containsKey('owned_qty') ||
            item.containsKey('user_qty') ||
            item.containsKey('stok') ||
            item.containsKey('stock')) {
          return true;
        }
      }
    }
    return false;
  }

  static void _mergePowersList(
    List<ItemModel> incoming, {
    bool overwriteZeroQty = false,
  }) {
    final Map<String, ItemModel> byCode = {
      for (final p in powersNotifier.value)
        if (p.kode.isNotEmpty) p.kode: p,
    };

    for (final inc in incoming) {
      if (inc.kode.isNotEmpty) {
        final prev = byCode[inc.kode];
        final resolvedQty = overwriteZeroQty
            ? inc.qty
            : (inc.qty > 0 ? inc.qty : (prev?.qty ?? 0));

        byCode[inc.kode] = inc.copyWith(
          qty: resolvedQty,
          isOwned: resolvedQty > 0,
          desc: inc.desc.isNotEmpty ? inc.desc : (prev?.desc ?? ''),
          tagline: inc.tagline.isNotEmpty ? inc.tagline : (prev?.tagline ?? ''),
        );
      }
    }

    if (byCode.isNotEmpty) {
      powersNotifier.value = byCode.values.toList();
    } else {
      powersNotifier.value = incoming;
    }
  }

  static Future<void> _loadCachedPowerQuantities() async {
    if (_isCacheLoaded) return;
    _isCacheLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_powerQtyCacheKey);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final updated = powersNotifier.value.map((p) {
          final cachedQty = int.tryParse((decoded[p.kode] ?? '').toString());
          if (cachedQty != null) {
            return p.copyWith(qty: cachedQty, isOwned: cachedQty > 0);
          }
          return p;
        }).toList();
        powersNotifier.value = updated;
      }
    } catch (_) {}
  }

  static Future<void> _saveCachedPowerQuantities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = <String, int>{
        for (final p in powersNotifier.value)
          if (p.kode.isNotEmpty) p.kode: p.qty,
      };
      await prefs.setString(_powerQtyCacheKey, jsonEncode(map));
    } catch (_) {}
  }

  static Map<String, dynamic> _extractDataMap(Map<String, dynamic> body) {
    if (body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body;
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    await _ensureAuthenticated();
    try {
      final response = await ApiConfig.dio.get(path);
      final body = _normalizeData(response.data);
      if (body['success'] == false) {
        throw GachaException(
          (body['message'] ?? 'Gagal memuat data gacha.').toString(),
          statusCode: response.statusCode,
        );
      }
      return body;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    await _ensureAuthenticated();
    try {
      final response = await ApiConfig.dio.post(path, data: data);
      final body = _normalizeData(response.data);
      if (body['success'] == false) {
        throw GachaException(
          (body['message'] ?? 'Permintaan gacha gagal diproses.').toString(),
          statusCode: response.statusCode,
        );
      }
      return body;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static Future<void> _ensureAuthenticated() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw const GachaException(
        'Sesi login tidak ditemukan. Silakan login kembali.',
        statusCode: 401,
      );
    }
  }

  static GachaException _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final body = _normalizeData(e.response?.data);
    final serverMessage = body['message']?.toString();

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const GachaException(
          'Server tidak merespons. Periksa koneksi atau server Laravel.',
        );
      case DioExceptionType.connectionError:
        return GachaException(
          'Tidak dapat terhubung ke server (${ApiConfig.baseUrl}).',
        );
      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          return const GachaException(
            'Sesi login telah berakhir. Silakan login kembali.',
            statusCode: 401,
          );
        }
        return GachaException(
          serverMessage ?? 'Permintaan gagal diproses ($statusCode).',
          statusCode: statusCode,
        );
      default:
        return GachaException(
          serverMessage ?? 'Terjadi gangguan jaringan. Silakan coba lagi.',
          statusCode: statusCode,
        );
    }
  }

  static Map<String, dynamic> _normalizeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        return {};
      }
    }
    return {};
  }
}
