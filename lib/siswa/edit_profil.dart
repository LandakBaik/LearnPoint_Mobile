import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/student_profile_model.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _usernameController = TextEditingController(text: widget.profile.username);
    _emailController = TextEditingController(text: widget.profile.email);
    _addressController = TextEditingController(text: widget.profile.address);
    _dobController = TextEditingController(text: widget.profile.dateOfBirth);
    _parentNameController = TextEditingController(text: widget.profile.parentName);
    _parentPhoneController = TextEditingController(text: widget.profile.parentPhone);
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

  Future<void> _pickDate() async {
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 14));
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4338CA),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final formatted = '${pickedDate.day} ${months[pickedDate.month - 1]} ${pickedDate.year}';
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  String _calculateInitials(String name) {
    if (name.trim().isEmpty) return 'AP';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;

        final updatedProfile = widget.profile.copyWith(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
          gender: _selectedGender,
          parentName: _parentNameController.text.trim(),
          parentPhone: _parentPhoneController.text.trim(),
          nisn: _nisnController.text.trim(),
          initials: _calculateInitials(_nameController.text),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Profil berhasil diperbarui!'),
              ],
            ),
            backgroundColor: Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pop(updatedProfile);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap periksa kembali isian formulir yang belum valid.'),
          backgroundColor: Color(0xFFEF4444),
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

                        const Text(
                          'Edit Profil Siswa',
                          style: TextStyle(
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

                    // Avatar Edit Icon
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
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

                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pilih foto dari galeri/kamera'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
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
                                  offset: Offset(0, 2),
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

                    const SizedBox(height: 12),

                    Text(
                      'Ubah Data & Foto Profil',
                      style: TextStyle(
                        fontSize: 14,
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
                        // SECTION 1: DATA PRIBADI
                        _buildSectionHeader(
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFF4F46E5),
                          iconBgColor: const Color(0xFFEDE9FE),
                          title: 'Informasi Pribadi',
                        ),

                        const SizedBox(height: 14),

                        // Nama Lengkap (TextFormField dengan Validasi)
                        _buildFieldLabel('Nama Lengkap *'),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _buildInputDecoration(
                            hint: 'Masukkan nama lengkap',
                            prefixIcon: Icons.badge_outlined,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nama lengkap tidak boleh kosong';
                            }
                            if (val.trim().length < 3) {
                              return 'Nama lengkap minimal 3 karakter';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 18),

                        // Username (TextFormField dengan Validasi)
                        _buildFieldLabel('Username *'),
                        TextFormField(
                          controller: _usernameController,
                          decoration: _buildInputDecoration(
                            hint: 'Masukkan username',
                            prefixIcon: Icons.alternate_email_rounded,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            if (val.contains(' ')) {
                              return 'Username tidak boleh mengandung spasi';
                            }
                            if (val.length < 4) {
                              return 'Username minimal 4 karakter';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Email (TextFormField dengan Validasi Email)
                        _buildFieldLabel('Alamat Email *'),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildInputDecoration(
                            hint: 'contoh: nama@learnpoint.sch.id',
                            prefixIcon: Icons.mail_outline_rounded,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(val.trim())) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Jenis Kelamin (Dropdown Form Field)
                        _buildFieldLabel('Jenis Kelamin *'),
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
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Pilih jenis kelamin';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Tanggal Lahir (TextFormField dengan DatePicker)
                        _buildFieldLabel('Tanggal Lahir *'),
                        TextFormField(
                          controller: _dobController,
                          readOnly: true,
                          onTap: _pickDate,
                          decoration: _buildInputDecoration(
                            hint: 'Pilih tanggal lahir',
                            prefixIcon: Icons.cake_outlined,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF4338CA)),
                              onPressed: _pickDate,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Tanggal lahir wajib diisi';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Alamat Domisili (TextFormField Multi-line)
                        _buildFieldLabel('Alamat Lengkap *'),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 3,
                          decoration: _buildInputDecoration(
                            hint: 'Masukkan alamat domisili lengkap',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Alamat tidak boleh kosong';
                            }
                            if (val.trim().length < 5) {
                              return 'Alamat minimal 5 karakter';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        // SECTION 2: DATA WALI MURID
                        _buildSectionHeader(
                          icon: Icons.family_restroom_rounded,
                          iconColor: const Color(0xFF059669),
                          iconBgColor: const Color(0xFFDCFCE7),
                          title: 'Informasi Wali Murid',
                        ),

                        const SizedBox(height: 14),

                        // Nama Wali Murid (TextFormField dengan Validasi)
                        _buildFieldLabel('Nama Wali Murid *'),
                        TextFormField(
                          controller: _parentNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _buildInputDecoration(
                            hint: 'Masukkan nama ayah/ibu/wali',
                            prefixIcon: Icons.supervisor_account_outlined,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nama wali murid tidak boleh kosong';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // No HP Wali Murid (TextFormField dengan Phone Validation)
                        _buildFieldLabel('No. HP / WhatsApp Wali *'),
                        TextFormField(
                          controller: _parentPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _buildInputDecoration(
                            hint: 'contoh: 0812-3456-7890',
                            prefixIcon: Icons.phone_outlined,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nomor HP wali murid tidak boleh kosong';
                            }
                            final cleanPhone = val.replaceAll(RegExp(r'[^0-9]'), '');
                            if (cleanPhone.length < 9 || cleanPhone.length > 15) {
                              return 'Nomor HP tidak valid (9-15 digit)';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        // SECTION 3: DATA AKADEMIK (READ ONLY / EDITABLE)
                        _buildSectionHeader(
                          icon: Icons.school_rounded,
                          iconColor: const Color(0xFFD97706),
                          iconBgColor: const Color(0xFFFEF3C7),
                          title: 'Data Akademik',
                        ),

                        const SizedBox(height: 14),

                        // NISN
                        _buildFieldLabel('Nomor Induk Siswa Nasional (NISN)'),
                        TextFormField(
                          controller: _nisnController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _buildInputDecoration(
                            hint: 'Masukkan NISN siswa',
                            prefixIcon: Icons.numbers_rounded,
                          ),
                          validator: (val) {
                            if (val != null && val.isNotEmpty && val.length < 8) {
                              return 'NISN minimal 8 digit angka';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // TOMBOL SIMPAN & BATAL
                        Row(
                          children: [
                            // Tombol Batal
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Tombol Simpan Perubahan
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4338CA),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.save_rounded, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Simpan Perubahan',
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
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
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
