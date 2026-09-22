class StudentProfileModel {
  final String name;
  final String gradeClass;
  final String schoolName;
  final String initials;
  final bool hasNotification;

  const StudentProfileModel({
    required this.name,
    required this.gradeClass,
    required this.schoolName,
    required this.initials,
    this.hasNotification = true,
  });
}
