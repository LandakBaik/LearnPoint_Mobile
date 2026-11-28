import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:learnpoint_mobile/features/siswa/mapel/widgets/mapel_skeleton_widget.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/models/task_model.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/detail_tugas_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/screens/detail_tugas_pilgan_screen.dart';
import 'package:learnpoint_mobile/features/siswa/tugas/services/task_api_service.dart';

class TugasSection extends StatefulWidget {
  final int? mapelId;
  final String subjectName;

  const TugasSection({super.key, this.mapelId, this.subjectName = ''});

  @override
  State<TugasSection> createState() => TugasSectionState();
}

class TugasSectionState extends State<TugasSection> {
  Future<void> refresh() => _loadTasks();
  List<Map<String, dynamic>> tasks = [];

  bool isLoading = true;
  String? errorMessage;
  bool showAllCompleted = false;

  // ============================================================
  // WARNA
  // ============================================================

  static const Color primary = Color(0xFF2563EB);
  static const Color dark = Color(0xFF1E293B);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE4EAF4);

  static const Color orange = Color(0xFFED9B32);
  static const Color red = Color(0xFFE53935);
  static const Color green = Color(0xFF219653);

  static const Color orangeBg = Color(0xFFFFF5E9);
  static const Color redBg = Color(0xFFFFEEEE);
  static const Color greenBg = Color(0xFFEAF6EF);
  static const Color blueBg = Color(0xFFEFF6FF);

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didUpdateWidget(covariant TugasSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mapelId != widget.mapelId ||
        oldWidget.subjectName != widget.subjectName) {
      showAllCompleted = false;
      _loadTasks();
    }
  }

  // ============================================================
  // MEMBACA NILAI DARI BEBERAPA KEMUNGKINAN FIELD API
  // ============================================================

  dynamic _firstValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  int? _parseId(dynamic value) {
    if (value == null) return null;

    if (value is Map) {
      value = value['id'] ?? value['mapel_id'] ?? value['mata_pelajaran_id'];
    }

    return int.tryParse(value.toString());
  }

  // ============================================================
  // AMBIL ID MAPEL DARI DATA TUGAS
  // ============================================================

  int? _getTaskMapelId(Map<String, dynamic> task) {
    final directId = _firstValue(task, [
      'mapel_id',
      'mata_pelajaran_id',
      'id_mapel',
      'id_mata_pelajaran',
      'subject_id',
    ]);

    if (directId != null) {
      return _parseId(directId);
    }

    for (final key in ['mapel', 'mata_pelajaran', 'mataPelajaran', 'subject']) {
      final relation = task[key];

      if (relation is Map) {
        final id =
            relation['id'] ??
            relation['mapel_id'] ??
            relation['mata_pelajaran_id'];

        if (id != null) {
          return _parseId(id);
        }
      }
    }

    return null;
  }

  // ============================================================
  // AMBIL NAMA MAPEL DARI DATA TUGAS
  // ============================================================

  String _getTaskMapelName(Map<String, dynamic> task) {
    final directName = _firstValue(task, [
      'nama_mapel',
      'mapel_nama',
      'nama_mata_pelajaran',
      'subject_name',
    ]);

    if (directName != null) {
      return directName.toString().trim();
    }

    for (final key in ['mapel', 'mata_pelajaran', 'mataPelajaran', 'subject']) {
      final relation = task[key];

      if (relation is String) {
        return relation.trim();
      }

      if (relation is Map) {
        final name =
            relation['nama'] ??
            relation['nama_mapel'] ??
            relation['name'] ??
            relation['judul'];

        if (name != null) {
          return name.toString().trim();
        }
      }
    }

    return '';
  }

  // ============================================================
  // FILTER TUGAS SESUAI MAPEL YANG DIPILIH
  // ============================================================

  bool _belongsToSelectedMapel(Map<String, dynamic> task) {
    final selectedId = widget.mapelId;
    final selectedName = widget.subjectName.trim().toLowerCase();

    final taskMapelId = _getTaskMapelId(task);
    final taskMapelName = _getTaskMapelName(task).toLowerCase();

    // Jika data tugas memiliki ID mapel, cocokkan berdasarkan ID.
    if (selectedId != null && taskMapelId != null) {
      return taskMapelId == selectedId;
    }

    // Jika ID tidak tersedia, gunakan nama mapel sebagai alternatif.
    if (selectedName.isNotEmpty && taskMapelName.isNotEmpty) {
      return taskMapelName == selectedName;
    }

    // Jangan tampilkan tugas yang mapelnya tidak dapat diidentifikasi.
    return false;
  }

  // ============================================================
  // LOAD TUGAS
  // ============================================================

  Future<void> _loadTasks() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await TaskApiService.getTasks();

      final allTasks = List<Map<String, dynamic>>.from(result);

      final filteredTasks = allTasks.where(_belongsToSelectedMapel).toList();

      if (!mounted) return;

      setState(() {
        tasks = filteredTasks;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // ============================================================
  // SUBMISSION
  // ============================================================

  Map<String, dynamic>? _submission(Map<String, dynamic> task) {
    final data = task['submission'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  // ============================================================
  // CEK SUDAH DIKUMPULKAN
  // ============================================================

  bool _isSubmitted(Map<String, dynamic> task) {
    final submitted = task['is_submitted'];

    if (submitted == true || submitted == 1 || submitted == '1') {
      return true;
    }

    final submission = _submission(task);

    if (submission != null && submission.isNotEmpty) {
      return true;
    }

    return false;
  }

  // ============================================================
  // CEK SUDAH DINILAI
  // ============================================================

  bool _hasGrade(Map<String, dynamic> task) {
    final submission = _submission(task);

    if (submission != null) {
      for (final key in ['nilai', 'score', 'grade', 'nilai_akhir']) {
        final value = submission[key];

        if (value != null && value.toString().trim().isNotEmpty) {
          return true;
        }
      }
    }

    for (final key in ['nilai', 'score', 'grade', 'nilai_akhir']) {
      final value = task[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // JENIS TUGAS
  // ============================================================

  bool _isPilgan(Map<String, dynamic> task) {
    final type = task['tipe']?.toString().toLowerCase().trim();

    return type == 'pilihan_ganda' ||
        type == 'pilgan' ||
        type == 'pilihan ganda';
  }

  // ============================================================
  // DEADLINE
  // ============================================================

  DateTime? _deadline(Map<String, dynamic> task) {
    final value = task['deadline']?.toString();

    if (value == null || value.isEmpty) return null;

    return DateTime.tryParse(value)?.toLocal();
  }

  bool _isLate(Map<String, dynamic> task) {
    if (_isSubmitted(task)) return false;

    final deadline = _deadline(task);

    if (deadline == null) return false;

    return DateTime.now().isAfter(deadline);
  }

  // ============================================================
  // FORMAT DEADLINE
  // ============================================================

  String _formatDeadline(Map<String, dynamic> task) {
    final date = _deadline(task);

    if (date == null) return 'Deadline belum ditentukan';

    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return "${date.day} ${monthNames[date.month - 1]} ${date.year}";
  }

  // ============================================================
  // INFO SISA WAKTU
  // ============================================================

  String _deadlineStatus(Map<String, dynamic> task) {
    final deadline = _deadline(task);

    if (deadline == null) return 'Deadline tidak tersedia';

    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      final lateDays = difference.inDays.abs();

      if (lateDays == 0) {
        return 'Terlambat hari ini';
      }

      return 'Terlambat $lateDays hari';
    }

    if (difference.inDays >= 1) {
      return '${difference.inDays} hari lagi';
    }

    if (difference.inHours >= 1) {
      return '${difference.inHours} jam lagi';
    }

    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} menit lagi';
    }

    return 'Segera dikumpulkan';
  }

  // ============================================================
  // DAFTAR TUGAS BELUM DIKERJAKAN
  // ============================================================

  List<Map<String, dynamic>> get pendingTasks {
    return tasks.where((task) => !_isSubmitted(task)).toList()..sort((a, b) {
      final dateA = _deadline(a);
      final dateB = _deadline(b);

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateA.compareTo(dateB);
    });
  }

  // ============================================================
  // DAFTAR TUGAS SELESAI / DIKUMPULKAN
  // ============================================================

  List<Map<String, dynamic>> get completedTasks {
    return tasks.where((task) => _isSubmitted(task)).toList()..sort((a, b) {
      final dateA = _deadline(a);
      final dateB = _deadline(b);

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });
  }

  // ============================================================
  // NAVIGASI DETAIL TUGAS
  // ============================================================

  void _openDetail(Map<String, dynamic> task) {
    final late = _isLate(task);
    final submitted = _isSubmitted(task);

    final taskModel = TaskModel(
      id: task['id'].toString(),
      subject: _getTaskMapelName(task).isNotEmpty
          ? _getTaskMapelName(task)
          : widget.subjectName,
      title: task['judul']?.toString() ?? 'Tanpa Judul',
      description: task['deskripsi']?.toString() ?? '',
      deadline: task['deadline']?.toString() ?? '',
      timeRemainingTag: submitted
          ? (_hasGrade(task)
                ? 'Tugas telah dinilai'
                : 'Tugas telah dikumpulkan')
          : _deadlineStatus(task),
      subjectColor: muted,
      accentBorderColor: late ? red : primary,
      icon: Icons.assignment_outlined,
      iconBgColor: const Color(0xFFF0F4F9),
      isSubmitted: submitted,
      type: task['tipe']?.toString() ?? 'upload',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (_isPilgan(task)) {
            return DetailTugasPilganScreen(task: taskModel);
          }

          return DetailTugasPage(task: taskModel);
        },
      ),
    ).then((_) {
      if (mounted) {
        _loadTasks();
      }
    });
  }

  // ============================================================
  // TEXT STYLE
  // ============================================================

  TextStyle _textStyle({
    double size = 12,
    Color color = dark,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const DetailMapelListSkeletonWidget();
    }

    if (errorMessage != null) {
      return _buildError();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPendingPanel(),

        const SizedBox(height: 12),

        const Divider(height: 1, thickness: 0.8, color: Color(0xFFE6E8EF)),

        const SizedBox(height: 12),

        _buildCompletedPanel(),
      ],
    );
  }

  // ============================================================
  // PANEL BELUM DIKERJAKAN
  // ============================================================

  Widget _buildPendingPanel() {
    final data = pendingTasks;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 10),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Belum Dikerjakan',
                  style: _textStyle(size: 16, weight: FontWeight.w800),
                ),
              ),
              _countBadge(
                count: data.length,
                color: primary,
                background: blueBg,
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (data.isEmpty)
            SizedBox(
              width: double.infinity,
              height: 130,
              child: Center(
                child: _buildPanelEmpty(
                  icon: Icons.task_alt_rounded,
                  message: 'Semua tugas sudah dikumpulkan',
                ),
              ),
            )
          else
            Column(
              children: List.generate(data.length, (index) {
                final task = data[index];

                return _buildTaskRow(
                  task: task,
                  isCompleted: false,
                  showDivider: index != data.length - 1,
                );
              }),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PANEL SELESAI
  // ============================================================

  Widget _buildCompletedPanel() {
    final data = completedTasks;

    final visibleTasks = showAllCompleted ? data : data.take(3).toList();

    final hasMore = data.length > 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 10),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Selesai',
                  style: _textStyle(size: 16, weight: FontWeight.w800),
                ),
              ),
              _countBadge(
                count: data.length,
                color: green,
                background: greenBg,
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (data.isEmpty)
            SizedBox(
              width: double.infinity,
              height: 130,
              child: Center(
                child: _buildPanelEmpty(
                  icon: Icons.assignment_outlined,
                  message: 'Belum ada tugas yang dikumpulkan',
                ),
              ),
            )
          else
            Column(
              children: List.generate(visibleTasks.length, (index) {
                final task = visibleTasks[index];

                return _buildTaskRow(
                  task: task,
                  isCompleted: true,
                  showDivider:
                      index != visibleTasks.length - 1 ||
                      (hasMore && !showAllCompleted),
                );
              }),
            ),

          if (hasMore) ...[
            const SizedBox(height: 5),
            InkWell(
              onTap: () {
                setState(() {
                  showAllCompleted = !showAllCompleted;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showAllCompleted
                          ? 'Tampilkan lebih sedikit'
                          : 'Lihat semua',
                      style: _textStyle(
                        size: 11,
                        color: primary,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      showAllCompleted
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 17,
                      color: primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  // ============================================================
  // TASK ROW
  // ============================================================

  Widget _buildTaskRow({
    required Map<String, dynamic> task,
    required bool isCompleted,
    required bool showDivider,
  }) {
    final title = task['judul']?.toString() ?? 'Tanpa Judul';
    final late = !isCompleted && _isLate(task);
    final deadline = _deadline(task);

    return Column(
      children: [
        InkWell(
          onTap: () => _openDetail(task),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTaskIcon(isCompleted),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _textStyle(
                          size: 13,
                          color: dark,
                          weight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),

                      if (isCompleted)
                        Text(
                          'Berhasil dikumpulkan',
                          style: _textStyle(
                            size: 11,
                            color: green,
                            weight: FontWeight.w500,
                          ),
                        )
                      else ...[
                        if (deadline != null)
                          _buildDeadlineRow(task, late)
                        else
                          Text(
                            'Deadline belum ditentukan',
                            style: _textStyle(size: 10, color: muted),
                          ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 5),

                const Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
                  color: Color(0xFF7B8494),
                ),
              ],
            ),
          ),
        ),

        if (showDivider)
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFE5EAF4)),
      ],
    );
  }

  // ============================================================
  // IKON TUGAS
  // ============================================================

  Widget _buildTaskIcon(bool isCompleted) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFBFD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 24,
              color: Color.fromARGB(255, 114, 61, 237),
            ),
          ),

          if (isCompleted)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 17, color: green),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // DEADLINE ROW
  // ============================================================

  Widget _buildDeadlineRow(Map<String, dynamic> task, bool late) {
    final color = late ? red : muted;
    final background = late ? redBg : orangeBg;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      runSpacing: 4,
      children: [
        Icon(
          Icons.calendar_month_outlined,
          size: 14,
          color: late ? red : primary,
        ),

        Text(
          'Deadline ${_formatDeadline(task)}',
          style: _textStyle(size: 10, color: muted, weight: FontWeight.w500),
        ),

        Text('•', style: _textStyle(size: 10, color: muted)),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (late) ...[
                const Icon(Icons.error_rounded, size: 12, color: red),
                const SizedBox(width: 3),
              ],
              Text(
                _deadlineStatus(task),
                style: _textStyle(
                  size: 10,
                  color: late ? red : orange,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COUNT BADGE
  // ============================================================

  Widget _countBadge({
    required int count,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "$count tugas",
        style: _textStyle(size: 11, color: color, weight: FontWeight.w800),
      ),
    );
  }

  // ============================================================
  // EMPTY PANEL
  // ============================================================

  Widget _buildPanelEmpty({required IconData icon, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(icon, size: 25, color: muted.withValues(alpha: 0.65)),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: _textStyle(size: 10, color: muted),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PANEL DECORATION
  // ============================================================

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFFE7EDF6), width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF213D68).withValues(alpha: 0.045),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 29, color: muted),
          const SizedBox(height: 8),
          Text(
            'Tugas gagal dimuat',
            style: _textStyle(size: 12, weight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          TextButton(
            onPressed: _loadTasks,
            child: Text(
              'Coba Lagi',
              style: _textStyle(
                size: 11,
                color: primary,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
