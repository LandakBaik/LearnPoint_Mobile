import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnpoint_mobile/features/auth/data/auth_service.dart';
import 'package:learnpoint_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/screens/change_password_screen.dart';
import 'package:learnpoint_mobile/features/siswa/profile/screens/edit_profil_screen.dart';
import 'package:learnpoint_mobile/features/siswa/profile/services/profile_service.dart';

class AkunScreen extends StatefulWidget {
  final StudentProfileModel? profile;

  const AkunScreen({
    super.key,
    this.profile,
  });

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  late StudentProfileModel _currentProfile;
  bool _isLoading = true;
  bool _isLoggingOut = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile ??
        ProfileService.profileNotifier.value ??
        const StudentProfileModel.empty();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetched = await ProfileService.fetchProfile();
      if (!mounted) return;
      setState(() {
        _currentProfile = fetched;
        _isLoading = false;
      });
    } on ProfileException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data profil: $e';
      });
    }
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).push<StudentProfileModel>(
      MaterialPageRoute(
        builder: (context) => EditProfilScreen(profile: _currentProfile),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _currentProfile = updated;
      });
    }
  }

  Future<void> _openChangePassword() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const Changepass(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final isGuru = _currentProfile.isGuru;
    final isActive = _currentProfile.isActive;
    final statusLabel = isGuru
        ? (isActive ? 'Guru Aktif' : 'Nonaktif')
        : (_currentProfile.isSiswa
            ? (isActive ? 'Siswa Aktif' : 'Nonaktif')
            : (isActive ? 'Aktif' : 'Nonaktif'));

    return Scaffold(
      backgroundColor: const Color(0xFF4338CA),
      body: SafeArea(
        top: false,
        bottom: true,
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          color: const Color(0xFF4338CA),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      // Top Bar (Back Button + Title + Action Button)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  Navigator.of(context).pop(_currentProfile),
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

                          const Text(
                            'Profil Akun',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),

                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isGuru
                                  ? _openEditProfile
                                  : _openChangePassword,
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
                                child: Icon(
                                  isGuru
                                      ? Icons.edit_rounded
                                      : Icons.lock_reset_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Foto Profil Avatar
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

                      const SizedBox(height: 16),

                      if (_isLoading && _currentProfile.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      else ...[
                        Text(
                          _currentProfile.name.isNotEmpty
                              ? _currentProfile.name
                              : '-',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (_currentProfile.username.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            '@${_currentProfile.username}',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(height: 14),

                      // Badges (Kelas & Status Aktif)
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: (isActive
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444))
                                  .withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isActive
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFFFCA5A5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: isActive
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFFFCA5A5),
                                  size: 8,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusLabel,
                                  style: const TextStyle(
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
                        if (_isLoading && !_currentProfile.isEmpty) ...[
                          const LinearProgressIndicator(
                            color: Color(0xFF4338CA),
                            backgroundColor: Color(0xFFE0E7FF),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF991B1B),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _loadProfile,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ========================================
                        // SECTION 1: DATA DIRI & AKUN
                        // ========================================
                        _buildSectionHeader(
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFF4F46E5),
                          iconBgColor: const Color(0xFFEDE9FE),
                          title: isGuru ? 'Data Diri Guru' : 'Data Diri Siswa',
                        ),

                        const SizedBox(height: 14),

                        _buildCardContainer(
                          children: [
                            _buildInfoRow(
                              icon: Icons.badge_outlined,
                              label: 'Nama Lengkap',
                              value: _currentProfile.name.isNotEmpty
                                  ? _currentProfile.name
                                  : '-',
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              icon: Icons.alternate_email_rounded,
                              label: 'Username',
                              value: _currentProfile.username.isNotEmpty
                                  ? _currentProfile.username
                                  : '-',
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              icon: Icons.mail_outline_rounded,
                              label: 'Alamat Email',
                              value: _currentProfile.email.isNotEmpty
                                  ? _currentProfile.email
                                  : '-',
                              canCopy: _currentProfile.email.isNotEmpty,
                              context: context,
                            ),
                            if (!isGuru) ...[
                              _buildDivider(),
                              _buildInfoRow(
                                icon: Icons.cake_outlined,
                                label: 'Tanggal Lahir',
                                value: _currentProfile.dateOfBirth,
                              ),
                            ],
                            _buildDivider(),
                            _buildInfoRow(
                              icon: Icons.wc_rounded,
                              label: 'Jenis Kelamin',
                              value: _currentProfile.gender,
                            ),
                            if (!isGuru && _currentProfile.agama != null) ...[
                              _buildDivider(),
                              _buildInfoRow(
                                icon: Icons.auto_awesome_outlined,
                                label: 'Agama',
                                value: _currentProfile.agama!,
                              ),
                            ],
                            if (isGuru) ...[
                              _buildDivider(),
                              _buildInfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Nomor Telepon',
                                value: _currentProfile.parentPhone,
                                canCopy: _currentProfile.parentPhone != '-',
                                context: context,
                              ),
                            ] else ...[
                              _buildDivider(),
                              _buildInfoRow(
                                icon: Icons.location_on_outlined,
                                label: 'Alamat Lengkap',
                                value: _currentProfile.address,
                                isMultiLine: true,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 24),

                        if (!isGuru) ...[
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
                                canCopy: _currentProfile.parentPhone != '-',
                                context: context,
                                actionWidget: _currentProfile.parentPhone != '-'
                                    ? InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                              text:
                                                  _currentProfile.parentPhone));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Nomor HP ${_currentProfile.parentPhone} berhasil disalin'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                      )
                                    : null,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                        ],

                        // ========================================
                        // SECTION 3: INFORMASI AKADEMIK / MENGAJAR
                        // ========================================
                        _buildSectionHeader(
                          icon: Icons.school_rounded,
                          iconColor: const Color(0xFFD97706),
                          iconBgColor: const Color(0xFFFEF3C7),
                          title: isGuru
                              ? 'Informasi Mengajar'
                              : 'Informasi Akademik',
                        ),

                        const SizedBox(height: 14),

                        _buildCardContainer(
                          children: isGuru
                              ? [
                                  _buildInfoRow(
                                    icon: Icons.numbers_rounded,
                                    label: 'NUPTK',
                                    value: _currentProfile.nisn ?? '-',
                                  ),
                                  _buildDivider(),
                                  _buildInfoRow(
                                    icon: Icons.meeting_room_outlined,
                                    label: 'Status Wali Kelas',
                                    value: _currentProfile.waliKelas != null
                                        ? 'Wali Kelas ${_currentProfile.waliKelas}'
                                        : 'Bukan Wali Kelas',
                                  ),
                                  _buildDivider(),
                                  _buildInfoRow(
                                    icon: Icons.menu_book_outlined,
                                    label: 'Mata Pelajaran Diampu',
                                    value: _currentProfile
                                            .mapelDiampu.isNotEmpty
                                        ? _currentProfile.mapelDiampu.join(', ')
                                        : '-',
                                    isMultiLine: true,
                                  ),
                                ]
                              : [
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
                                  if (_currentProfile.waliKelas != null) ...[
                                    _buildDivider(),
                                    _buildInfoRow(
                                      icon: Icons.person_pin_outlined,
                                      label: 'Wali Kelas',
                                      value: _currentProfile.waliKelas!,
                                    ),
                                  ],
                                  _buildDivider(),
                                  _buildInfoRow(
                                    icon: Icons.numbers_rounded,
                                    label: 'NIS Siswa',
                                    value: _currentProfile.nisn ?? '-',
                                  ),
                                  _buildDivider(),
                                  _buildInfoRow(
                                    icon: Icons.calendar_month_outlined,
                                    label: 'Angkatan / Tahun Ajaran',
                                    value: _currentProfile.academicYear ?? '-',
                                  ),
                                ],
                        ),

                        const SizedBox(height: 28),

                        if (isGuru) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _openEditProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4338CA),
                                foregroundColor: Colors.white,
                                elevation: 1,
                                minimumSize: const Size(double.infinity, 50),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_note_rounded, size: 21),
                                  SizedBox(width: 8),
                                  Text(
                                    'Edit Data Profil',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // ========================================
                        // TOMBOL UBAH KATA SANDI
                        // ========================================
                        SizedBox(
                          width: double.infinity,
                          child: isGuru
                              ? OutlinedButton(
                                  onPressed: _openChangePassword,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF4338CA),
                                    side: const BorderSide(
                                      color: Color(0xFF4338CA),
                                      width: 1.5,
                                    ),
                                    minimumSize: const Size(double.infinity, 48),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock_reset_rounded, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Ubah Kata Sandi',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _openChangePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4338CA),
                                    foregroundColor: Colors.white,
                                    elevation: 1,
                                    minimumSize: const Size(double.infinity, 50),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock_reset_rounded, size: 21),
                                      SizedBox(width: 8),
                                      Text(
                                        'Ubah Kata Sandi',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),

                        const SizedBox(height: 12),

                        // ========================================
                        // TOMBOL LOGOUT
                        // ========================================
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _isLoggingOut
                                ? null
                                : () => _showLogoutDialog(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFF5F5),
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(
                                color: Color(0xFFFECACA),
                                width: 1.2,
                              ),
                              minimumSize: const Size(double.infinity, 46),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoggingOut) ...[
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Keluar dari akun...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(Icons.logout_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Keluar dari Akun',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
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
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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

  void _showLogoutDialog(BuildContext parentContext) {
    if (_isLoggingOut) return;

    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.of(dialogContext).pop(),
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
            onPressed: () async {
              if (_isLoggingOut) return;
              final navigator = Navigator.of(parentContext);
              final messenger = ScaffoldMessenger.of(parentContext);

              Navigator.of(dialogContext).pop();
              if (!mounted) return;
              setState(() {
                _isLoggingOut = true;
              });

              await AuthService.logout();
              if (!mounted) return;

              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Berhasil keluar dari akun'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              navigator.pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const Login()),
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
