enum AttendanceStatus { present, absent, leftClassroom }

class AttendanceRecord {
  final String date;
  final String studentName;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.date,
    required this.studentName,
    required this.status,
  });

  String get statusText {
    switch (status) {
      case AttendanceStatus.present:
        return "Present";
      case AttendanceStatus.absent:
        return "Absent";
      case AttendanceStatus.leftClassroom:
        return "left classroom";
    }
  }
}

const List<AttendanceRecord> mockAttendance = [
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.absent),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.leftClassroom),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.absent),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
  AttendanceRecord(date: "06-03-25", studentName: "Mia Johnson", status: AttendanceStatus.present),
];
