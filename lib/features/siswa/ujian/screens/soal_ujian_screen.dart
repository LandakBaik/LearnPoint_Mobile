import 'dart:async';
import 'package:flutter/material.dart';
import 'package:learnpoint_mobile/core/config/api_config.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/models/ujian_model.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/screens/hasil_ujian_screen.dart';
import 'package:learnpoint_mobile/features/siswa/ujian/services/ujian_api_service.dart';

const Color primaryBlue = Color(0xFF0757C9);
const Color darkText = Color(0xFF13233A);
const Color secondaryText = Color(0xFF596579);
const Color lightBlue = Color(0xFFEAF4FF);
const Color cardBlue = Color(0xFFF0F5FF);
const Color greenColor = Color(0xFF008A63);

class QuizStartPage extends StatefulWidget {
  final int ujianId;

  const QuizStartPage({super.key, required this.ujianId});

  @override
  State<QuizStartPage> createState() => _QuizStartPageState();
}

class _QuizStartPageState extends State<QuizStartPage> with WidgetsBindingObserver {
  final TextEditingController _essayController = TextEditingController();
  final TextEditingController _unlockCodeController = TextEditingController();

  UjianKerjakanData? _data;
  bool _isLoading = true;
  String? _errorMessage;

  int _currentIndex = 0;
  int _sisaDetik = 0;
  bool _isSaving = false;
  bool _lastSaved = false;
  bool _isSubmitting = false;

  // Anti-cheat state
  int _pelanggaranCount = 0;
  int _maxToleransi = 3;
  bool _isLocked = false;
  bool _cooldownPelanggaran = false;
  bool _isUnlocking = false;
  String? _unlockError;

  // Jawaban berbasis soal_id
  final Map<int, dynamic> _answers = {};

  Timer? _countdownTimer;
  Timer? _heartbeatTimer;
  Timer? _essayDebounce;
  int? _pendingEssaySoalId;
  String? _pendingEssayValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLembarUjian();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _heartbeatTimer?.cancel();
    _essayDebounce?.cancel();
    _essayController.dispose();
    _unlockCodeController.dispose();
    super.dispose();
  }

  /// Deteksi siswa meninggalkan aplikasi (Home / Recent Apps / Split Screen)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (!_isLoading && !_isSubmitting && !_isLocked && _data != null) {
        _laporkanPelanggaran('Keluar dari aplikasi saat ujian berlangsung');
      }
    }
  }

  Future<void> _loadLembarUjian() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final res = await UjianApiService.getLembarKerjakan(widget.ujianId);
      if (!mounted) return;

      _answers.clear();
      for (final soal in res.soals) {
        final raw = res.savedAnswers[soal.id] ?? soal.savedAnswer;
        if (raw != null && raw.isNotEmpty) {
          if (soal.tipeSoal == 'multiple_choice') {
            _answers[soal.id] = raw
                .split(',')
                .map((e) => e.trim().toLowerCase())
                .where((e) => e.isNotEmpty)
                .toList();
          } else {
            _answers[soal.id] = raw;
          }
        }
      }

      setState(() {
        _data = res;
        _sisaDetik = res.sisaDetik;
        _pelanggaranCount = res.pelanggaranCount;
        _isLocked = res.statusSesi == 'terkunci';
        _currentIndex = 0;
        _isLoading = false;
      });

      _syncEssayController();
      _mulaiTimer();
      _mulaiHeartbeat();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<UjianSoalItem> get _soals => _data?.soals ?? [];
  UjianSoalItem? get _currentSoal =>
      (_soals.isNotEmpty && _currentIndex < _soals.length) ? _soals[_currentIndex] : null;

  void _syncEssayController() {
    final soal = _currentSoal;
    if (soal != null && soal.tipeSoal == 'essay') {
      final saved = _answers[soal.id];
      _essayController.text = saved is String ? saved : '';
      _essayController.selection = TextSelection.collapsed(
        offset: _essayController.text.length,
      );
    } else {
      _essayController.clear();
    }
  }

  void _mulaiTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isSubmitting) {
        timer.cancel();
        return;
      }
      if (_sisaDetik > 0) {
        setState(() => _sisaDetik--);
      } else {
        timer.cancel();
        _eksekusiSubmit(otomatis: true, pesan: 'Waktu ujian telah berakhir! Jawaban otomatis dikumpulkan.');
      }
    });
  }

  void _mulaiHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (!mounted || _isSubmitting) return;
      try {
        final statusData = await UjianApiService.cekStatusSesi(widget.ujianId);
        if (!mounted || _isSubmitting) return;

        final status = statusData['status']?.toString();
        final isTimeout = statusData['is_timeout'] == true;

        if (status == 'ditarik') {
          _countdownTimer?.cancel();
          _heartbeatTimer?.cancel();
          _tampilkanPesanLaluKeluar(
            statusData['message']?.toString() ?? 'Ujian sedang ditarik oleh guru pengawas.',
          );
          return;
        }

        if (status == 'selesai') {
          _countdownTimer?.cancel();
          _heartbeatTimer?.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ujian Anda telah diselesaikan oleh pengawas.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HasilUjianPage(ujianId: widget.ujianId)),
          );
          return;
        }

        if (isTimeout) {
          _eksekusiSubmit(otomatis: true, pesan: 'Waktu sesi telah berakhir.');
          return;
        }

        if (status == 'terkunci' && !_isLocked) {
          setState(() => _isLocked = true);
        } else if (status == 'sedang_mengerjakan' && _isLocked) {
          setState(() {
            _isLocked = false;
            _pelanggaranCount = int.tryParse('${statusData['pelanggaran_count'] ?? 0}') ?? 0;
            _unlockError = null;
          });
        }
      } catch (_) {
        // Abaikan error jaringan sementara pada heartbeat
      }
    });
  }

  void _tampilkanPesanLaluKeluar(String pesan) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Pemberitahuan'),
        content: Text(pesan),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Future<void> _laporkanPelanggaran(String alasan) async {
    if (_cooldownPelanggaran || _isLocked || _isSubmitting) return;
    _cooldownPelanggaran = true;
    Future.delayed(const Duration(seconds: 3), () => _cooldownPelanggaran = false);

    try {
      final res = await UjianApiService.catatPelanggaran(
        ujianId: widget.ujianId,
        alasan: alasan,
      );
      if (!mounted) return;

      final count = int.tryParse('${res['pelanggaran_count'] ?? _pelanggaranCount}') ?? _pelanggaranCount;
      final maxTol = int.tryParse('${res['max_toleransi'] ?? 3}') ?? 3;
      final locked = res['is_locked'] == true;

      setState(() {
        _pelanggaranCount = count;
        _maxToleransi = maxTol;
        _isLocked = locked;
      });

      if (!locked && mounted) {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 26),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Peringatan Anti-Curang!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            content: Text(
              'Anda terdeteksi meninggalkan aplikasi saat ujian.\n\n'
              'Peringatan ke-$count dari $maxTol. Jika mencapai $maxTol kali, sesi Anda akan terkunci otomatis.',
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Saya Mengerti'),
              ),
            ],
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _submitUnlockCode() async {
    final kode = _unlockCodeController.text.trim();
    if (kode.isEmpty || _isUnlocking) return;

    setState(() {
      _isUnlocking = true;
      _unlockError = null;
    });

    try {
      final res = await UjianApiService.bukaKunciDenganKode(
        ujianId: widget.ujianId,
        kode: kode,
      );
      if (!mounted) return;
      _unlockCodeController.clear();
      final updatedCount = int.tryParse(
        '${res['pelanggaran_count'] ?? _pelanggaranCount}',
      );
      setState(() {
        _isLocked = false;
        _pelanggaranCount = updatedCount ?? _pelanggaranCount;
        _isUnlocking = false;
        _unlockError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUnlocking = false;
        _unlockError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  bool _isSoalTerjawab(int soalId) {
    final val = _answers[soalId];
    if (val == null) return false;
    if (val is List) return val.isNotEmpty;
    return val.toString().trim().isNotEmpty;
  }

  Future<void> _kirimAutoSave(int soalId, dynamic nilai) async {
    if (!mounted) return;
    setState(() {
      _isSaving = true;
      _lastSaved = false;
    });
    try {
      await UjianApiService.simpanJawaban(
        ujianId: widget.ujianId,
        soalId: soalId,
        jawaban: nilai,
      );
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _lastSaved = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _lastSaved = false);
      });
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _pilihSingleChoice(int soalId, String kode) {
    setState(() => _answers[soalId] = kode);
    _kirimAutoSave(soalId, kode);
  }

  void _toggleMultipleChoice(int soalId, String kode) {
    final current = _answers[soalId] is List
        ? List<String>.from(_answers[soalId] as List)
        : <String>[];

    if (current.contains(kode)) {
      current.remove(kode);
    } else {
      current.add(kode);
    }
    setState(() => _answers[soalId] = current);
    _kirimAutoSave(soalId, current.join(','));
  }

  void _ubahJawabanEssay(int soalId, String teks) {
    setState(() => _answers[soalId] = teks);
    _pendingEssaySoalId = soalId;
    _pendingEssayValue = teks;

    _essayDebounce?.cancel();
    _essayDebounce = Timer(const Duration(milliseconds: 700), () {
      _flushPendingEssay();
    });
  }

  Future<void> _flushPendingEssay() async {
    _essayDebounce?.cancel();
    if (_pendingEssaySoalId != null) {
      final id = _pendingEssaySoalId!;
      final val = _pendingEssayValue ?? '';
      _pendingEssaySoalId = null;
      _pendingEssayValue = null;
      await _kirimAutoSave(id, val);
    }
  }

  Future<void> _pindahSoal(int targetIndex) async {
    if (targetIndex < 0 || targetIndex >= _soals.length) return;
    await _flushPendingEssay();
    setState(() => _currentIndex = targetIndex);
    _syncEssayController();
  }

  Future<void> _konfirmasiKumpul({bool dariTombolKeluar = false}) async {
    await _flushPendingEssay();
    if (!mounted) return;

    final dijawab = _soals.where((s) => _isSoalTerjawab(s.id)).length;
    final total = _soals.length;

    final konfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(
              dariTombolKeluar ? Icons.exit_to_app_rounded : Icons.check_circle_outline,
              color: dariTombolKeluar ? Colors.red : greenColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                dariTombolKeluar ? 'Keluar & Kumpulkan?' : 'Kumpulkan Ujian?',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          dariTombolKeluar
              ? 'Jika Anda keluar sekarang, seluruh jawaban ($dijawab dari $total soal) akan OTOMATIS DIKUMPULKAN dan sesi dinyatakan SELESAI.'
              : (dijawab < total
                  ? 'Anda baru menjawab $dijawab dari $total soal. Yakin ingin mengumpulkan ujian sekarang?'
                  : 'Semua soal ($total) telah dijawab. Yakin ingin mengumpulkan ujian sekarang?'),
          style: const TextStyle(fontSize: 13, color: secondaryText, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: dariTombolKeluar ? Colors.red : greenColor,
              foregroundColor: Colors.white,
            ),
            child: Text(dariTombolKeluar ? 'Kumpulkan & Keluar' : 'Ya, Kumpulkan'),
          ),
        ],
      ),
    );

    if (konfirm == true) {
      await _eksekusiSubmit();
    }
  }

  Future<void> _eksekusiSubmit({bool otomatis = false, String? pesan}) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    _countdownTimer?.cancel();
    _heartbeatTimer?.cancel();
    await _flushPendingEssay();

    // Siapkan batch jawaban sebagai backup jika ada auto-save yang tertinggal
    final batch = <String, dynamic>{};
    _answers.forEach((soalId, value) {
      if (value is List) {
        batch[soalId.toString()] = value.join(',');
      } else if (value != null) {
        batch[soalId.toString()] = value.toString();
      }
    });

    try {
      await UjianApiService.submitUjian(
        ujianId: widget.ujianId,
        jawabanBatch: batch,
      );
      if (!mounted) return;
      if (pesan != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HasilUjianPage(ujianId: widget.ujianId)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Gagal mengumpulkan ujian: ${e.toString().replaceFirst('Exception: ', '')}'),
        ),
      );
      if (!otomatis) {
        _mulaiTimer();
        _mulaiHeartbeat();
      }
    }
  }

  void _bukaNavigasiNomorSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Navigasi Nomor Soal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: darkText),
                ),
                Text(
                  '${_soals.where((s) => _isSoalTerjawab(s.id)).length}/${_soals.length} Terjawab',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: greenColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15,
                ),
                itemCount: _soals.length,
                itemBuilder: (_, idx) {
                  final s = _soals[idx];
                  final answered = _isSoalTerjawab(s.id);
                  final active = idx == _currentIndex;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _pindahSoal(idx);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: answered ? greenColor : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: active ? Border.all(color: primaryBlue, width: 2.5) : null,
                      ),
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: answered ? Colors.white : darkText,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimer(int totalSeconds) {
    final sec = totalSeconds < 0 ? 0 : totalSeconds;
    final h = (sec ~/ 3600).toString().padLeft(2, '0');
    final m = ((sec % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  int _countWords(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isLoading && _data != null && !_isLocked) {
          _konfirmasiKumpul(dariTombolKeluar: true);
        } else if (!didPop && (_data == null || _errorMessage != null)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: lightBlue,
        body: SafeArea(
          child: Stack(
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: primaryBlue))
              else if (_errorMessage != null || _data == null || _soals.isEmpty)
                _buildErrorState()
              else
                Column(
                  children: [
                    _buildExamHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          children: [
                            _buildInfoBanner(),
                            _buildQuestionCard(),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomAction(),
                  ],
                ),

              // Overlay Layar Terkunci (Anti-Curang)
              if (_isLocked) _buildLockedOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock_outlined, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Soal ujian belum tersedia.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: secondaryText, height: 1.5),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamHeader() {
    final total = _soals.length;
    final answeredCount = _soals.where((s) => _isSoalTerjawab(s.id)).length;
    final progress = total > 0 ? answeredCount / total : 0.0;
    final isLowTime = _sisaDetik < 300;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _konfirmasiKumpul(dariTombolKeluar: true),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.exit_to_app_rounded, size: 15, color: Color(0xFFC62828)),
                      SizedBox(width: 4),
                      Text(
                        'Keluar',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFC62828)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _data?.judul ?? 'Ujian',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: darkText),
                ),
              ),
              if (_isSaving)
                const Text('Menyimpan...', style: TextStyle(fontSize: 10.5, color: primaryBlue, fontWeight: FontWeight.w600))
              else if (_lastSaved)
                const Text('✓ Tersimpan', style: TextStyle(fontSize: 10.5, color: greenColor, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              InkWell(
                onTap: _bukaNavigasiNomorSheet,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.grid_view_rounded, color: primaryBlue, size: 17),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentIndex + 1}/$total',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: darkText),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: isLowTime ? const Color(0xFFFFEBEE) : const Color(0xFFCBEAFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: isLowTime ? Colors.red : const Color(0xFF0874AD),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatTimer(_sisaDetik),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isLowTime ? Colors.red : const Color(0xFF16466B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Terjawab', style: TextStyle(fontSize: 11.5, color: secondaryText)),
                        ),
                        Text(
                          '${(progress * 100).round()}% ($answeredCount/$total)',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: primaryBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFDCE8FA),
                        valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    final soal = _currentSoal;
    if (soal == null) return const SizedBox.shrink();

    final String message;
    if (soal.tipeSoal == 'essay') {
      message = 'Tuliskan jawaban uraianmu dengan jelas. Jawaban tersimpan otomatis.';
    } else if (soal.tipeSoal == 'multiple_choice') {
      message = 'Kamu dapat memilih lebih dari satu jawaban yang benar.';
    } else {
      message = 'Pilih satu jawaban yang paling tepat.';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: primaryBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.5, color: darkText, height: 1.4, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final soal = _currentSoal;
    if (soal == null) return const SizedBox.shrink();

    final saved = _answers[soal.id];
    final selectedMulti = saved is List ? saved.map((e) => e.toString()).toList() : <String>[];
    final imageUrl = ApiConfig.publicAssetUrl(soal.gambar);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  'Soal No. ${_currentIndex + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFCBEAFF), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  soal.tipeLabel,
                  style: const TextStyle(color: Color(0xFF0874AD), fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium_outlined, color: greenColor, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Bobot: ${soal.bobot.toStringAsFixed(soal.bobot % 1 == 0 ? 0 : 1)} Poin',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: darkText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.all(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  height: 200,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Gambar soal gagal dimuat.', style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            soal.pertanyaan,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: darkText, height: 1.55),
          ),
          const SizedBox(height: 18),

          // 1. ESSAY
          if (soal.tipeSoal == 'essay') ...[
            Row(
              children: [
                const Icon(Icons.edit_note_rounded, color: greenColor, size: 20),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Jawaban Esai',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF4C5668)),
                  ),
                ),
                Text(
                  '${_countWords(_essayController.text)} kata',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: greenColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD8E4F7)),
              ),
              child: TextField(
                controller: _essayController,
                minLines: 6,
                maxLines: 12,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 14.5, color: darkText, height: 1.55),
                decoration: const InputDecoration(
                  hintText: 'Tuliskan jawaban esai kamu secara lengkap di sini...',
                  hintStyle: TextStyle(color: Color(0xFF8B96A8), fontSize: 13.5),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
                onChanged: (val) => _ubahJawabanEssay(soal.id, val),
              ),
            ),
          ]
          // 2. PILIHAN GANDA TUNGGAL & KOMPLEKS
          else ...[
            ...soal.pilihan.map((opsi) {
              final bool isSelected = soal.tipeSoal == 'multiple_choice'
                  ? selectedMulti.contains(opsi.kode)
                  : (saved?.toString().toLowerCase() == opsi.kode);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    if (soal.tipeSoal == 'multiple_choice') {
                      _toggleMultipleChoice(soal.id, opsi.kode);
                    } else {
                      _pilihSingleChoice(soal.id, opsi.kode);
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEAF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? primaryBlue : const Color(0xFFDCE5F3),
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? primaryBlue : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            opsi.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isSelected ? Colors.white : darkText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            opsi.teks,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: darkText,
                              height: 1.4,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            soal.tipeSoal == 'multiple_choice'
                                ? Icons.check_box_rounded
                                : Icons.check_circle_rounded,
                            color: primaryBlue,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final isLast = _currentIndex >= _soals.length - 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1E7F0), width: 0.8)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 48,
            child: ElevatedButton(
              onPressed: _currentIndex > 0 ? () => _pindahSoal(_currentIndex - 1) : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFFDCE8FA),
                foregroundColor: darkText,
                disabledBackgroundColor: const Color(0xFFEAF0F8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              child: const Icon(Icons.chevron_left, size: 26),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        if (isLast) {
                          _konfirmasiKumpul();
                        } else {
                          _pindahSoal(_currentIndex + 1);
                        }
                      },
                icon: Icon(
                  isLast ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                  size: 20,
                ),
                label: Text(
                  _isSubmitting
                      ? 'Mengumpulkan...'
                      : (isLast ? 'Selesai & Kumpulkan' : 'Soal Selanjutnya'),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: isLast ? greenColor : primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return Container(
      color: const Color(0xF00F172A),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.lock_rounded, color: Colors.red, size: 32),
            ),
            const SizedBox(height: 14),
            const Text(
              'Sesi Ujian Terkunci',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkText),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda melampaui batas toleransi meninggalkan layar ($_pelanggaranCount/$_maxToleransi pelanggaran). '
              'Masukkan Kode Buka Blokir dari pengawas atau tunggu pengawas membuka kunci dari panel monitoring.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: secondaryText, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _unlockCodeController,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 3),
              decoration: InputDecoration(
                hintText: 'KODE BUKA BLOKIR',
                hintStyle: const TextStyle(fontSize: 12, letterSpacing: 1),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_unlockError != null) ...[
              const SizedBox(height: 8),
              Text(_unlockError!, style: const TextStyle(fontSize: 11.5, color: Colors.red, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _isUnlocking ? null : _submitUnlockCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isUnlocking ? 'Memverifikasi...' : 'Buka Blokir & Lanjutkan',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}