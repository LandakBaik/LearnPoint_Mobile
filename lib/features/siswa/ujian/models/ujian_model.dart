class UjianItem {
  final int id;
  final String judul;
  final String? kisiKisi;
  final String jenisUjian;
  final int durasiMenit;
  final int totalSoal;
  final double kkm;
  final bool tampilkanNilai;
  final int sesi;
  final String status; // scheduled, published, completed, unpublished, draft
  final String statusLabel;
  final String? waktuMulai;
  final String? waktuMulaiSesi;
  final String? deadline;
  final String mapel;
  final String kelas;
  final String guru;
  final bool sudahMulai;
  final bool sudahDikerjakan;
  final String? statusSesi;
  final String? waktuSelesai;
  final double? nilaiSiswa;

  const UjianItem({
    required this.id,
    required this.judul,
    this.kisiKisi,
    this.jenisUjian = 'reguler',
    required this.durasiMenit,
    required this.totalSoal,
    required this.kkm,
    required this.tampilkanNilai,
    required this.sesi,
    required this.status,
    required this.statusLabel,
    this.waktuMulai,
    this.waktuMulaiSesi,
    this.deadline,
    required this.mapel,
    required this.kelas,
    required this.guru,
    required this.sudahMulai,
    required this.sudahDikerjakan,
    this.statusSesi,
    this.waktuSelesai,
    this.nilaiSiswa,
  });

  factory UjianItem.fromJson(Map<String, dynamic> json) {
    return UjianItem(
      id: _toInt(json['id']),
      judul: json['judul']?.toString() ?? 'Tanpa Judul',
      kisiKisi: json['kisi_kisi']?.toString(),
      jenisUjian: json['jenis_ujian']?.toString() ?? 'reguler',
      durasiMenit: _toInt(json['durasi_menit'], fallback: 60),
      totalSoal: _toInt(json['total_soal']),
      kkm: _toDouble(json['kkm'], fallback: 75),
      tampilkanNilai: json['tampilkan_nilai'] == true || json['tampilkan_nilai'] == 1,
      sesi: _toInt(json['sesi'], fallback: 1),
      status: json['status']?.toString() ?? 'draft',
      statusLabel: json['status_label']?.toString() ?? '-',
      waktuMulai: json['waktu_mulai']?.toString(),
      waktuMulaiSesi: json['waktu_mulai_sesi']?.toString(),
      deadline: json['deadline']?.toString(),
      mapel: json['mapel']?.toString() ?? 'Mata Pelajaran',
      kelas: json['kelas']?.toString() ?? '-',
      guru: json['guru']?.toString() ?? 'Guru Pengampu',
      sudahMulai: json['sudah_mulai'] == true,
      sudahDikerjakan: json['sudah_dikerjakan'] == true,
      statusSesi: json['status_sesi']?.toString(),
      waktuSelesai: json['waktu_selesai']?.toString(),
      nilaiSiswa: json['nilai_siswa'] != null ? _toDouble(json['nilai_siswa']) : null,
    );
  }
}

class UjianDetail {
  final int id;
  final String judul;
  final String? kisiKisi;
  final String jenisUjian;
  final int durasiMenit;
  final double kkm;
  final bool tampilkanNilai;
  final int sesi;
  final String status;
  final String statusLabel;
  final String? waktuMulai;
  final String? waktuMulaiSesi;
  final String? batasAkhirSesi;
  final String? deadline;
  final String mapel;
  final String kelas;
  final String guru;
  final bool sudahMulai;
  final bool sudahDikerjakan;
  final String? statusSesi;
  final double? nilaiSiswa;
  final int singleChoiceCount;
  final int multipleChoiceCount;
  final int essayCount;
  final int matchingCount;
  final int totalSoal;
  final double totalPoin;

  const UjianDetail({
    required this.id,
    required this.judul,
    this.kisiKisi,
    required this.jenisUjian,
    required this.durasiMenit,
    required this.kkm,
    required this.tampilkanNilai,
    required this.sesi,
    required this.status,
    required this.statusLabel,
    this.waktuMulai,
    this.waktuMulaiSesi,
    this.batasAkhirSesi,
    this.deadline,
    required this.mapel,
    required this.kelas,
    required this.guru,
    required this.sudahMulai,
    required this.sudahDikerjakan,
    this.statusSesi,
    this.nilaiSiswa,
    required this.singleChoiceCount,
    required this.multipleChoiceCount,
    required this.essayCount,
    required this.matchingCount,
    required this.totalSoal,
    required this.totalPoin,
  });

  factory UjianDetail.fromJson(Map<String, dynamic> json) {
    final ringkasan = json['ringkasan_tipe'] is Map
        ? Map<String, dynamic>.from(json['ringkasan_tipe'])
        : <String, dynamic>{};

    return UjianDetail(
      id: _toInt(json['id']),
      judul: json['judul']?.toString() ?? 'Tanpa Judul',
      kisiKisi: json['kisi_kisi']?.toString(),
      jenisUjian: json['jenis_ujian']?.toString() ?? 'reguler',
      durasiMenit: _toInt(json['durasi_menit'], fallback: 60),
      kkm: _toDouble(json['kkm'], fallback: 75),
      tampilkanNilai: json['tampilkan_nilai'] == true || json['tampilkan_nilai'] == 1,
      sesi: _toInt(json['sesi'], fallback: 1),
      status: json['status']?.toString() ?? 'draft',
      statusLabel: json['status_label']?.toString() ?? '-',
      waktuMulai: json['waktu_mulai']?.toString(),
      waktuMulaiSesi: json['waktu_mulai_sesi']?.toString(),
      batasAkhirSesi: json['batas_akhir_sesi']?.toString(),
      deadline: json['deadline']?.toString(),
      mapel: json['mapel']?.toString() ?? 'Mata Pelajaran',
      kelas: json['kelas']?.toString() ?? '-',
      guru: json['guru']?.toString() ?? 'Guru Pengampu',
      sudahMulai: json['sudah_mulai'] == true,
      sudahDikerjakan: json['sudah_dikerjakan'] == true,
      statusSesi: json['status_sesi']?.toString(),
      nilaiSiswa: json['nilai_siswa'] != null ? _toDouble(json['nilai_siswa']) : null,
      singleChoiceCount: _toInt(ringkasan['single_choice']),
      multipleChoiceCount: _toInt(ringkasan['multiple_choice']),
      essayCount: _toInt(ringkasan['essay']),
      matchingCount: _toInt(ringkasan['matching']),
      totalSoal: _toInt(ringkasan['total_soal']),
      totalPoin: _toDouble(ringkasan['total_poin'], fallback: 100),
    );
  }
}

class UjianPilihanOpsi {
  final String kode;
  final String label;
  final String teks;

  const UjianPilihanOpsi({
    required this.kode,
    required this.label,
    required this.teks,
  });

  factory UjianPilihanOpsi.fromJson(Map<String, dynamic> json) {
    return UjianPilihanOpsi(
      kode: json['kode']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      teks: json['teks']?.toString() ?? '',
    );
  }
}

class UjianSoalItem {
  final int id;
  final int nomor;
  final String pertanyaan;
  final String tipeSoal; // single_choice, multiple_choice, essay, matching
  final String? gambar;
  final double bobot;
  final List<UjianPilihanOpsi> pilihan;
  final String? savedAnswer;

  const UjianSoalItem({
    required this.id,
    required this.nomor,
    required this.pertanyaan,
    required this.tipeSoal,
    this.gambar,
    required this.bobot,
    required this.pilihan,
    this.savedAnswer,
  });

  String get tipeLabel {
    switch (tipeSoal) {
      case 'essay':
        return 'Esai / Uraian';
      case 'multiple_choice':
        return 'Pilihan Ganda Kompleks';
      case 'matching':
        return 'Menjodohkan';
      default:
        return 'Pilihan Ganda';
    }
  }

  factory UjianSoalItem.fromJson(Map<String, dynamic> json) {
    final rawPilihan = json['pilihan'] is List ? json['pilihan'] as List : [];
    return UjianSoalItem(
      id: _toInt(json['id']),
      nomor: _toInt(json['nomor']),
      pertanyaan: json['pertanyaan']?.toString() ?? '',
      tipeSoal: json['tipe_soal']?.toString() ?? 'single_choice',
      gambar: json['gambar']?.toString(),
      bobot: _toDouble(json['bobot'], fallback: 1),
      pilihan: rawPilihan
          .whereType()
          .map((e) => UjianPilihanOpsi.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      savedAnswer: json['saved_answer']?.toString(),
    );
  }
}

class UjianKerjakanData {
  final int ujianId;
  final String judul;
  final int durasiMenit;
  final int sesiNomor;
  final int seleksiId;
  final String statusSesi;
  final int pelanggaranCount;
  final int sisaDetik;
  final List<UjianSoalItem> soals;
  final Map<int, String> savedAnswers;

  const UjianKerjakanData({
    required this.ujianId,
    required this.judul,
    required this.durasiMenit,
    required this.sesiNomor,
    required this.seleksiId,
    required this.statusSesi,
    required this.pelanggaranCount,
    required this.sisaDetik,
    required this.soals,
    required this.savedAnswers,
  });

  factory UjianKerjakanData.fromJson(Map<String, dynamic> json) {
    final ujianMap = json['ujian'] is Map ? Map<String, dynamic>.from(json['ujian']) : {};
    final sesiMap = json['sesi'] is Map ? Map<String, dynamic>.from(json['sesi']) : {};
    final rawSoals = json['soals'] is List ? json['soals'] as List : [];
    final rawSaved = json['saved_answers'] is Map ? Map<String, dynamic>.from(json['saved_answers']) : {};

    final savedMap = <int, String>{};
    rawSaved.forEach((k, v) {
      final parsedId = int.tryParse(k.toString());
      if (parsedId != null && v != null) {
        savedMap[parsedId] = v.toString();
      }
    });

    return UjianKerjakanData(
      ujianId: _toInt(ujianMap['id']),
      judul: ujianMap['judul']?.toString() ?? 'Ujian',
      durasiMenit: _toInt(ujianMap['durasi_menit'], fallback: 60),
      sesiNomor: _toInt(ujianMap['sesi'], fallback: 1),
      seleksiId: _toInt(sesiMap['id']),
      statusSesi: sesiMap['status']?.toString() ?? 'sedang_mengerjakan',
      pelanggaranCount: _toInt(sesiMap['pelanggaran_count']),
      sisaDetik: _toInt(sesiMap['sisa_detik']),
      soals: rawSoals
          .whereType()
          .map((e) => UjianSoalItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      savedAnswers: savedMap,
    );
  }
}

class UjianHasilData {
  final int ujianId;
  final String judul;
  final String mapel;
  final String kelas;
  final String guru;
  final double kkm;
  final bool tampilkanNilai;
  final double? nilai;
  final double? nilaiAwal;
  final double? nilaiAkhir;
  final bool tuntas;
  final int totalSoal;
  final int totalBenar;
  final int totalSalah;
  final bool adaEssay;
  final bool essayBelumDinilai;
  final int? durasiDetik;
  final String? waktuSelesai;

  const UjianHasilData({
    required this.ujianId,
    required this.judul,
    required this.mapel,
    required this.kelas,
    required this.guru,
    required this.kkm,
    required this.tampilkanNilai,
    this.nilai,
    this.nilaiAwal,
    this.nilaiAkhir,
    required this.tuntas,
    required this.totalSoal,
    required this.totalBenar,
    required this.totalSalah,
    required this.adaEssay,
    required this.essayBelumDinilai,
    this.durasiDetik,
    this.waktuSelesai,
  });

  factory UjianHasilData.fromJson(Map<String, dynamic> json) {
    final u = json['ujian'] is Map ? Map<String, dynamic>.from(json['ujian']) : {};
    final s = json['summary'] is Map ? Map<String, dynamic>.from(json['summary']) : {};

    return UjianHasilData(
      ujianId: _toInt(u['id']),
      judul: u['judul']?.toString() ?? 'Hasil Ujian',
      mapel: u['mapel']?.toString() ?? 'Mata Pelajaran',
      kelas: u['kelas']?.toString() ?? '-',
      guru: u['guru']?.toString() ?? 'Guru Pengampu',
      kkm: _toDouble(u['kkm'], fallback: 75),
      tampilkanNilai: u['tampilkan_nilai'] == true || u['tampilkan_nilai'] == 1,
      nilai: s['nilai'] != null ? _toDouble(s['nilai']) : null,
      nilaiAwal: s['nilai_awal'] != null ? _toDouble(s['nilai_awal']) : null,
      nilaiAkhir: s['nilai_akhir'] != null ? _toDouble(s['nilai_akhir']) : null,
      tuntas: s['tuntas'] == true,
      totalSoal: _toInt(s['total_soal']),
      totalBenar: _toInt(s['total_benar']),
      totalSalah: _toInt(s['total_salah']),
      adaEssay: s['ada_essay'] == true,
      essayBelumDinilai: s['essay_belum_dinilai'] == true,
      durasiDetik: s['durasi_detik'] != null ? _toInt(s['durasi_detik']) : null,
      waktuSelesai: s['waktu_selesai']?.toString(),
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}