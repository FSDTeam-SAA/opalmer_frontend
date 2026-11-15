class NotificationModel {
  final String id;
  final String to;
  final String message;
  final String type;
  final String? refId;
  final String? studentId;
  final bool isViewed;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.to,
    required this.message,
    required this.type,
    this.refId,
    this.studentId,
    required this.isViewed,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      to: (json['to'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? 'general').toString(),
      refId: json['id']?.toString(),
      studentId: json['studentId']?.toString(),
      isViewed: json['isViewed'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  NotificationModel copyWith({bool? isViewed}) {
    return NotificationModel(
      id: id,
      to: to,
      message: message,
      type: type,
      refId: refId,
      studentId: studentId,
      isViewed: isViewed ?? this.isViewed,
      createdAt: createdAt,
    );
  }

  /// Human-friendly title derived from notification type.
  String get title {
    switch (type.toLowerCase()) {
      case 'quiz':
        return 'New Assessment';
      case 'quiz_result':
      case 'grade':
      case 'assignment_grade':
        return 'New Grades Posted';
      case 'homework':
        return 'New Homework';
      case 'lesson':
        return 'New Lesson';
      case 'attendance':
        return 'Attendance Update';
      case 'behavior':
        return 'Behavior Update';
      case 'message':
        return 'New Message';
      case 'schedule':
        return "Today's Schedule";
      case 'exam':
        return 'Upcoming Exam';
      case 'announcement':
      case 'admin_announcement':
        return 'Announcement';
      case 'academicdocument':
      case 'academic_document':
        return 'Academic Document';
      case 'homework_help':
        return 'Homework Help';
      case 'submission':
        return 'Assignment Submitted';
      case 'class':
        return 'Class Update';
      default:
        return 'Notification';
    }
  }
}
