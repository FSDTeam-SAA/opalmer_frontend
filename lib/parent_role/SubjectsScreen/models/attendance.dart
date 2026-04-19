enum AttendanceStatus { present, absent, tardy, holiday, unknown }

class AttendanceRecord {
  final String id;
  final String date;
  final String studentName;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.id,
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
      case AttendanceStatus.tardy:
        return "Tardy";
      case AttendanceStatus.holiday:
        return "Holiday";
      case AttendanceStatus.unknown:
        return "—";
    }
  }

  factory AttendanceRecord.fromJson(
    Map<String, dynamic> json, {
    String studentNameFallback = '',
  }) {
    return AttendanceRecord(
      id: (json['_id'] ?? '').toString(),
      date: _formatDate(json['date']) ?? '—',
      studentName: studentNameFallback,
      status: _parseStatus(json['status']),
    );
  }

  static AttendanceStatus _parseStatus(dynamic raw) {
    if (raw is! String) return AttendanceStatus.unknown;
    switch (raw.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'tardy':
        return AttendanceStatus.tardy;
      case 'holiday':
        return AttendanceStatus.holiday;
      default:
        return AttendanceStatus.unknown;
    }
  }

  static String? _formatDate(dynamic iso) {
    if (iso is! String || iso.isEmpty) return null;
    try {
      final d = DateTime.parse(iso).toLocal();
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final yy = (d.year % 100).toString().padLeft(2, '0');
      return '$dd-$mm-$yy';
    } catch (_) {
      return null;
    }
  }
}