class Subject {
  final String id;
  final String name;
  final String attendance;
  final String attendanceEmoji;
  final String performance;
  final String teacherName;
  final String teacherAvatar;
  final String date;
  final List<SubjectProgressPoint>? weeklyProgress;

  const Subject({
    required this.id,
    required this.name,
    required this.attendance,
    required this.attendanceEmoji,
    required this.performance,
    required this.teacherName,
    required this.teacherAvatar,
    required this.date,
    this.weeklyProgress,
  });
}

class SubjectProgressPoint {
  final double x; // Represents day (0-6)
  final double y; // Represents percentage (0-100)
  final String dayLabel;

  const SubjectProgressPoint(this.x, this.y, this.dayLabel);
}

class ChildProfile {
  final String id;
  final String name;
  final String imageUrl;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

const List<ChildProfile> mockChildren = [
  ChildProfile(
    id: "1",
    name: "Mia Johnson",
    imageUrl: "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?auto=format&fit=crop&w=150&q=80",
  ),
  ChildProfile(
    id: "2",
    name: "Alex Johnson",
    imageUrl: "https://images.unsplash.com/photo-1517677129300-07b130802f46?auto=format&fit=crop&w=150&q=80",
  ),
];

// Mock Progress Data
const List<SubjectProgressPoint> scienceProgress = [
  SubjectProgressPoint(0, 30, "Sun"),
  SubjectProgressPoint(1, 38, "Mon"),
  SubjectProgressPoint(2, 32, "Tue"),
  SubjectProgressPoint(3, 45, "Wed"),
  SubjectProgressPoint(4, 55, "Thu"),
  SubjectProgressPoint(5, 42, "Fri"),
  SubjectProgressPoint(6, 42, "Sat"),
];

const List<Subject> mockSubjects = [
  Subject(
    id: "s1",
    name: "Science",
    attendance: "92%",
    attendanceEmoji: "😇",
    performance: "85%",
    teacherName: "Olivia Carter",
    teacherAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=60",
    date: "06-03-25",
    weeklyProgress: scienceProgress,
  ),
  Subject(
    id: "s2",
    name: "Mathematics",
    attendance: "88%",
    attendanceEmoji: "😎",
    performance: "90%",
    teacherName: "Benjamin Wade",
    teacherAvatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=100&q=60",
    date: "06-03-25",
  ),
  Subject(
    id: "s3",
    name: "English",
    attendance: "95%",
    attendanceEmoji: "🌟",
    performance: "92%",
    teacherName: "Sophia Miller",
    teacherAvatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=60",
    date: "06-03-25",
  ),
];
