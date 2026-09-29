import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String subject;
  final String title;
  final String deadline;
  final String timeRemainingTag;
  final Color subjectColor;
  final Color accentBorderColor;
  final IconData icon;
  final Color iconBgColor;

  const TaskModel({
    required this.id,
    required this.subject,
    required this.title,
    required this.deadline,
    required this.timeRemainingTag,
    required this.subjectColor,
    required this.accentBorderColor,
    required this.icon,
    required this.iconBgColor,
  });
}
