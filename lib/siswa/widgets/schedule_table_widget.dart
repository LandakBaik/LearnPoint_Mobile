import 'package:flutter/material.dart';
import '../../models/schedule_model.dart';

class ScheduleTableWidget extends StatelessWidget {
  final List<ScheduleItemModel> schedules;

  const ScheduleTableWidget({
    super.key,
    required this.schedules,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3B82F6), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 12,
            headingRowHeight: 38,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 40,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
            columns: const [
              DataColumn(
                label: Text(
                  'Hari',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Jam',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Durasi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Mata Kuliah',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Ruang',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Dosen / Asisten',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ],
            rows: schedules.map((item) {
              final rowBgColor = item.isToday
                  ? const Color(0xFFFACC15) // Golden Yellow highlight
                  : Colors.white;

              final textStyle = TextStyle(
                fontSize: 10,
                fontWeight: item.isToday ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF1E293B),
              );

              return DataRow(
                color: WidgetStateProperty.all(rowBgColor),
                cells: [
                  DataCell(Text(item.day, style: textStyle)),
                  DataCell(Text(item.time, style: textStyle)),
                  DataCell(Text(item.duration, style: textStyle)),
                  DataCell(Text(item.subject, style: textStyle)),
                  DataCell(Text(item.room, style: textStyle)),
                  DataCell(Text(item.teacher, style: textStyle)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
