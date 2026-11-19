import 'package:learnpoint_mobile/shared/models/user_model.dart';

class StudentProfileModel {
  final String name;
  final String gradeClass;
  final String schoolName;
  final String initials;
  final bool hasNotification;
  final String username;
  final String email;
  final String address;
  final String dateOfBirth;
  final String gender;
  final String parentName;
  final String parentPhone;
  final String? avatarUrl;
  final String? nisn;
  final String? academicYear;
  final String role;
  final String status;
  final String? agama;
  final String? waliKelas;
  final String? semester;
  final List<String> mapelDiampu;

  const StudentProfileModel({
    required this.name,
    required this.gradeClass,
    this.schoolName = 'SMPN 14 Jember',
    required this.initials,
    this.hasNotification = false,
    this.username = '',
    this.email = '',
    this.address = '-',
    this.dateOfBirth = '-',
    this.gender = '-',
    this.parentName = '-',
    this.parentPhone = '-',
    this.avatarUrl,
    this.nisn,
    this.academicYear,
    this.role = 'siswa',
    this.status = 'aktif',
    this.agama,
    this.waliKelas,
    this.semester,
    this.mapelDiampu = const [],
  });

  const StudentProfileModel.empty()
      : name = '',
        gradeClass = '-',
        schoolName = 'SMPN 14 Jember',
        initials = '-',
        hasNotification = false,
        username = '',
        email = '',
        address = '-',
        dateOfBirth = '-',
        gender = '-',
        parentName = '-',
        parentPhone = '-',
        avatarUrl = null,
        nisn = null,
        academicYear = null,
        role = 'siswa',
        status = 'aktif',
        agama = null,
        waliKelas = null,
        semester = null,
        mapelDiampu = const [];

  bool get isGuru => role.toLowerCase() == 'guru';
  bool get isSiswa => role.toLowerCase() == 'siswa';
  bool get isActive => status.toLowerCase() == 'aktif';
  bool get isEmpty => name.trim().isEmpty && username.trim().isEmpty;

  StudentProfileModel copyWith({
    String? name,
    String? gradeClass,
    String? schoolName,
    String? initials,
    bool? hasNotification,
    String? username,
    String? email,
    String? address,
    String? dateOfBirth,
    String? gender,
    String? parentName,
    String? parentPhone,
    String? avatarUrl,
    String? nisn,
    String? academicYear,
    String? role,
    String? status,
    String? agama,
    String? waliKelas,
    String? semester,
    List<String>? mapelDiampu,
  }) {
    return StudentProfileModel(
      name: name ?? this.name,
      gradeClass: gradeClass ?? this.gradeClass,
      schoolName: schoolName ?? this.schoolName,
      initials: initials ?? this.initials,
      hasNotification: hasNotification ?? this.hasNotification,
      username: username ?? this.username,
      email: email ?? this.email,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nisn: nisn ?? this.nisn,
      academicYear: academicYear ?? this.academicYear,
      role: role ?? this.role,
      status: status ?? this.status,
      agama: agama ?? this.agama,
      waliKelas: waliKelas ?? this.waliKelas,
      semester: semester ?? this.semester,
      mapelDiampu: mapelDiampu ?? this.mapelDiampu,
    );
  }

  /// Memetakan respons `GET /api/profile` atau `PUT /api/profile` dari Laravel:
  /// ```json
  /// { "user": { ... }, "detail": { ... } }
  /// ```
  factory StudentProfileModel.fromProfileApi(Map<String, dynamic> data) {
    final userMap = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : data;
    final detail = data['detail'] is Map
        ? Map<String, dynamic>.from(data['detail'] as Map)
        : null;

    final role = (userMap['role'] ?? 'siswa').toString();
    final isGuruRole = role.toLowerCase() == 'guru';
    final isSiswaRole = role.toLowerCase() == 'siswa';

    final rawName = isSiswaRole
        ? (detail?['nama_siswa'] ?? userMap['name'] ?? '')
        : isGuruRole
            ? (detail?['nama'] ?? userMap['name'] ?? '')
            : (userMap['name'] ?? '');
    final name = rawName.toString().trim();

    final username = (userMap['username'] ?? '').toString().trim();
    final email = (userMap['email'] ?? '').toString().trim();
    final status =
        (detail?['status'] ?? userMap['status'] ?? 'aktif').toString().trim();

    String gradeClass = '-';
    String? waliKelas;
    List<String> mapelDiampu = [];

    if (isSiswaRole && detail != null) {
      Map<String, dynamic>? kelasMap;
      if (detail['kelas'] is Map) {
        kelasMap = Map<String, dynamic>.from(detail['kelas'] as Map);
      } else if (detail['anggota_kelases'] is List) {
        final list = detail['anggota_kelases'] as List;
        for (var i = list.length - 1; i >= 0; i--) {
          final item = list[i];
          if (item is Map && item['kelas'] is Map) {
            kelasMap = Map<String, dynamic>.from(item['kelas'] as Map);
            break;
          }
        }
      }

      final namaKelas =
          (kelasMap?['nama_kelas'] ?? detail['nama_kelas'] ?? '').toString().trim();
      if (namaKelas.isNotEmpty) {
        gradeClass = namaKelas.toLowerCase().startsWith('kelas')
            ? namaKelas
            : 'Kelas $namaKelas';
      } else {
        gradeClass = 'Belum Ada Kelas';
      }

      if (kelasMap?['guru'] is Map) {
        final guruMap = kelasMap!['guru'] as Map;
        final namaGuru = guruMap['nama']?.toString().trim();
        if (namaGuru != null && namaGuru.isNotEmpty) {
          waliKelas = namaGuru;
        }
      }
    } else if (isGuruRole && detail != null) {
      if (detail['kelas'] is Map) {
        final kelasMap = detail['kelas'] as Map;
        final namaKelas = kelasMap['nama_kelas']?.toString().trim() ?? '';
        if (namaKelas.isNotEmpty) {
          waliKelas = namaKelas;
          gradeClass = 'Wali Kelas $namaKelas';
        }
      }
      if (detail['guru_mapels'] is List) {
        final list = detail['guru_mapels'] as List;
        final names = <String>{};
        for (final gm in list) {
          if (gm is Map && gm['mapel'] is Map) {
            final mapelName = gm['mapel']['nama_mapel']?.toString().trim();
            if (mapelName != null && mapelName.isNotEmpty) {
              names.add(mapelName);
            }
          }
        }
        mapelDiampu = names.toList();
      }
      if (gradeClass == '-') {
        gradeClass = mapelDiampu.isNotEmpty
            ? 'Guru ${mapelDiampu.join(', ')}'
            : 'Guru Pengajar';
      }
    } else {
      gradeClass = role.isNotEmpty
          ? '${role[0].toUpperCase()}${role.substring(1)}'
          : '-';
    }

    String? academicYear;
    final rawTahunAjaran =
        (detail?['tahun_ajaran'] ?? userMap['tahun_ajaran'])?.toString().trim();
    if (rawTahunAjaran != null && rawTahunAjaran.isNotEmpty) {
      academicYear = rawTahunAjaran;
    } else if (detail?['angkatan'] != null) {
      final angkatanInt = int.tryParse(detail!['angkatan'].toString());
      if (angkatanInt != null) {
        academicYear = '$angkatanInt/${angkatanInt + 1}';
      } else {
        academicYear = detail['angkatan'].toString();
      }
    }

    final rawNis = isGuruRole
        ? (detail?['nuptk'] ?? detail?['nip'])?.toString().trim()
        : (detail?['nis'] ?? detail?['nisn'])?.toString().trim();

    final rawGender = detail?['jenis_kelamin']?.toString().trim() ?? '';
    final gender = _formatGender(rawGender);

    final rawDob = detail?['tanggal_lahir']?.toString().trim() ?? '';
    final dateOfBirth = _formatDate(rawDob);

    final rawAddress = (detail?['alamat'] ?? '').toString().trim();
    final rawParentName = (detail?['wali_murid'] ?? '').toString().trim();
    final rawPhone = isGuruRole
        ? (detail?['nomor_telepon'] ?? detail?['nohp'] ?? '').toString().trim()
        : (detail?['nohp_wali'] ?? '').toString().trim();

    final rawAgama = detail?['agama']?.toString().trim();
    final rawSchool =
        (detail?['school_name'] ?? detail?['sekolah'] ?? userMap['school_name'])
            ?.toString()
            .trim();
    final rawAvatar =
        (userMap['avatar_url'] ?? detail?['avatar_url'])?.toString().trim();

    return StudentProfileModel(
      name: name.isNotEmpty ? name : username,
      gradeClass: gradeClass,
      schoolName: (rawSchool != null && rawSchool.isNotEmpty)
          ? rawSchool
          : 'SMPN 14 Jember',
      initials: computeInitials(name.isNotEmpty ? name : username),
      hasNotification: false,
      username: username,
      email: email,
      address: rawAddress.isNotEmpty ? rawAddress : '-',
      dateOfBirth: dateOfBirth,
      gender: gender,
      parentName: rawParentName.isNotEmpty ? rawParentName : '-',
      parentPhone: rawPhone.isNotEmpty ? rawPhone : '-',
      avatarUrl: (rawAvatar != null && rawAvatar.isNotEmpty) ? rawAvatar : null,
      nisn: (rawNis != null && rawNis.isNotEmpty) ? rawNis : null,
      academicYear: academicYear,
      role: role,
      status: status.isNotEmpty ? status : 'aktif',
      agama: (rawAgama != null && rawAgama.isNotEmpty) ? rawAgama : null,
      waliKelas: waliKelas,
      mapelDiampu: mapelDiampu,
    );
  }

  /// Konversi fallback dari [UserModel] (misalnya langsung setelah login).
  factory StudentProfileModel.fromUserModel(UserModel user) {
    final siswa = user.siswa;
    final guru = user.guru;
    final name = user.isSiswa
        ? (siswa?.namaSiswa?.trim().isNotEmpty == true
            ? siswa!.namaSiswa!.trim()
            : user.name)
        : user.isGuru
            ? (guru?.nama?.trim().isNotEmpty == true
                ? guru!.nama!.trim()
                : user.name)
            : user.name;

    String gradeClass = '-';
    if (user.isSiswa) {
      final namaKelas = siswa?.namaKelas?.trim() ?? '';
      gradeClass = namaKelas.isNotEmpty
          ? (namaKelas.toLowerCase().startsWith('kelas')
              ? namaKelas
              : 'Kelas $namaKelas')
          : 'Belum Ada Kelas';
    } else if (user.isGuru) {
      gradeClass = 'Guru Pengajar';
    } else {
      gradeClass = user.role;
    }

    return StudentProfileModel(
      name: name,
      gradeClass: gradeClass,
      schoolName: 'SMPN 14 Jember',
      initials: computeInitials(name),
      hasNotification: false,
      username: user.username,
      email: user.email,
      address: (siswa?.alamat?.trim().isNotEmpty == true)
          ? siswa!.alamat!.trim()
          : '-',
      dateOfBirth: _formatDate(siswa?.tanggalLahir ?? ''),
      gender: _formatGender(siswa?.jenisKelamin ?? ''),
      parentName: (siswa?.waliMurid?.trim().isNotEmpty == true)
          ? siswa!.waliMurid!.trim()
          : '-',
      parentPhone: user.isGuru
          ? ((guru?.nohp?.trim().isNotEmpty == true) ? guru!.nohp!.trim() : '-')
          : ((siswa?.nohpWali?.trim().isNotEmpty == true)
              ? siswa!.nohpWali!.trim()
              : '-'),
      nisn: user.isGuru ? guru?.nuptk : (siswa?.nis ?? siswa?.nisn),
      role: user.role,
      status: user.status,
    );
  }

  static String computeInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '-';
    if (parts.length == 1) {
      final word = parts[0];
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  static String _formatGender(String raw) {
    final upper = raw.trim().toUpperCase();
    if (upper == 'L' || upper == 'LAKI-LAKI') return 'Laki-laki';
    if (upper == 'P' || upper == 'PEREMPUAN') return 'Perempuan';
    return raw.trim().isNotEmpty ? raw.trim() : '-';
  }

  static String _formatDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '-';
    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) return trimmed;

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }
}
