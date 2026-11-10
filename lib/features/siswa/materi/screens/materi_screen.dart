import 'package:flutter/material.dart';


import 'package:learnpoint_mobile/features/siswa/materi/screens/materi_per_mapel_screen.dart';
import 'package:learnpoint_mobile/features/siswa/profile/screens/akun_screen.dart';
import 'package:learnpoint_mobile/features/siswa/profile/models/student_profile_model.dart';
import 'package:learnpoint_mobile/core/widgets/inverted_top_curve_clipper.dart';
import 'package:learnpoint_mobile/features/siswa/materi/widgets/subject_materi_card_widget.dart';
import 'package:learnpoint_mobile/features/siswa/materi/models/materi_model.dart';
import 'package:learnpoint_mobile/features/siswa/materi/data/materi_service.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/screens/notifikasi_screen.dart';
import 'package:learnpoint_mobile/features/siswa/dashboard/widgets/dashboard_header_widget.dart';

class Materi extends StatefulWidget {
  final VoidCallback? onBackTap;
  const Materi({super.key, this.onBackTap});

  // Dummy Profile Data
  static const studentProfile = StudentProfileModel(
    name: 'Abimanyu',
    gradeClass: 'Kelas VIII-A',
    schoolName: 'SMP Merdeka',
    initials: 'AP',
    hasNotification: true,
  );

  @override
  State<Materi> createState() => _MateriState();
}

class _MateriState extends State<Materi> {
  final TextEditingController _searchController = TextEditingController();
  List<MateriModel> _daftarMapel = List<MateriModel>.from(subjek);
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDaftarMapel();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDaftarMapel() async {
    setState(() {
      _isLoading = true;
    });
    final result = await MateriService.fetchDaftarMapelSiswa();
    if (!mounted) return;
    setState(() {
      _daftarMapel = result;
      _isLoading = false;
    });
  }

  List<MateriModel> get _filteredMapel {
    if (_searchQuery.trim().isEmpty) {
      return _daftarMapel;
    }
    final q = _searchQuery.trim().toLowerCase();
    return _daftarMapel.where((item) {
      return item.materi.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textScale = (screenWidth / 400).clamp(0.9, 1.1).toDouble();
    final filtered = _filteredMapel;

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 114, 61, 237),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: DashboardHeaderWidget(
                  profile: Materi.studentProfile,
                  onNotificationTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                  onProfileTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const AkunScreen(profile: Materi.studentProfile),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: widget.onBackTap ?? () => Navigator.maybePop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Text(
                          'Materi Pembelajaran',
                          style: TextStyle(
                            fontSize: 30 * textScale,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = const Color(0xB32C2C2C),
                          ),
                        ),
                        Text(
                          'Materi Pembelajaran',
                          style: TextStyle(
                            fontSize: 30 * textScale,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Temukan materi untuk belajarmu',
                        style: TextStyle(
                          fontSize: 15 * textScale,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari materi...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              // Daftar mata pelajaran
              Expanded(
                child: ClipPath(
                  clipper: const InvertedTopCurveClipper(
                    cornerRadius: 15,
                    curveDepth: 20,
                    centerX: 0.5,
                    curveHalfWidth: 0.52,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.fromLTRB(0, 45, 0, 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      ),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: _loadDaftarMapel,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final cardHorizontalMargin =
                                    constraints.maxWidth < 360 ? 12.0 : 20.0;

                                if (filtered.isEmpty) {
                                  return ListView(
                                    children: const [
                                      SizedBox(height: 60),
                                      Center(
                                        child: Text(
                                          'Mata pelajaran tidak ditemukan.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final sub = filtered[index];

                                    return SubjectMateriCardWidget(
                                      subject: sub,
                                      imageUrl:
                                          'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=1200&q=80',
                                      elevation: index.isEven ? 2 : 0,
                                      horizontalMargin: cardHorizontalMargin,
                                      ontap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                Materimapel(subject: sub),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
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
}
