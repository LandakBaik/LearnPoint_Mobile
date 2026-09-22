import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class TaskCardWidget extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.onTap,
  });

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Content Area
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject Icon Container
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: task.iconBgColor,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            task.icon,
                            color: task.subjectColor,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Detail Information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Subject Title + Time Remaining Badge
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    task.subject,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: task.subjectColor,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: task.subjectColor ==
                                              const Color(0xFF2563EB)
                                          ? const Color(0xFFFEE2E2)
                                          : const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      task.timeRemainingTag,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: task.subjectColor ==
                                                const Color(0xFF2563EB)
                                            ? const Color(0xFFDC2626)
                                            : const Color(0xFF4F46E5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // Task Title
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 6),

                              // Deadline Info
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Deadline: ${task.deadline}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Right Accent Bar
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: task.accentBorderColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
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
