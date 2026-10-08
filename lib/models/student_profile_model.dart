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

  const StudentProfileModel({
    required this.name,
    required this.gradeClass,
    required this.schoolName,
    required this.initials,
    this.hasNotification = true,
    this.username = 'abimanyu_putra',
    this.email = 'abimanyu.putra@learnpoint.sch.id',
    this.address = 'Jl. Kalimantan No. 37, Sumbersari, Jember, Jawa Timur',
    this.dateOfBirth = '14 Mei 2011',
    this.gender = 'Laki-laki',
    this.parentName = 'Bambang Sudarmono',
    this.parentPhone = '0812-3456-7890',
    this.avatarUrl = 'assets/images/kocheng.jpg',
    this.nisn = '0098234112',
    this.academicYear = '2025/2026',
  });

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
    );
  }
}
