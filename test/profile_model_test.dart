import 'package:flutter_test/flutter_test.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/shared/models/user_model.dart';

void main() {
  group('StudentProfileModel Laravel API mapping', () {
    test('parses GET /api/profile response for siswa correctly', () {
      final apiData = {
        'user': {
          'id': 10,
          'name': 'Siti Aminah',
          'username': 'siti_aminah',
          'email': '2026001@siswa.learnpoint.sch.id',
          'role': 'siswa',
          'status': 'aktif',
        },
        'detail': {
          'id': 5,
          'nama_siswa': 'Siti Aminah',
          'nis': '2026001',
          'angkatan': 2026,
          'alamat': 'Jl. Mastrip No. 12, Jember',
          'tanggal_lahir': '2012-08-17',
          'jenis_kelamin': 'P',
          'agama': 'Islam',
          'wali_murid': 'Ahmad Fauzi',
          'nohp_wali': '081234567890',
          'status': 'aktif',
          'kelas': {
            'id': 2,
            'nama_kelas': 'VII-B',
            'tingkatan': 7,
            'guru': {
              'id': 3,
              'nama': 'Budi Santoso, S.Pd',
            },
          },
          'anggota_kelases': [],
        },
      };

      final profile = StudentProfileModel.fromProfileApi(apiData);

      expect(profile.name, 'Siti Aminah');
      expect(profile.username, 'siti_aminah');
      expect(profile.email, '2026001@siswa.learnpoint.sch.id');
      expect(profile.initials, 'SA');
      expect(profile.nisn, '2026001');
      expect(profile.gradeClass, 'Kelas VII-B');
      expect(profile.waliKelas, 'Budi Santoso, S.Pd');
      expect(profile.gender, 'Perempuan');
      expect(profile.dateOfBirth, '17 Agustus 2012');
      expect(profile.agama, 'Islam');
      expect(profile.address, 'Jl. Mastrip No. 12, Jember');
      expect(profile.parentName, 'Ahmad Fauzi');
      expect(profile.parentPhone, '081234567890');
      expect(profile.academicYear, '2026/2027');
      expect(profile.isSiswa, isTrue);
      expect(profile.isGuru, isFalse);
      expect(profile.isActive, isTrue);
    });

    test('falls back to anggota_kelases when detail.kelas is null', () {
      final apiData = {
        'user': {
          'id': 11,
          'name': 'Rizky Pratama',
          'username': 'rizky_p',
          'email': 'rizky@siswa.learnpoint.sch.id',
          'role': 'siswa',
          'status': 'aktif',
        },
        'detail': {
          'id': 6,
          'nama_siswa': 'Rizky Pratama',
          'nis': '2026002',
          'jenis_kelamin': 'L',
          'kelas': null,
          'anggota_kelases': [
            {
              'id': 1,
              'kelas': {
                'id': 4,
                'nama_kelas': 'VIII-A',
              },
            },
          ],
        },
      };

      final profile = StudentProfileModel.fromProfileApi(apiData);
      expect(profile.gradeClass, 'Kelas VIII-A');
      expect(profile.gender, 'Laki-laki');
    });

    test('parses GET /api/profile response for guru correctly', () {
      final apiData = {
        'user': {
          'id': 2,
          'name': 'Dewi Lestari',
          'username': 'dewi_lestari',
          'email': 'dewi@guru.learnpoint.sch.id',
          'role': 'guru',
          'status': 'aktif',
        },
        'detail': {
          'id': 1,
          'nama': 'Dewi Lestari',
          'nuptk': '198701012015012001',
          'nomor_telepon': '085211223344',
          'jenis_kelamin': 'Perempuan',
          'status': 'aktif',
          'kelas': {
            'id': 1,
            'nama_kelas': 'VII-A',
          },
          'guru_mapels': [
            {
              'id': 1,
              'mapel': {'id': 1, 'nama_mapel': 'Matematika'},
            },
            {
              'id': 2,
              'mapel': {'id': 2, 'nama_mapel': 'IPA'},
            },
          ],
        },
      };

      final profile = StudentProfileModel.fromProfileApi(apiData);
      expect(profile.name, 'Dewi Lestari');
      expect(profile.isGuru, isTrue);
      expect(profile.nisn, '198701012015012001');
      expect(profile.parentPhone, '085211223344');
      expect(profile.gender, 'Perempuan');
      expect(profile.waliKelas, 'VII-A');
      expect(profile.gradeClass, 'Wali Kelas VII-A');
      expect(profile.mapelDiampu, ['Matematika', 'IPA']);
    });

    test('converts UserModel fallback without dummy values', () {
      final user = UserModel(
        id: 1,
        name: 'Andi Wijaya',
        username: 'andi_w',
        email: 'andi@siswa.learnpoint.sch.id',
        role: 'siswa',
        siswa: SiswaData(
          id: 9,
          nis: '998877',
          namaSiswa: 'Andi Wijaya',
          alamat: 'Jember',
          tanggalLahir: '2011-01-05',
          jenisKelamin: 'L',
          waliMurid: 'Wijaya',
          nohpWali: '081111222333',
          namaKelas: 'IX-C',
        ),
      );

      final profile = StudentProfileModel.fromUserModel(user);
      expect(profile.name, 'Andi Wijaya');
      expect(profile.nisn, '998877');
      expect(profile.gradeClass, 'Kelas IX-C');
      expect(profile.dateOfBirth, '5 Januari 2011');
      expect(profile.gender, 'Laki-laki');
      expect(profile.avatarUrl, isNull);
    });
  });
}
