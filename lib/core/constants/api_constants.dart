class ApiConstants {
  // Replace this with your backend IP or domain
  // For Android Emulator, use http://10.0.2.2:5000/api/v1
  // For iOS Simulator, use http://localhost:5000/api/v1
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // Auth Endpoints
  static const String login = '/users/login';
  static const String register = '/users/register';
  static const String profile = '/users/profile';
  
  // Academics Endpoints
  static const String lessons = '/lessons';
  static const String homework = '/homework';
  static const String academicDocument = '/academicDocument';
  static const String stuAssignToClass = '/stuAssignToClass';
  
  // Quizzes Endpoints
  static const String quizzes = '/quizzes';
  static const String quizQA = '/quiz/qa';
  static const String submitQuiz = '/test/quizzes';
  
  // Attendance Endpoints
  static const String attendance = '/attendances/student';
}
