import 'package:opalmer_education/core/models/user_model.dart';

class LessonModel {
  final String id;
  final String studentId;
  final String? teacherId;
  final String? classId;
  final String objective;
  final String note;
  final String? documentUrl;
  final bool isArchived;
  final DateTime? createdAt;
  final UserModel? teacher;

  LessonModel({
    required this.id,
    required this.studentId,
    this.teacherId,
    this.classId,
    required this.objective,
    required this.note,
    this.documentUrl,
    required this.isArchived,
    this.createdAt,
    this.teacher,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['_id'] ?? '',
      studentId: json['studentId'] is Map ? json['studentId']['_id'] : (json['studentId'] ?? ''),
      teacherId: json['teacherId'] is Map ? json['teacherId']['_id'] : json['teacherId'],
      classId: json['classId'] is Map ? json['classId']['_id'] : json['classId'],
      objective: json['objective'] ?? '',
      note: json['note'] ?? '',
      documentUrl: json['document']?['url'],
      isArchived: json['isArchived'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      teacher: json['teacherId'] is Map ? UserModel.fromJson(json['teacherId']) : null,
    );
  }
}

class HomeworkModel {
  final String id;
  final String classId;
  final String userId;
  final String title;
  final List<String> fileUrls;
  final bool archived;
  final DateTime? createdAt;

  HomeworkModel({
    required this.id,
    required this.classId,
    required this.userId,
    required this.title,
    required this.fileUrls,
    required this.archived,
    this.createdAt,
  });

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    var files = json['file'] as List? ?? [];
    List<String> urls = files.map((f) => f['url']?.toString() ?? '').where((url) => url.isNotEmpty).toList();

    return HomeworkModel(
      id: json['_id'] ?? '',
      classId: json['classId'] is Map ? json['classId']['_id'] : json['classId'],
      userId: json['userId'] is Map ? json['userId']['_id'] : (json['userId'] ?? ''),
      title: json['title'] ?? '',
      fileUrls: urls,
      archived: json['archived'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}

class QuizModel {
  final String id;
  final String title;
  final String? description;
  final String? classId;
  final String? teacherId;
  final DateTime? createdAt;
  final String? teacherName;
  final int questionCount;
  final int durationMinutes;

  QuizModel({
    required this.id,
    required this.title,
    this.description,
    this.classId,
    this.teacherId,
    this.createdAt,
    this.teacherName,
    this.questionCount = 0,
    this.durationMinutes = 0,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return QuizModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      classId: json['classId'] is Map ? json['classId']['_id'] : json['classId'],
      teacherId: json['teacherId'] is Map ? json['teacherId']['_id'] : json['teacherId'],
      teacherName: json['teacherId'] is Map ? json['teacherId']['username'] : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      questionCount: parseInt(json['questionCount']),
      durationMinutes: parseInt(json['time']),
    );
  }

  /// Human-friendly subtitle used on quiz cards. Falls back to the description
  /// when the backend hasn't populated counts yet.
  String get metaLine {
    final parts = <String>[];
    if (questionCount > 0) {
      parts.add('$questionCount ${questionCount == 1 ? 'Question' : 'Questions'}');
    }
    if (durationMinutes > 0) parts.add('$durationMinutes min');
    if (parts.isEmpty) return (description ?? '').trim();
    return parts.join(' · ');
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] ?? '',
    );
  }
}

class QuizQA {
  final String id;
  final String quizId;
  final List<QuizQuestion> questions;

  QuizQA({
    required this.id,
    required this.quizId,
    required this.questions,
  });

  factory QuizQA.fromJson(Map<String, dynamic> json) {
    var qs = json['questions'] as List? ?? [];
    return QuizQA(
      id: json['_id'] ?? '',
      quizId: json['quizId'] ?? '',
      questions: qs.map((q) => QuizQuestion.fromJson(q)).toList(),
    );
  }
}

class AttendanceRecord {
  final String id;
  final DateTime date;
  final String status; // e.g., "Present", "Absent"
  final String? note;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.status,
    this.note,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['_id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      status: (json['status'] ?? json['present'] ?? 'Absent').toString(),
      note: json['note'],
    );
  }

  bool get isPresent => status.toLowerCase() == 'present';
  bool get isHoliday => status.toLowerCase() == 'holiday';
}

class BehaviorRecord {
  final String id;
  final String message;
  final String state; // "positive" | "negative"
  final DateTime? createdAt;

  const BehaviorRecord({
    required this.id,
    required this.message,
    required this.state,
    this.createdAt,
  });

  factory BehaviorRecord.fromJson(Map<String, dynamic> json) {
    return BehaviorRecord(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      state: (json['state'] ?? 'positive').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  bool get isPositive => state.toLowerCase() == 'positive';
}

class QuizResultModel {
  final String id;
  final String? quizId;
  final String quizTitle;
  final int score;
  final double percentage;
  final String status;
  final DateTime? createdAt;

  QuizResultModel({
    required this.id,
    this.quizId,
    required this.quizTitle,
    required this.score,
    required this.percentage,
    required this.status,
    this.createdAt,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    // Handle both populated and non-populated quizId
    String title = "Unknown Quiz";
    String? qId;
    
    if (json['quizId'] is Map) {
      title = json['quizId']['title'] ?? "Unknown Quiz";
      qId = json['quizId']['_id'];
    } else {
      qId = json['quizId']?.toString();
    }

    return QuizResultModel(
      id: json['_id'] ?? '',
      quizId: qId,
      quizTitle: title,
      score: (json['score'] ?? 0).toInt(),
      percentage: (json['percentage'] ?? 0).toDouble() / 100.0, // Scale to 0.0-1.0 for progress bar
      status: json['progress']?['status'] ?? 'completed',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
