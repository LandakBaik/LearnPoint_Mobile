import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth/login.dart';
import '../models/student_profile_model.dart';
import 'edit_profil.dart';

class AkunScreen extends StatefulWidget {
  final StudentProfileModel profile;

  const AkunScreen({
    super.key,
    this.profile = const StudentProfileModel(
      name: 'Abimanyu Putra Pratama',
      gradeClass: '7-A',
      schoolName: 'SMPN 14 Jember',
      initials: 'AP',
      username: 'abimanyu_putra',
      email: 'abimanyu.putra@example.com',
      address: 'Jl. Kalimantan No. 37, Sumbersari, Jember, Jawa Timur',
      dateOfBirth: '14 Mei 2011',
      gender: 'Laki-laki',
      parentName: 'Eko Sudarsono',
      parentPhone: '0812-3456-7890',
      avatarUrl: 'assets/images/kocheng.jpg',
      nisn: '0098234112',
      academicYear: '2025/2026',
    ),
  });

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  late StudentProfileModel _currentProfile;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).push<StudentProfileModel>(
      MaterialPageRoute(
        builder: (context) => EditProfilScreen(profile: _currentProfile),
      ),
    );

    if (updated != null) {
      setState(() {
        _currentProfile = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF4338CA),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================================
              // HEADER PROFIL (TEMA DASHBOARD INDIGO)
              // ========================================
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3730A3),
                      Color(0xFF4338CA),
                    ],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 32.0 : 20.0,
                  mediaQuery.padding.top + 14.0,
                  isTablet ? 32.0 : 20.0,
                  28.0,
                ),
                child: Column(
                  children: [
                    // Top Bar (Back Button + Title + Edit Button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(_currentProfile),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // Title
                        const Text(
                          'Profil Akun',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),

                        // Edit Button (Top Right)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _openEditProfile,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Foto Profil Avatar (UKURAN DIPERBESAR: 110 x 110)
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _buildAvatarImage(),
                          ),
                        ),

                        // Badge Kamera Edit Foto
                        GestureDetector(
                          onTap: _openEditProfile,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Nama Siswa (UKURAN DIPERBESAR: 24sp)
                    Text(
                      _currentProfile.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Username Tag (UKURAN DIPERBESAR: 14.5sp)
                    Text(
                      '@${_currentProfile.username}',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Badges (Kelas & Status Aktif - UKURAN DIPERBESAR)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Badge Sekolah & Kelas
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${_currentProfile.gradeClass} • ${_currentProfile.schoolName}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF34D399),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                color: Color(0xFF34D399),
                                size: 8,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Siswa Aktif',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ========================================
              // KONTEN DATA AKUN (CONTAINER PUTIH MELENGKUNG)
              // ========================================
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32.0 : 20.0,
                    vertical: 26.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========================================
                      // SECTION 1: DATA DIRI & AKUN
                      // ========================================
                      _buildSectionHeader(
                        icon: Icons.person_rounded,
                        iconColor: const Color(0xFF4F46E5),
                        iconBgColor: const Color(0xFFEDE9FE),
                        title: 'Data Diri Siswa',
                      ),

                      const SizedBox(height: 14),

                      _buildCardContainer(
                        children: [
                          _buildInfoRow(
                            icon: Icons.badge_outlined,
                            label: 'Nama Lengkap',
                            value: _currentProfile.name,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.alternate_email_rounded,
                            label: 'Username',
                            value: _currentProfile.username,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.mail_outline_rounded,
                            label: 'Alamat Email',
                            value: _currentProfile.email,
                            canCopy: true,
                            context: context,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.cake_outlined,
                            label: 'Tanggal Lahir',
                            value: _currentProfile.dateOfBirth,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.wc_rounded,
                            label: 'Jenis Kelamin',
                            value: _currentProfile.gender,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Alamat Lengkap',
                            value: _currentProfile.address,
                            isMultiLine: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ========================================
                      // SECTION 2: DATA WALI MURID
                      // ========================================
                      _buildSectionHeader(
                        icon: Icons.family_restroom_rounded,
                        iconColor: const Color(0xFF059669),
                        iconBgColor: const Color(0xFFDCFCE7),
                        title: 'Data Wali Murid',
                      ),

                      const SizedBox(height: 14),

                      _buildCardContainer(
                        children: [
                          _buildInfoRow(
                            icon: Icons.supervisor_account_outlined,
                            label: 'Nama Wali Murid',
                            value: _currentProfile.parentName,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.phone_outlined,
                            label: 'No. HP Wali Murid',
                            value: _currentProfile.parentPhone,
                            canCopy: true,
                            context: context,
                            actionWidget: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: _currentProfile.parentPhone));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Nomor HP ${_currentProfile.parentPhone} berhasil disalin'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFA7F3D0),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.copy_rounded,
                                      size: 14,
                                      color: Color(0xFF059669),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Salin',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ========================================
                      // SECTION 3: INFORMASI AKADEMIK
                      // ========================================
                      _buildSectionHeader(
                        icon: Icons.school_rounded,
                        iconColor: const Color(0xFFD97706),
                        iconBgColor: const Color(0xFFFEF3C7),
                        title: 'Informasi Akademik',
                      ),

                      const SizedBox(height: 14),

                      _buildCardContainer(
                        children: [
                          _buildInfoRow(
                            icon: Icons.account_balance_outlined,
                            label: 'Asal Sekolah',
                            value: _currentProfile.schoolName,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.meeting_room_outlined,
                            label: 'Kelas',
                            value: _currentProfile.gradeClass,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.numbers_rounded,
                            label: 'NISN Siswa',
                            value: _currentProfile.nisn ?? '-',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.calendar_month_outlined,
                            label: 'Tahun Ajaran',
                            value: _currentProfile.academicYear ?? '2025/2026',
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ========================================
                      // TOMBOL EDIT PROFIL UTAMA
                      // ========================================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _openEditProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4338CA),
                            foregroundColor: Colors.white,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_note_rounded, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Edit Data Profil',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ========================================
                      // TOMBOL LOGOUT
                      // ========================================
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFECACA),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showLogoutDialog(context),
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Keluar dari Akun',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    final avatar = _currentProfile.avatarUrl;
    if (avatar != null && avatar.isNotEmpty) {
      if (avatar.startsWith('assets/')) {
        return Image.asset(
          avatar,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(),
        );
      } else {
        return Image.network(
          avatar,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(),
        );
      }
    }
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF4338CA),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _currentProfile.initials,
        style: const TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        thickness: 0.9,
        color: Color(0xFFF1F5F9),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiLine = false,
    bool canCopy = false,
    BuildContext? context,
    Widget? actionWidget,
  }) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        if (actionWidget != null) ...[
          const SizedBox(width: 8),
          actionWidget,
        ] else if (canCopy && context != null) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label berhasil disalin'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.copy_rounded,
                size: 16,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 10),
            Text(
              'Konfirmasi Keluar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun LearnPoint ini?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                fontSize: 14.5,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Berhasil keluar dari akun'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
            ),
          ),
        ],
      ),
    );
  }
}
