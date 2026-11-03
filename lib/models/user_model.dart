class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String role;
  final String status;
  final SiswaData? siswa;
  final GuruData? guru;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    this.status = 'aktif',
    this.siswa,
    this.guru,
  });

  bool get isSiswa => role.toLowerCase() == 'siswa';
  bool get isGuru => role.toLowerCase() == 'guru';
  bool get isAdmin => role.toLowerCase() == 'operator' || role.toLowerCase() == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'siswa',
      status: json['status'] ?? 'aktif',
      siswa: json['siswa'] != null && json['siswa'] is Map<String, dynamic>
          ? SiswaData.fromJson(json['siswa'] as Map<String, dynamic>)
          : null,
      guru: json['guru'] != null && json['guru'] is Map<String, dynamic>
          ? GuruData.fromJson(json['guru'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'status': status,
      if (siswa != null) 'siswa': siswa!.toJson(),
      if (guru != null) 'guru': guru!.toJson(),
    };
  }
}

class SiswaData {
  final int id;
  final String? nis;
  final String? nisn;
  final String? namaSiswa;
  final String? alamat;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? waliMurid;
  final String? nohpWali;
  final String? namaKelas;

  SiswaData({
    required this.id,
    this.nis,
    this.nisn,
    this.namaSiswa,
    this.alamat,
    this.tanggalLahir,
    this.jenisKelamin,
    this.waliMurid,
    this.nohpWali,
    this.namaKelas,
  });

  factory SiswaData.fromJson(Map<String, dynamic> json) {
    String? resolvedKelas;
    if (json['kelas'] != null && json['kelas'] is Map<String, dynamic>) {
      resolvedKelas = json['kelas']['nama_kelas']?.toString();
    }

    return SiswaData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nis: json['nis']?.toString(),
      nisn: json['nisn']?.toString(),
      namaSiswa: json['nama_siswa'] ?? json['nama'],
      alamat: json['alamat'],
      tanggalLahir: json['tanggal_lahir'],
      jenisKelamin: json['jenis_kelamin'],
      waliMurid: json['wali_murid'] ?? json['nama_ayah'],
      nohpWali: json['nohp_wali'] ?? json['no_telp_ortu'],
      namaKelas: resolvedKelas ?? json['nama_kelas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nis': nis,
      'nisn': nisn,
      'nama_siswa': namaSiswa,
      'alamat': alamat,
      'tanggal_lahir': tanggalLahir,
      'jenisKelamin': jenisKelamin,
      'wali_murid': waliMurid,
      'nohp_wali': nohpWali,
      'nama_kelas': namaKelas,
    };
  }
}

class GuruData {
  final int id;
  final String? nuptk;
  final String? nip;
  final String? nama;
  final String? nohp;

  GuruData({
    required this.id,
    this.nuptk,
    this.nip,
    this.nama,
    this.nohp,
  });

  factory GuruData.fromJson(Map<String, dynamic> json) {
    return GuruData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nuptk: json['nuptk']?.toString(),
      nip: json['nip']?.toString(),
      nama: json['nama'] ?? json['nama_guru'],
      nohp: json['nohp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nuptk': nuptk,
      'nip': nip,
      'nama': nama,
      'nohp': nohp,
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;
  final Map<String, dynamic>? errors;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    String? token;

    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      token = data['token']?.toString();
      if (data['user'] != null && data['user'] is Map<String, dynamic>) {
        parsedUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
    }

    return AuthResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      token: token,
      user: parsedUser,
      errors: json['errors'] is Map<String, dynamic> ? json['errors'] : null,
    );
  }
}

