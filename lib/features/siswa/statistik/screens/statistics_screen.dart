import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:learnpoint_mobile/features/siswa/statistik/models/student_statistics_model.dart';
import 'package:learnpoint_mobile/features/siswa/statistik/providers/statistics_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StatisticsProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatisticsProvider>();
    final response = provider.response;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text('Statistik Belajar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1B4B),
        elevation: 0,
      ),
      body: provider.isLoading && response == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : provider.errorMessage != null && response == null
              ? _ErrorState(message: provider.errorMessage!, onRetry: provider.load)
              : RefreshIndicator(
                  onRefresh: () => provider.load(periodId: response?.selectedPeriod?.id),
                  color: const Color(0xFF4F46E5),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    children: [
                      _PeriodSelector(
                        selected: response?.selectedPeriod,
                        periods: response?.periods ?? const [],
                        onChanged: (period) => provider.load(periodId: period.id),
                      ),
                      const SizedBox(height: 18),
                      if (provider.errorMessage != null)
                        _InlineError(message: provider.errorMessage!, onRetry: provider.load),
                      if (provider.errorMessage != null) const SizedBox(height: 16),
                      if (response == null)
                        const _EmptyState()
                      else ...[
                        _SummaryCard(statistics: response.statistics),
                        const SizedBox(height: 18),
                        _ComponentSection(statistics: response.statistics),
                        const SizedBox(height: 18),
                        _ProgressSection(months: response.statistics.monthlyScores),
                        const SizedBox(height: 24),
                        _SubjectSection(subjects: response.statistics.subjects),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.periods, required this.onChanged});
  final AcademicPeriodModel? selected;
  final List<AcademicPeriodModel> periods;
  final ValueChanged<AcademicPeriodModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_month_rounded, color: Color(0xFF4F46E5)),
        const SizedBox(width: 10),
        Expanded(
          child: Text('Periode akademik', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF374151))),
        ),
        if (periods.length > 1)
          DropdownButton<int>(
            value: selected?.id,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(12),
            items: periods.map((period) => DropdownMenuItem(value: period.id, child: Text(period.label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)))).toList(),
            onChanged: (id) {
              for (final period in periods) {
                if (period.id == id) {
                  onChanged(period);
                  break;
                }
              }
            },
          )
        else
          Text(selected?.label ?? 'Belum tersedia', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF4F46E5))),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.statistics});
  final StudentStatisticsModel statistics;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(statistics.category);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF312E81)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: statistics.hasRealData
          ? Row(children: [
              SizedBox(width: 104, height: 104, child: Stack(alignment: Alignment.center, children: [
                SizedBox(width: 104, height: 104, child: CircularProgressIndicator(value: statistics.average.clamp(0, 100).toDouble() / 100, strokeWidth: 10, backgroundColor: Colors.white24, color: Colors.white)),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_score(statistics.average), style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                  Text('RATA-RATA', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700)),
                ]),
              ])),
              const SizedBox(width: 18),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pencapaian Belajarmu', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 7),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: .22), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: .7))), child: Text(statistics.category, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
                const SizedBox(height: 8),
                Text('Nilai dihitung dari aktivitas yang sudah dinilai.', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11, height: 1.4)),
              ])),
            ])
          : const _SummaryEmpty(),
    );
  }
}

class _SummaryEmpty extends StatelessWidget {
  const _SummaryEmpty();
  @override
  Widget build(BuildContext context) => Row(children: [
    const Icon(Icons.insights_outlined, color: Colors.white, size: 46), const SizedBox(width: 16),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Belum Ada Riwayat Nilai', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)), const SizedBox(height: 4),
      Text('Nilai akan muncul setelah tugas, kuis, atau ujian dinilai.', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12, height: 1.4)),
    ])),
  ]);
}

class _ComponentSection extends StatelessWidget {
  const _ComponentSection({required this.statistics});
  final StudentStatisticsModel statistics;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _SectionTitle(title: 'Ringkasan Penilaian'), const SizedBox(height: 12),
    Row(children: [
      Expanded(child: _ComponentCard(label: 'Tugas', average: statistics.tugasAverage, graded: statistics.tugasGraded, total: statistics.tugasTotal, color: const Color(0xFF2563EB), icon: Icons.assignment_rounded)),
      const SizedBox(width: 10), Expanded(child: _ComponentCard(label: 'Kuis', average: statistics.kuisAverage, graded: statistics.kuisGraded, total: statistics.kuisTotal, color: const Color(0xFFF59E0B), icon: Icons.quiz_rounded)),
      const SizedBox(width: 10), Expanded(child: _ComponentCard(label: 'Ujian', average: statistics.ujianAverage, graded: statistics.ujianGraded, total: statistics.ujianTotal, color: const Color(0xFF8B5CF6), icon: Icons.fact_check_rounded)),
    ]),
  ]);
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({required this.label, required this.average, required this.graded, required this.total, required this.color, required this.icon});
  final String label; final double average; final int graded; final int total; final Color color; final IconData icon;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEAECF0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 20, color: color), const SizedBox(height: 10), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF667085), fontWeight: FontWeight.w700)), const SizedBox(height: 3),
    Text(graded > 0 ? _score(average) : '-', style: GoogleFonts.plusJakartaSans(fontSize: 19, color: const Color(0xFF1E1B4B), fontWeight: FontWeight.w800)), const SizedBox(height: 4),
    Text('$graded/$total dinilai', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF98A2B3), fontWeight: FontWeight.w600)),
  ]));
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.months});
  final List<MonthlyScoreModel> months;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFEAECF0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const _SectionTitle(title: 'Perkembangan Nilai'), const SizedBox(height: 4), Text('Rata-rata nilai per bulan', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF667085))), const SizedBox(height: 14),
    if (months.any((month) => month.tugas != null || month.kuis != null || month.ujian != null)) ...[
      SizedBox(height: 175, child: CustomPaint(size: Size.infinite, painter: _ProgressPainter(months))), const SizedBox(height: 8), _Legend(),
    ] else Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Text('Belum ada perkembangan nilai pada periode ini.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF667085))))),
  ]));
}

class _SubjectSection extends StatelessWidget {
  const _SubjectSection({required this.subjects}); final List<SubjectScoreModel> subjects;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _SectionTitle(title: 'Nilai per Mata Pelajaran'), const SizedBox(height: 12),
    if (subjects.isEmpty) const _EmptyState() else ...subjects.map((subject) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _SubjectCard(subject: subject))),
  ]);
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject}); final SubjectScoreModel subject;
  @override
  Widget build(BuildContext context) {
    final completed = subject.isCompleted == true;
    final color = subject.score == null ? const Color(0xFF98A2B3) : completed ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEAECF0))), child: Row(children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.menu_book_rounded, color: color)), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(subject.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF1E1B4B))), const SizedBox(height: 4), Text('KKM ${_score(subject.kkm)}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF667085)))])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(subject.score == null ? '-' : _score(subject.score!), style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: color)), const SizedBox(height: 3), Text(subject.score == null ? 'Belum ada nilai' : completed ? 'Tuntas' : 'Belum tuntas', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color))]),
    ]));
  }
}

class _SectionTitle extends StatelessWidget { const _SectionTitle({required this.title}); final String title; @override Widget build(BuildContext context) => Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E1B4B))); }
class _Legend extends StatelessWidget { @override Widget build(BuildContext context) => const Row(mainAxisAlignment: MainAxisAlignment.center, children: [_LegendItem('Tugas', Color(0xFF2563EB)), SizedBox(width: 16), _LegendItem('Kuis', Color(0xFFF59E0B)), SizedBox(width: 16), _LegendItem('Ujian', Color(0xFF8B5CF6))]); }
class _LegendItem extends StatelessWidget { const _LegendItem(this.label, this.color); final String label; final Color color; @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF667085)))]); }
class _EmptyState extends StatelessWidget { const _EmptyState(); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Center(child: Text('Belum ada data statistik.'))); }
class _ErrorState extends StatelessWidget { const _ErrorState({required this.message, required this.onRetry}); final String message; final VoidCallback onRetry; @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFF667085)), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center), const SizedBox(height: 12), ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi'))]))); }
class _InlineError extends StatelessWidget { const _InlineError({required this.message, required this.onRetry}); final String message; final VoidCallback onRetry; @override Widget build(BuildContext context) => Material(color: const Color(0xFFFFF4ED), borderRadius: BorderRadius.circular(12), child: ListTile(leading: const Icon(Icons.error_outline, color: Color(0xFFD92D20)), title: Text(message, style: const TextStyle(fontSize: 12)), trailing: TextButton(onPressed: onRetry, child: const Text('Ulangi')))); }

class _ProgressPainter extends CustomPainter {
  _ProgressPainter(this.months); final List<MonthlyScoreModel> months;
  @override void paint(Canvas canvas, Size size) {
    const left = 25.0; const right = 8.0; const top = 8.0; const bottom = 28.0;
    final plotWidth = size.width - left - right; final plotHeight = size.height - top - bottom;
    final grid = Paint()..color = const Color(0xFFEAECF0)..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) { final y = top + plotHeight * i / 4; canvas.drawLine(Offset(left, y), Offset(size.width - right, y), grid); }
    _drawSeries(canvas, size, months.map((item) => item.tugas).toList(), const Color(0xFF2563EB), left, top, plotWidth, plotHeight);
    _drawSeries(canvas, size, months.map((item) => item.kuis).toList(), const Color(0xFFF59E0B), left, top, plotWidth, plotHeight);
    _drawSeries(canvas, size, months.map((item) => item.ujian).toList(), const Color(0xFF8B5CF6), left, top, plotWidth, plotHeight);
    final style = TextStyle(color: const Color(0xFF98A2B3), fontSize: 9); for (var i = 0; i < months.length; i++) { final x = months.length == 1 ? left + plotWidth / 2 : left + plotWidth * i / (months.length - 1); final text = TextPainter(text: TextSpan(text: months[i].label, style: style), textDirection: TextDirection.ltr)..layout(maxWidth: 40); text.paint(canvas, Offset(x - text.width / 2, size.height - 17)); }
  }
  void _drawSeries(Canvas canvas, Size size, List<double?> values, Color color, double left, double top, double width, double height) {
    final points = <Offset>[]; for (var i = 0; i < values.length; i++) { final value = values[i]; if (value == null) continue; final x = values.length == 1 ? left + width / 2 : left + width * i / (values.length - 1); points.add(Offset(x, top + height * (1 - value.clamp(0, 100).toDouble() / 100))); }
    if (points.isEmpty) return; final paint = Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round; final path = Path()..moveTo(points.first.dx, points.first.dy); for (final point in points.skip(1)) { path.lineTo(point.dx, point.dy); } canvas.drawPath(path, paint); final dot = Paint()..color = color..style = PaintingStyle.fill; for (final point in points) { canvas.drawCircle(point, 3.5, dot); }
  }
  @override bool shouldRepaint(covariant _ProgressPainter oldDelegate) => oldDelegate.months != months;
}

String _score(double score) => score == score.roundToDouble() ? score.toStringAsFixed(0) : score.toStringAsFixed(1);
Color _categoryColor(String category) => switch (category) { 'Sangat Baik' => const Color(0xFF10B981), 'Baik' => const Color(0xFF2563EB), 'Cukup' => const Color(0xFFF59E0B), 'Perlu Bimbingan' => const Color(0xFFF43F5E), _ => const Color(0xFF94A3B8) };
