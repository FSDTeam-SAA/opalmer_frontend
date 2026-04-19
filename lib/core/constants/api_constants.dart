class ApiConstants {
  // Replace this with your backend IP or domain
  // For Android Emulator, use http://10.0.2.2:5000/api/v1
  // For iOS Simulator, use http://127.0.0.1:5000/api/v1
  // For Physical Device, use your machine IP: http://10.10.5.53:5000/api/v1
  static const String baseUrl = 'http://localhost:5000/api/v1';

  // Auth Endpoints
  static const String login = '/users/login';
  static const String register = '/users/register';

  static const String me = '/users/me';
  static const String changePassword = '/users/change-password';
  

  static const String profile = '/users/profile';
  // Academics Endpoints
  static const String lessons = '/lessons';
  static const String homework = '/homework';
  static const String academicDocument = '/academicDocument/student-documents';
  static const String stuAssignToClass = '/student-assign-to-class';

  // Quizzes Endpoints
  static const String quizzes = '/quizzes';
  static const String quizQA = '/quiz/qa';
  static const String submitQuiz = '/test/quizzes';
  static const String quizResults = '/test/quizzes/answers';

  // Attendance Endpoints
  static const String attendance = '/attendances/student';


  // Behavior
  static const String studentBehaviors = '/behavior/student-behaviors';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read';

  // Socket
  static const String socketBaseUrl = 'http://127.0.0.1:5000';

  // Learning Tips Endpoints
  static const String learningTipsByParent = '/learning-tips/by-parent/me';

}
