class ApiConstants {
  // Replace this with your backend IP or domain
  // For Android Emulator, use http://10.0.2.2:5000/api/v1
  // For iOS Simulator, use http://127.0.0.1:5000/api/v1
  // For Physical Device, use your machine IP: http://10.10.5.53:5000/api/v1
  static const String baseUrl = 'http://187.77.187.56:5006/api/v1';

  // Auth Endpoints
  static const String login = '/users/login';
  static const String register = '/users/register';
  static const String profile = '/users/profile';

  // Academics Endpoints
  static const String lessons = '/lessons';
  static const String homework = '/homework';
  static const String academicDocument = '/academicDocument/student-documents';
  static const String stuAssignToClass = '/stuAssignToClass';

  // Quizzes Endpoints
  static const String quizzes = '/quizzes';
  static const String quizQA = '/quiz/qa';
  static const String submitQuiz = '/test/quizzes';
  static const String quizResults = '/test/quizzes/answers';

  // Attendance Endpoints
  static const String attendance = '/attendances/student';

  // Learning Tips Endpoints
  static const String learningTipsByParent = '/learning-tips/by-parent/me';
}
