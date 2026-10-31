import 'package:flutter/material.dart';

class Changepass extends StatefulWidget {
  const Changepass({super.key});

  @override
  State<Changepass> createState() => _ChangepassState();
}

class _ChangepassState extends State<Changepass> {
  final _formkey = GlobalKey<FormState>();
  final passwordLamaController = TextEditingController();
  final passwordBaruController = TextEditingController();
  final konfirmasiPasswordController = TextEditingController();




// Nama    :IDEA BRILIANTA
// NIM     : E41251668
// KELOMPOK: 2





  bool passwordTerlihat = false;
  bool passwordBaruTerlihat = false;
  bool konfirmasiPasswordTerlihat = false;

  @override
  void dispose() {
    passwordLamaController.dispose();
    passwordBaruController.dispose();
    konfirmasiPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mediaquery untuk scaling font dan spacing dinamis
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScale = (screenWidth / 390).clamp(0.85, 1.15);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1B4B), size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Ganti Password',
          style: TextStyle(
            color: const Color(0xFF1E1B4B),
            fontSize: 18 * textScale,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: (screenWidth * 0.06).clamp(16.0, 32.0),
            vertical: 12.0,
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Icon Ilustrasi Gembok Lingkaran Soft Purple
              Container(
                width: 90 * textScale,
                height: 90 * textScale,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.lock_rounded,
                    size: 42 * textScale,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ),
              SizedBox(height: 20 * textScale),

              // Judul & Subtitle
              Text(
                'Ganti Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22 * textScale,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Buat password baru untuk\nmenjaga keamanan akunmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5 * textScale,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 24 * textScale),

              // Form Fields
              Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: Password Lama
                    _buildFieldLabel('Password Lama', textScale),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordLamaController,
                      obscureText: !passwordTerlihat,
                      style: TextStyle(fontSize: 14 * textScale, color: const Color(0xFF1E293B)),
                      decoration: _buildInputDecoration(
                        hintText: 'Masukkan password lama',
                        isObscured: !passwordTerlihat,
                        onToggleVisibility: () {
                          setState(() {
                            passwordTerlihat = !passwordTerlihat;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password lama wajib diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16 * textScale),

                    // Field 2: Password Baru
                    _buildFieldLabel('Password Baru', textScale),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordBaruController,
                      obscureText: !passwordBaruTerlihat,
                      style: TextStyle(fontSize: 14 * textScale, color: const Color(0xFF1E293B)),
                      decoration: _buildInputDecoration(
                        hintText: 'Masukkan password baru',
                        isObscured: !passwordBaruTerlihat,
                        onToggleVisibility: () {
                          setState(() {
                            passwordBaruTerlihat = !passwordBaruTerlihat;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password baru wajib diisi';
                        }
                        if (value.length < 8) {
                          return 'Minimal 8 karakter';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16 * textScale),

                    _buildFieldLabel('Konfirmasi Password', textScale),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: konfirmasiPasswordController,
                      obscureText: !konfirmasiPasswordTerlihat,
                      style: TextStyle(fontSize: 14 * textScale, color: const Color(0xFF1E293B)),
                      decoration: _buildInputDecoration(
                        hintText: 'Masukkan konfirmasi password',
                        isObscured: !konfirmasiPasswordTerlihat,
                        onToggleVisibility: () {
                          setState(() {
                            konfirmasiPasswordTerlihat = !konfirmasiPasswordTerlihat;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password wajib diisi';
                        }
                        if (value.length < 8) {
                          return 'Minimal 8 karakter';
                        }
                        if (value != passwordBaruController.text) {
                          return 'Konfirmasi password harus sama';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32 * textScale),

                    // Tombol Submit "Ganti Password"
                    SizedBox(
                      width: double.infinity,
                      height: 50 * textScale,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password berhasil diperbarui!'),
                                backgroundColor: Color(0xFF4F46E5),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Ganti Password',
                          style: TextStyle(
                            fontSize: 15 * textScale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Label di atas TextFormField
  Widget _buildFieldLabel(String title, double textScale) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.5 * textScale,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  // Helper InputDecoration sesuai gambar referensi
  InputDecoration _buildInputDecoration({
    required String hintText,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: Color(0xFF64748B),
        size: 20,
      ),
      suffixIcon: IconButton(
        onPressed: onToggleVisibility,
        icon: Icon(
          isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: const Color(0xFF64748B),
          size: 20,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}
