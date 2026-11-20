import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/core/config/api_config.dart';

class ItemModel {
  final int id;
  final String kode;
  final String name;
  final String tagline;
  final String desc;
  final String detailEfek;
  final String tipeEfek;
  final String rarity;
  final String temaWarna;
  final IconData icon;
  final Color color;
  final int qty;
  final bool isOwned;

  const ItemModel({
    this.id = 0,
    this.kode = '',
    required this.name,
    this.tagline = '',
    required this.desc,
    this.detailEfek = '',
    this.tipeEfek = '',
    this.rarity = 'common',
    this.temaWarna = 'amber',
    required this.icon,
    required this.color,
    this.qty = 0,
    this.isOwned = true,
  });

  ItemModel copyWith({
    int? id,
    String? kode,
    String? name,
    String? tagline,
    String? desc,
    String? detailEfek,
    String? tipeEfek,
    String? rarity,
    String? temaWarna,
    IconData? icon,
    Color? color,
    int? qty,
    bool? isOwned,
  }) {
    return ItemModel(
      id: id ?? this.id,
      kode: kode ?? this.kode,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      desc: desc ?? this.desc,
      detailEfek: detailEfek ?? this.detailEfek,
      tipeEfek: tipeEfek ?? this.tipeEfek,
      rarity: rarity ?? this.rarity,
      temaWarna: temaWarna ?? this.temaWarna,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      qty: qty ?? this.qty,
      isOwned: isOwned ?? this.isOwned,
    );
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final kode = (json['kode'] ?? json['code'] ?? '').toString();
    final nama = (json['nama'] ?? json['name'] ?? _defaultPowerName(kode)).toString();
    final tagline = (json['tagline'] ?? '').toString();
    final deskripsi = (json['deskripsi'] ?? json['description'] ?? '').toString();
    final detailEfek = (json['detail_efek'] ?? '').toString();
    final tipeEfek = (json['tipe_efek'] ?? '').toString();
    final rarity = (json['rarity'] ?? 'rare').toString();
    final temaWarna = (json['tema_warna'] ?? _defaultPowerTheme(kode)).toString();
    final iconRaw = (json['icon'] ?? '').toString();

    final parsedQty = _parseInt(
      json['new_qty'] ??
          json['jumlah'] ??
          json['qty'] ??
          json['owned_qty'] ??
          json['user_qty'] ??
          json['stok'] ??
          json['stock'] ??
          json['count'] ??
          (json['pivot'] is Map
              ? (json['pivot']['jumlah'] ?? json['pivot']['qty'])
              : null) ??
          0,
    );
    final isOwned = json['is_owned'] is bool
        ? json['is_owned'] as bool
        : parsedQty > 0;

    final resolvedDesc = deskripsi.isNotEmpty
        ? deskripsi
        : (tagline.isNotEmpty ? tagline : _defaultPowerDesc(kode));

    return ItemModel(
      id: _parseInt(json['id']),
      kode: kode,
      name: nama,
      tagline: tagline,
      desc: resolvedDesc,
      detailEfek: detailEfek,
      tipeEfek: tipeEfek,
      rarity: rarity,
      temaWarna: temaWarna,
      icon: resolvePowerIcon(kode, iconRaw),
      color: resolveThemeColor(temaWarna, rarity: rarity),
      qty: parsedQty,
      isOwned: isOwned,
    );
  }

  static String _defaultPowerName(String kode) {
    switch (kode) {
      case 'double_side_knife':
        return 'Double Side Knife';
      case 'two_x_score':
        return '2x Score';
      case 'second_chance':
        return 'Second Chance';
      case 'lucky_clover':
        return 'Lucky Clover';
      case 'remove_wrong_answer':
        return 'Remove Wrong Answer';
      default:
        return 'Item Power';
    }
  }

  static String _defaultPowerTheme(String kode) {
    switch (kode) {
      case 'double_side_knife':
        return 'rose';
      case 'two_x_score':
        return 'amber';
      case 'second_chance':
        return 'cyan';
      case 'lucky_clover':
        return 'emerald';
      case 'remove_wrong_answer':
        return 'purple';
      default:
        return 'amber';
    }
  }

  static String _defaultPowerDesc(String kode) {
    switch (kode) {
      case 'double_side_knife':
        return 'Benar dapat 2x/2.5x poin, salah penalti -0.5x poin.';
      case 'two_x_score':
        return 'Benar dapat 2x poin tanpa penalti salah.';
      case 'second_chance':
        return 'Menahan 1x pilihan salah dan mengizinkan pilih ulang.';
      case 'lucky_clover':
        return 'Menampilkan teks petunjuk (hint) pada soal.';
      case 'remove_wrong_answer':
        return 'Mengeliminasi hingga 2 opsi jawaban yang salah.';
      default:
        return 'Item kekuatan khusus untuk membantu pengerjaan kuis.';
    }
  }

  static IconData resolvePowerIcon(String kode, [String iconClass = '']) {
    final lowerKode = kode.toLowerCase();
    final lowerIcon = iconClass.toLowerCase();

    if (lowerKode == 'double_side_knife' ||
        lowerIcon.contains('skull') ||
        lowerIcon.contains('dagger')) {
      return Icons.dangerous_rounded;
    }
    if (lowerKode == 'two_x_score' ||
        lowerIcon.contains('bolt') ||
        lowerIcon.contains('star') ||
        lowerIcon.contains('angles-up')) {
      return Icons.bolt_rounded;
    }
    if (lowerKode == 'second_chance' ||
        lowerIcon.contains('shield') ||
        lowerIcon.contains('heart') ||
        lowerIcon.contains('rotate')) {
      return Icons.shield_rounded;
    }
    if (lowerKode == 'lucky_clover' ||
        lowerIcon.contains('clover') ||
        lowerIcon.contains('leaf') ||
        lowerIcon.contains('lightbulb')) {
      return Icons.eco_rounded;
    }
    if (lowerKode == 'remove_wrong_answer' ||
        lowerIcon.contains('eraser') ||
        lowerIcon.contains('scissors') ||
        lowerIcon.contains('filter') ||
        lowerIcon.contains('ban')) {
      return Icons.auto_fix_high_rounded;
    }
    return Icons.auto_awesome_rounded;
  }

  static Color resolveThemeColor(String temaWarna, {String rarity = ''}) {
    switch (temaWarna.toLowerCase()) {
      case 'rose':
      case 'red':
        return const Color(0xFFF43F5E);
      case 'amber':
      case 'yellow':
      case 'gold':
      case 'orange':
        return const Color(0xFFF59E0B);
      case 'emerald':
      case 'green':
        return const Color(0xFF10B981);
      case 'cyan':
      case 'blue':
      case 'sky':
        return const Color(0xFF06B6D4);
      case 'purple':
      case 'violet':
      case 'indigo':
        return const Color(0xFFA855F7);
      default:
        switch (rarity.toLowerCase()) {
          case 'legendary':
            return const Color(0xFFF59E0B);
          case 'epic':
            return const Color(0xFFA855F7);
          case 'rare':
            return const Color(0xFF3B82F6);
          default:
            return const Color(0xFF10B981);
        }
    }
  }
}

/// Model Banner Dashboard dari sistem Gacha & Inventory
class BannerItemModel {
  final int id;
  final String kode;
  final String nama;
  final String deskripsi;
  final String? gifUrl;
  final String theme;
  final String rarity;
  final String badge;
  final bool isUnlocked;
  final bool isEquipped;
  final bool isPity;

  const BannerItemModel({
    this.id = 0,
    required this.kode,
    required this.nama,
    this.deskripsi = '',
    this.gifUrl,
    this.theme = 'dark',
    this.rarity = 'common',
    this.badge = 'Default',
    this.isUnlocked = false,
    this.isEquipped = false,
    this.isPity = false,
  });

  bool get isDefault =>
      kode.toLowerCase() == 'default' ||
      gifUrl == null ||
      gifUrl!.trim().isEmpty;

  /// URL publik lengkap ke file GIF di server: '{BASE_URL}/{gif_url}'
  String get fullGifUrl => isDefault ? '' : ApiConfig.publicAssetUrl(gifUrl);

  Color get rarityColor {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return const Color(0xFFF59E0B);
      case 'epic':
        return const Color(0xFFA855F7);
      case 'rare':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF64748B);
    }
  }

  BannerItemModel copyWith({
    int? id,
    String? kode,
    String? nama,
    String? deskripsi,
    String? gifUrl,
    String? theme,
    String? rarity,
    String? badge,
    bool? isUnlocked,
    bool? isEquipped,
    bool? isPity,
  }) {
    return BannerItemModel(
      id: id ?? this.id,
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      gifUrl: gifUrl ?? this.gifUrl,
      theme: theme ?? this.theme,
      rarity: rarity ?? this.rarity,
      badge: badge ?? this.badge,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isEquipped: isEquipped ?? this.isEquipped,
      isPity: isPity ?? this.isPity,
    );
  }

  factory BannerItemModel.fromJson(Map<String, dynamic> json) {
    final rawGif = json['gif_url']?.toString().trim();
    return BannerItemModel(
      id: _parseInt(json['id']),
      kode: (json['kode'] ?? json['code'] ?? 'default').toString(),
      nama: (json['nama'] ?? json['name'] ?? 'Banner Dashboard').toString(),
      deskripsi: (json['deskripsi'] ?? json['description'] ?? '').toString(),
      gifUrl: (rawGif == null || rawGif.isEmpty || rawGif == 'null')
          ? null
          : rawGif,
      theme: (json['theme'] ?? 'dark').toString(),
      rarity: (json['rarity'] ?? 'common').toString(),
      badge: (json['badge'] ?? json['rarity'] ?? 'Banner').toString(),
      isUnlocked: _parseBool(json['is_unlocked'], defaultValue: true),
      isEquipped: _parseBool(json['is_equipped'], defaultValue: false),
      isPity: _parseBool(json['is_pity'], defaultValue: false),
    );
  }
}

/// Model Status Gacha & Koleksi Banner Siswa dari GET /api/siswa/gacha
class GachaStatusModel {
  final int koin;
  final int pityCounter;
  final int pityMax;
  final int harga1x;
  final int harga10x;
  final String equippedBanner;
  final BannerItemModel? activeBanner;
  final List<BannerItemModel> bannersList;
  final List<ItemModel> powersList;

  const GachaStatusModel({
    required this.koin,
    required this.pityCounter,
    required this.pityMax,
    required this.harga1x,
    required this.harga10x,
    required this.equippedBanner,
    this.activeBanner,
    this.bannersList = const [],
    this.powersList = const [],
  });

  factory GachaStatusModel.fromJson(Map<String, dynamic> json) {
    final equippedCode = (json['equipped_banner'] ?? 'default').toString();

    BannerItemModel? active;
    if (json['active_banner'] is Map<String, dynamic>) {
      active = BannerItemModel.fromJson(
        json['active_banner'] as Map<String, dynamic>,
      ).copyWith(isEquipped: true, isUnlocked: true);
    }

    final rawBanners = json['banners_list'] is List
        ? json['banners_list'] as List
        : (json['banners'] is List ? json['banners'] as List : const []);
    final banners = rawBanners
        .whereType<Map<String, dynamic>>()
        .map(BannerItemModel.fromJson)
        .toList();

    if (active == null && banners.isNotEmpty) {
      active = banners.firstWhere(
        (b) => b.isEquipped || b.kode == equippedCode,
        orElse: () => banners.first,
      );
    }

    final rawPowers = json['powers_list'] is List
        ? json['powers_list'] as List
        : (json['powers'] is List
            ? json['powers'] as List
            : (json['inventories'] is List
                ? json['inventories'] as List
                : const []));
    final powers = rawPowers
        .whereType<Map<String, dynamic>>()
        .map(ItemModel.fromJson)
        .toList();

    return GachaStatusModel(
      koin: _parseInt(json['koin'] ?? json['total_koin_siswa'], defaultValue: 0),
      pityCounter: _parseInt(json['pity_counter'], defaultValue: 0),
      pityMax: _parseInt(json['pity_max'], defaultValue: 30),
      harga1x: _parseInt(json['harga_1x'], defaultValue: 20),
      harga10x: _parseInt(json['harga_10x'], defaultValue: 180),
      equippedBanner: equippedCode,
      activeBanner: active,
      bannersList: banners,
      powersList: powers,
    );
  }
}

/// Model Panduan & Katalog Item Gacha dari GET /api/siswa/gacha/panduan
class GachaPanduanModel {
  final int pityMax;
  final int harga1x;
  final int harga10x;
  final List<ItemModel> powers;
  final List<BannerItemModel> banners;

  const GachaPanduanModel({
    this.pityMax = 30,
    this.harga1x = 20,
    this.harga10x = 180,
    this.powers = const [],
    this.banners = const [],
  });

  factory GachaPanduanModel.fromJson(Map<String, dynamic> json) {
    final rawPowers = json['powers'] is List ? json['powers'] as List : const [];
    final rawBanners =
        json['banners'] is List ? json['banners'] as List : const [];

    return GachaPanduanModel(
      pityMax: _parseInt(json['pity_max'], defaultValue: 30),
      harga1x: _parseInt(json['harga_1x'], defaultValue: 20),
      harga10x: _parseInt(json['harga_10x'], defaultValue: 180),
      powers: rawPowers
          .whereType<Map<String, dynamic>>()
          .map(ItemModel.fromJson)
          .toList(),
      banners: rawBanners
          .whereType<Map<String, dynamic>>()
          .map(BannerItemModel.fromJson)
          .toList(),
    );
  }
}

/// Model 1 hasil roll dari POST /api/siswa/gacha/pull
class GachaPullRollItemModel {
  final int rollNumber;
  final ItemModel? power;
  final BannerItemModel? banner;

  const GachaPullRollItemModel({
    required this.rollNumber,
    this.power,
    this.banner,
  });

  bool get hasBannerJackpot => banner != null;

  factory GachaPullRollItemModel.fromJson(Map<String, dynamic> json) {
    return GachaPullRollItemModel(
      rollNumber: _parseInt(json['roll_number'], defaultValue: 1),
      power: json['power'] is Map<String, dynamic>
          ? ItemModel.fromJson(json['power'] as Map<String, dynamic>)
          : null,
      banner: json['banner'] is Map<String, dynamic>
          ? BannerItemModel.fromJson(
              json['banner'] as Map<String, dynamic>,
            ).copyWith(isUnlocked: true)
          : null,
    );
  }
}

/// Model Response utama dari POST /api/siswa/gacha/pull
class GachaPullResponseModel {
  final int rolls;
  final int cost;
  final int sisaKoin;
  final int pityCounter;
  final int pityMax;
  final List<GachaPullRollItemModel> items;

  const GachaPullResponseModel({
    required this.rolls,
    required this.cost,
    required this.sisaKoin,
    required this.pityCounter,
    required this.pityMax,
    required this.items,
  });

  factory GachaPullResponseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] is List ? json['items'] as List : const [];
    return GachaPullResponseModel(
      rolls: _parseInt(json['rolls'], defaultValue: 1),
      cost: _parseInt(json['cost'], defaultValue: 20),
      sisaKoin: _parseInt(json['sisa_koin'], defaultValue: 0),
      pityCounter: _parseInt(json['pity_counter'], defaultValue: 0),
      pityMax: _parseInt(json['pity_max'], defaultValue: 30),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(GachaPullRollItemModel.fromJson)
          .toList(),
    );
  }
}

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value != null) {
    return int.tryParse(value.toString()) ?? defaultValue;
  }
  return defaultValue;
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return defaultValue;
}

/// Daftar 5 Item Power resmi LearnPoint sebagai fallback/default katalog
final List<ItemModel> item = [
  ItemModel(
    id: 1,
    kode: 'double_side_knife',
    name: 'Double Side Knife',
    tagline: 'Risiko Tinggi, Hadiah Lebih Besar',
    desc: 'Benar dapat 2x/2.5x poin, salah penalti -0.5x poin.',
    tipeEfek: 'multiplier',
    rarity: 'rare',
    temaWarna: 'rose',
    icon: Icons.dangerous_rounded,
    color: const Color(0xFFF43F5E),
    qty: 0,
  ),
  ItemModel(
    id: 2,
    kode: 'two_x_score',
    name: '2x Score',
    tagline: 'Gandakan Poin Tanpa Risiko',
    desc: 'Benar dapat 2x poin tanpa penalti salah.',
    tipeEfek: 'multiplier',
    rarity: 'epic',
    temaWarna: 'amber',
    icon: Icons.bolt_rounded,
    color: const Color(0xFFF59E0B),
    qty: 0,
  ),
  ItemModel(
    id: 3,
    kode: 'second_chance',
    name: 'Second Chance',
    tagline: 'Kesempatan Kedua Saat Salah',
    desc: 'Menahan 1x pilihan salah dan mengizinkan pilih ulang.',
    tipeEfek: 'second_chance',
    rarity: 'epic',
    temaWarna: 'cyan',
    icon: Icons.shield_rounded,
    color: const Color(0xFF06B6D4),
    qty: 0,
  ),
  ItemModel(
    id: 4,
    kode: 'lucky_clover',
    name: 'Lucky Clover',
    tagline: 'Petunjuk Rahasia Soal',
    desc: 'Menampilkan teks petunjuk (hint) pada soal.',
    tipeEfek: 'hint',
    rarity: 'rare',
    temaWarna: 'emerald',
    icon: Icons.eco_rounded,
    color: const Color(0xFF10B981),
    qty: 0,
  ),
  ItemModel(
    id: 5,
    kode: 'remove_wrong_answer',
    name: 'Remove Wrong Answer',
    tagline: 'Singkirkan Opsi Pengecoh',
    desc: 'Mengeliminasi hingga 2 opsi jawaban salah.',
    tipeEfek: 'eliminate_options',
    rarity: 'rare',
    temaWarna: 'purple',
    icon: Icons.auto_fix_high_rounded,
    color: const Color(0xFFA855F7),
    qty: 0,
  ),
];
