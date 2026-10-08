import 'package:flutter/material.dart';

import '../../models/task_model.dart';

class TaskCardWidget extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  const TaskCardWidget({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

// HEADER SECTION (Nama Mapel Tanpa Badge & Status Kanan)
                Row(
                  children: [
                    // 1. Nama Mapel (Teks biasa tanpa Container/Badge)
                    Text(
                      task.subject,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: task.subjectColor,
                      ),
                    ),

                    const Spacer(),

                    // 2. Badge Status Kanan Atas (Terlambat / Sisa Waktu / Tepat Waktu)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: task.accentBorderColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            task.isSubmitted
                                ? Icons.check_circle
                                : Icons.access_time_filled,
                            size: 12,
                            color: task.accentBorderColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.timeRemainingTag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: task.accentBorderColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // CONTENT SECTION (Ikon Kotak + Judul + Deadline)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container Ikon Tugas Berbentuk Kotak
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: task.iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        task.icon,
                        color: task.subjectColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Detail Judul Tugas dan Info Tenggat
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul Utama Tugas
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Baris Tanggal Deadline
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  task.deadline,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Garis Pemisah (Divider) Antara Konten dan Footer
                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                const SizedBox(height: 12),

                // FOOTER SECTION (Catatan & Tombol Aksi)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.footerNote ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    if (!task.isSubmitted)
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: task.subjectColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Kumpulkan",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      )
                    else if (task.score != null)
                      RichText(
                        text: TextSpan(
                          text: "Nilai Tugas: ",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          children: [
                            TextSpan(
                              text: task.score,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Text(
                        "Menunggu hasil",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}