class ScheduleItemModel {
  final String day;
  final String time;
  final String duration;
  final String subject;
  final String room;
  final String teacher;
  final bool isToday;

  const ScheduleItemModel({
    required this.day,
    required this.time,
    required this.duration,
    required this.subject,
    required this.room,
    required this.teacher,
    this.isToday = false,
  });
}
