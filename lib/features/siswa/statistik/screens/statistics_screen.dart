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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Statistik Belajar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: provider.isLoading && response == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : provider.errorMessage != null && response == null
              ? _ErrorState(message: provider.errorMessage!, onRetry: provider.load)
              : RefreshIndicator(
                  onRefresh: () => provider.load(periodId: response?.selectedPeriod?.id),
                  color: const Color(0xFF2563EB),
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
        const Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB)),
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
          Text(selected?.label ?? 'Belum tersedia', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB))),
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
        gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
    Text(graded > 0 ? _score(average) : '-', style: GoogleFonts.plusJakartaSans(fontSize: 19, color: const Color(0xFF1E293B), fontWeight: FontWeight.w800)), const SizedBox(height: 4),
    Text('$graded/$total dinilai', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF98A2B3), fontWeight: FontWeight.w600)),
  ]));
}

class _ProgressSection extends StatefulWidget {
  const _ProgressSection({required this.months});
  final List<MonthlyScoreModel> months;

  @override
  State<_ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<_ProgressSection> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant _ProgressSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.months != widget.months) {
      _selectedIndex = null;
    }
  }

  void _selectAt(double localX, double chartWidth) {
    if (widget.months.isEmpty) return;
    const left = _ProgressPainter.leftPadding;
    const right = _ProgressPainter.rightPadding;
    final plotWidth = chartWidth - left - right;
    if (plotWidth <= 0) return;

    final int index;
    if (widget.months.length == 1) {
      index = 0;
    } else {
      final ratio = ((localX - left) / plotWidth).clamp(0.0, 1.0);
      index = (ratio * (widget.months.length - 1)).round();
    }

    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final months = widget.months;
    final hasAnyData = months.any(
      (month) => month.tugas != null || month.kuis != null || month.ujian != null,
    );
    final selectedMonth = _selectedIndex != null &&
            _selectedIndex! >= 0 &&
            _selectedIndex! < months.length
        ? months[_selectedIndex!]
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Perkembangan Nilai'),
          const SizedBox(height: 4),
          Text(
            hasAnyData
                ? 'Rata-rata nilai per bulan • Ketuk grafik untuk detail'
                : 'Rata-rata nilai per bulan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 14),
          if (hasAnyData) ...[
            if (selectedMonth != null) ...[
              _SelectedMonthTooltip(
                month: selectedMonth,
                onClear: () => setState(() => _selectedIndex = null),
              ),
              const SizedBox(height: 10),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => _selectAt(
                    details.localPosition.dx,
                    constraints.maxWidth,
                  ),
                  onHorizontalDragUpdate: (details) => _selectAt(
                    details.localPosition.dx,
                    constraints.maxWidth,
                  ),
                  child: SizedBox(
                    height: 185,
                    width: double.infinity,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, 185),
                      painter: _ProgressPainter(
                        months,
                        selectedIndex: _selectedIndex,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            const _Legend(),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Belum ada perkembangan nilai pada periode ini.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF667085),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectedMonthTooltip extends StatelessWidget {
  const _SelectedMonthTooltip({
    required this.month,
    required this.onClear,
  });

  final MonthlyScoreModel month;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(
            month.label.isEmpty ? 'Bulan' : month.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                _MiniScoreBadge(
                  label: 'Tugas',
                  value: month.tugas,
                  color: const Color(0xFF2563EB),
                ),
                _MiniScoreBadge(
                  label: 'Kuis',
                  value: month.kuis,
                  color: const Color(0xFFF59E0B),
                ),
                _MiniScoreBadge(
                  label: 'Ujian',
                  value: month.ujian,
                  color: const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniScoreBadge extends StatelessWidget {
  const _MiniScoreBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ${value == null ? '-' : _score(value!)}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
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
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(subject.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))), const SizedBox(height: 4), Text('KKM ${_score(subject.kkm)}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF667085)))])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(subject.score == null ? '-' : _score(subject.score!), style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: color)), const SizedBox(height: 3), Text(subject.score == null ? 'Belum ada nilai' : completed ? 'Tuntas' : 'Belum tuntas', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color))]),
    ]));
  }
}

class _SectionTitle extends StatelessWidget { const _SectionTitle({required this.title}); final String title; @override Widget build(BuildContext context) => Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))); }
class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) => const Row(mainAxisAlignment: MainAxisAlignment.center, children: [_LegendItem('Tugas', Color(0xFF2563EB)), SizedBox(width: 16), _LegendItem('Kuis', Color(0xFFF59E0B)), SizedBox(width: 16), _LegendItem('Ujian', Color(0xFF8B5CF6))]);
}
class _LegendItem extends StatelessWidget { const _LegendItem(this.label, this.color); final String label; final Color color; @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF667085)))]); }
class _EmptyState extends StatelessWidget { const _EmptyState(); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Center(child: Text('Belum ada data statistik.'))); }
class _ErrorState extends StatelessWidget { const _ErrorState({required this.message, required this.onRetry}); final String message; final VoidCallback onRetry; @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFF667085)), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center), const SizedBox(height: 12), ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi'))]))); }
class _InlineError extends StatelessWidget { const _InlineError({required this.message, required this.onRetry}); final String message; final VoidCallback onRetry; @override Widget build(BuildContext context) => Material(color: const Color(0xFFFFF4ED), borderRadius: BorderRadius.circular(12), child: ListTile(leading: const Icon(Icons.error_outline, color: Color(0xFFD92D20)), title: Text(message, style: const TextStyle(fontSize: 12)), trailing: TextButton(onPressed: onRetry, child: const Text('Ulangi')))); }

class _ProgressPainter extends CustomPainter {
  _ProgressPainter(this.months, {this.selectedIndex});

  final List<MonthlyScoreModel> months;
  final int? selectedIndex;

  static const double leftPadding = 30.0;
  static const double rightPadding = 12.0;
  static const double topPadding = 10.0;
  static const double bottomPadding = 28.0;

  double _xForIndex(int index, double plotWidth) {
    if (months.length <= 1) return leftPadding + plotWidth / 2;
    return leftPadding + plotWidth * index / (months.length - 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final plotWidth = size.width - leftPadding - rightPadding;
    final plotHeight = size.height - topPadding - bottomPadding;
    if (plotWidth <= 0 || plotHeight <= 0) return;

    final gridPaint = Paint()
      ..color = const Color(0xFFEAECF0)
      ..strokeWidth = 1;
    const axisLabelStyle = TextStyle(
      color: Color(0xFF98A2B3),
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );

    // Grid horizontal + label sumbu Y (100, 75, 50, 25, 0)
    for (var i = 0; i <= 4; i++) {
      final y = topPadding + plotHeight * i / 4;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final labelValue = (100 - i * 25).toString();
      final yText = TextPainter(
        text: TextSpan(text: labelValue, style: axisLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: leftPadding - 6);
      yText.paint(
        canvas,
        Offset(leftPadding - yText.width - 6, y - yText.height / 2),
      );
    }

    // Highlight garis vertikal untuk bulan yang dipilih
    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < months.length) {
      final selectedX = _xForIndex(selectedIndex!, plotWidth);
      final guidePaint = Paint()
        ..color = const Color(0xFF2563EB).withValues(alpha: 0.22)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(selectedX, topPadding),
        Offset(selectedX, topPadding + plotHeight),
        guidePaint,
      );
    }

    _drawSeries(
      canvas,
      months.map((item) => item.tugas).toList(),
      const Color(0xFF2563EB),
      plotWidth,
      plotHeight,
    );
    _drawSeries(
      canvas,
      months.map((item) => item.kuis).toList(),
      const Color(0xFFF59E0B),
      plotWidth,
      plotHeight,
    );
    _drawSeries(
      canvas,
      months.map((item) => item.ujian).toList(),
      const Color(0xFF8B5CF6),
      plotWidth,
      plotHeight,
    );

    // Label sumbu X dengan step otomatis agar tidak bertumpukan
    final maxVisibleLabels = (plotWidth / 44).floor().clamp(1, months.length);
    final labelStep =
        (months.length / maxVisibleLabels).ceil().clamp(1, months.length);

    for (var i = 0; i < months.length; i++) {
      final isSelected = i == selectedIndex;
      final isFirstOrLast = i == 0 || i == months.length - 1;
      if (!isSelected && i % labelStep != 0 && !isFirstOrLast) continue;
      if (!isSelected &&
          labelStep > 1 &&
          i == months.length - 1 &&
          months.length > 2 &&
          (i - 1) % labelStep == 0) {
        continue;
      }

      final x = _xForIndex(i, plotWidth);
      final text = TextPainter(
        text: TextSpan(
          text: months[i].label,
          style: isSelected
              ? axisLabelStyle.copyWith(
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w800,
                )
              : axisLabelStyle,
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: 42);

      final dx = (x - text.width / 2).clamp(
        leftPadding,
        size.width - rightPadding - text.width,
      );
      text.paint(canvas, Offset(dx, size.height - 17));
    }
  }

  void _drawSeries(
    Canvas canvas,
    List<double?> values,
    Color color,
    double plotWidth,
    double plotHeight,
  ) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final haloPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    var currentSegment = <Offset>[];
    final allDots = <(int, Offset)>[];

    void flushSegment() {
      if (currentSegment.length >= 2) {
        final path = Path()
          ..moveTo(currentSegment.first.dx, currentSegment.first.dy);
        for (final point in currentSegment.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawPath(path, linePaint);
      }
      currentSegment = <Offset>[];
    }

    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value == null) {
        flushSegment();
        continue;
      }
      final x = _xForIndex(i, plotWidth);
      final y =
          topPadding + plotHeight * (1 - value.clamp(0, 100).toDouble() / 100);
      final point = Offset(x, y);
      currentSegment.add(point);
      allDots.add((i, point));
    }
    flushSegment();

    for (final (index, point) in allDots) {
      if (index == selectedIndex) {
        canvas.drawCircle(point, 7.5, haloPaint);
        canvas.drawCircle(point, 4.5, dotPaint);
      } else {
        canvas.drawCircle(point, 3.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) =>
      oldDelegate.months != months || oldDelegate.selectedIndex != selectedIndex;
}

String _score(double score) => score == score.roundToDouble() ? score.toStringAsFixed(0) : score.toStringAsFixed(1);
Color _categoryColor(String category) => switch (category) { 'Sangat Baik' => const Color(0xFF10B981), 'Baik' => const Color(0xFF2563EB), 'Cukup' => const Color(0xFFF59E0B), 'Perlu Bimbingan' => const Color(0xFFF43F5E), _ => const Color(0xFF94A3B8) };
