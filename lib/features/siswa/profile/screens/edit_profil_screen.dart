import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/features/siswa/profile/screens/change_password_screen.dart';
import 'package:learnpoint_mobile/features/siswa/profile/services/profile_service.dart';

class EditProfilScreen extends StatefulWidget {
  final StudentProfileModel profile;

  const EditProfilScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _nisnController;

  late String _selectedGender;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];

  bool get _isGuru => widget.profile.isGuru;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _usernameController = TextEditingController(text: widget.profile.username);
    _emailController = TextEditingController(text: widget.profile.email);
    _addressController = TextEditingController(text: widget.profile.address);
    _dobController = TextEditingController(text: widget.profile.dateOfBirth);
    _parentNameController = TextEditingController(text: widget.profile.parentName);
    _parentPhoneController = TextEditingController(
      text: widget.profile.parentPhone == '-' ? '' : widget.profile.parentPhone,
    );
    _nisnController = TextEditingController(text: widget.profile.nisn ?? '');

    _selectedGender = _genderOptions.contains(widget.profile.gender)
        ? widget.profile.gender
        : _genderOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _nisnController.dispose();
    super.dispose();
  }

  String _calculateInitials(String name) {
    return StudentProfileModel.computeInitials(name);
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    if (!_isGuru) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const Changepass()),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap periksa kembali isian formulir yang belum valid.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cleanPhone =
          _parentPhoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final updatedProfile = await ProfileService.updateGuruProfile(
        nomorTelepon: cleanPhone.isEmpty ? null : cleanPhone,
        jenisKelamin: _selectedGender,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Profil guru berhasil diperbarui!'),
            ],
          ),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop(updatedProfile);
    } on ProfileException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profil: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
              // HEADER EDIT PROFIL (TEMA DASHBOARD)
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
                  isTablet ? 28.0 : 18.0,
                  mediaQuery.padding.top + 14.0,
                  isTablet ? 28.0 : 18.0,
                  24.0,
                ),
                child: Column(
                  children: [
                    // Top Row: Back & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          ),
                        ),

                        Text(
                          _isGuru ? 'Edit Profil Guru' : 'Informasi Profil',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),

                        // Placeholder for symmetry
                        const SizedBox(width: 42),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Avatar
                    Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildAvatarImage(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _isGuru
                          ? 'Perbarui Nomor Telepon & Jenis Kelamin'
                          : 'Nama dan email dikelola oleh operator sekolah',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // ========================================
              // FORMULIR EDIT PROFIL (CONTAINER PUTIH)
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
                    horizontal: isTablet ? 28.0 : 20.0,
                    vertical: 26.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isGuru) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFC7D2FE),
                              ),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF4338CA),
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Sesuai aturan sistem, data diri siswa hanya dapat diubah oleh operator sekolah. Anda tetap dapat memperbarui kata sandi akun.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF312E81),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // SECTION 1: DATA PRIBADI (READ-ONLY FOR NAME/USERNAME/EMAIL)
                        _buildSectionHeader(
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFF4F46E5),
                          iconBgColor: const Color(0xFFEDE9FE),
                          title: 'Informasi Akun (Hanya Lihat)',
                        ),

                        const SizedBox(height: 14),

                        _buildFieldLabel('Nama Lengkap'),
                        TextFormField(
                          controller: _nameController,
                          readOnly: true,
                          decoration: _buildInputDecoration(
                            hint: 'Nama lengkap',
                            prefixIcon: Icons.badge_outlined,
                            readOnly: true,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildFieldLabel('Username'),
                        TextFormField(
                          controller: _usernameController,
                          readOnly: true,
                          decoration: _buildInputDecoration(
                            hint: 'Username',
                            prefixIcon: Icons.alternate_email_rounded,
                            readOnly: true,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildFieldLabel('Alamat Email'),
                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: _buildInputDecoration(
                            hint: 'Email',
                            prefixIcon: Icons.mail_outline_rounded,
                            readOnly: true,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildFieldLabel(_isGuru ? 'NUPTK' : 'Nomor Induk Siswa (NIS)'),
                        TextFormField(
                          controller: _nisnController,
                          readOnly: true,
                          decoration: _buildInputDecoration(
                            hint: '-',
                            prefixIcon: Icons.numbers_rounded,
                            readOnly: true,
                          ),
                        ),

                        if (_isGuru) ...[
                          const SizedBox(height: 28),
                          _buildSectionHeader(
                            icon: Icons.edit_note_rounded,
                            iconColor: const Color(0xFF059669),
                            iconBgColor: const Color(0xFFDCFCE7),
                            title: 'Biodata & Kontak Guru',
                          ),
                          const SizedBox(height: 14),
                          _buildFieldLabel('Jenis Kelamin'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedGender,
                            decoration: _buildInputDecoration(
                              hint: 'Pilih jenis kelamin',
                              prefixIcon: Icons.wc_rounded,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            items: _genderOptions.map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedGender = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildFieldLabel('Nomor Telepon (10-13 digit)'),
                          TextFormField(
                            controller: _parentPhoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(13),
                            ],
                            decoration: _buildInputDecoration(
                              hint: 'Contoh: 081234567890',
                              prefixIcon: Icons.phone_outlined,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return null; // nullable di Laravel
                              }
                              final cleanPhone =
                                  val.replaceAll(RegExp(r'[^0-9]'), '');
                              if (cleanPhone.length < 10 ||
                                  cleanPhone.length > 13) {
                                return 'Nomor telepon harus 10 hingga 13 digit angka';
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 32),

                        // TOMBOL SIMPAN & BATAL
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(
                                      color: Color(0xFFCBD5E1), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Kembali',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4338CA),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _isGuru
                                                ? Icons.save_rounded
                                                : Icons.lock_reset_rounded,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isGuru
                                                ? 'Simpan Perubahan'
                                                : 'Ubah Kata Sandi',
                                            style: const TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7, left: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF6366F1),
        size: 21,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4338CA), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      errorStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFFEF4444),
      ),
    );
  }

  Widget _buildAvatarImage() {
    final avatar = widget.profile.avatarUrl;
    if (avatar != null && avatar.isNotEmpty) {
      if (avatar.startsWith('assets/')) {
        return Image.asset(
          avatar,
          width: 105,
          height: 105,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(),
        );
      } else {
        return Image.network(
          avatar,
          width: 105,
          height: 105,
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
        _calculateInitials(_nameController.text),
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: Colors.white,
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
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
