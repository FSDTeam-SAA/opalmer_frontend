import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'student_profile.dart';
import '../navigation/teacher_workspace.dart';
import '../../core/models/teacher_class_model.dart';
import '../../core/providers/teacher_provider.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  final TeacherClassModel classData;
  final String? studentId;
  const StudentAttendanceScreen({
    Key? key,
    required this.classData,
    this.studentId,
  }) : super(key: key);

  @override
  ConsumerState<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState
    extends ConsumerState<StudentAttendanceScreen> {
  bool _isCreating = false;
  AsyncValue<List<dynamic>> _attendance = const AsyncLoading();
  final Set<String> _savingIds = {};

  Future<void> _updateStatus(
    String studentId,
    String attendanceId,
    String status,
  ) async {
    if (_savingIds.contains(attendanceId)) return;
    final rows = _attendance.asData?.value ?? [];
    final index = rows.indexWhere((row) => row['_id'] == attendanceId);
    if (index < 0 || rows[index]['status'] == status) return;
    final previous = Map<String, dynamic>.from(rows[index]);
    void replaceRow(Map<String, dynamic> row) {
      final current = List<dynamic>.from(_attendance.asData?.value ?? []);
      final position = current.indexWhere(
        (item) => item['_id'] == attendanceId,
      );
      if (position >= 0) current[position] = row;
      _attendance = AsyncData(current);
    }

    setState(() {
      _savingIds.add(attendanceId);
      replaceRow({...previous, 'status': status});
    });
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.patch(
        '/attendances/class/$attendanceId',
        data: {'status': status},
      );
      if (response.statusCode == 200 &&
          response.data['success'] == true &&
          response.data['data'] is Map) {
        if (!mounted) return;
        setState(
          () => replaceRow(Map<String, dynamic>.from(response.data['data'])),
        );
        ref.invalidate(classAttendanceProvider(widget.classData.id));
        ref.invalidate(classAttendanceStatsProvider(widget.classData.id));
        ref.invalidate(
          classDetailsAttendanceProvider('class|${widget.classData.id}'),
        );
        ref.invalidate(
          classDetailsAttendanceProvider(
            'student|$studentId|${widget.classData.id}',
          ),
        );
        ref.invalidate(
          studentAnalysisProvider('${widget.classData.id}|$studentId|weekly'),
        );
        ref.invalidate(
          studentAnalysisProvider('${widget.classData.id}|$studentId|monthly'),
        );
        ref.invalidate(
          studentAnalysisProvider('${widget.classData.id}|$studentId|daily'),
        );
        ref.invalidate(
          studentAttendanceStatsProvider('$studentId|${widget.classData.id}'),
        );
      } else {
        throw StateError('Attendance was not saved. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => replaceRow(previous));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _savingIds.remove(attendanceId));
    }
  }

  Future<void> _initTodayAttendance() async {
    if (!mounted) return;
    if (_isCreating) return;
    setState(() => _isCreating = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      // This endpoint creates attendance for missing students for today
      final response = await apiClient.post(
        '/attendances/class',
        data: {
          'classId': widget.classData.id,
          'date': DateTime.now().toIso8601String(),
        },
      );
      if (response.data['success'] != true || response.data['data'] is! Map) {
        throw StateError('Unable to load attendance');
      }
      final data = response.data['data'];
      if (!mounted) return;
      setState(
        () => _attendance = AsyncData([
          ...data['existing'] as List,
          ...data['created'] as List,
        ]),
      );
      ref.invalidate(classAttendanceProvider(widget.classData.id));
      ref.invalidate(
        classDetailsAttendanceProvider('class|${widget.classData.id}'),
      );
      for (final row in _attendance.asData?.value ?? []) {
        ref.invalidate(
          classDetailsAttendanceProvider(
            'student|${row['userId']}|${widget.classData.id}',
          ),
        );
      }
    } catch (e) {
      if (mounted)
        setState(() => _attendance = AsyncError(e, StackTrace.current));
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initTodayAttendance());
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(classStudentsProvider(widget.classData.id));
    final attendanceAsync = _attendance;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: AppPageHeader(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF871DAD),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Attendance",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Table Area ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEBD43),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Row(
                                children: const [
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  "Students Name",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 80,
                              child: Text(
                                "Status",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table Body
                      Expanded(
                        child: attendanceAsync.when(
                          data: (attendanceRecords) {
                            return studentsAsync.when(
                              data: (allStudents) {
                                final students = allStudents
                                    .where(
                                      (row) =>
                                          widget.studentId == null ||
                                          row['studentId']['_id']?.toString() ==
                                              widget.studentId,
                                    )
                                    .toList();
                                // Create a map of studentId -> attendanceRecord for quick lookup
                                final attendanceMap = {
                                  for (var record in attendanceRecords)
                                    record['userId']: record,
                                };

                                return ListView.builder(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 20,
                                  ),
                                  itemCount: students.length,
                                  itemBuilder: (context, index) {
                                    final assignment = students[index];
                                    final student = assignment['studentId'];
                                    if (student == null)
                                      return const SizedBox();

                                    final studentId = student['_id'];
                                    final record = attendanceMap[studentId];

                                    return _buildRow(
                                      record?['date'] is String
                                          ? DateFormat('dd-MM-yy').format(
                                              DateTime.parse(record['date']),
                                            )
                                          : 'N/A',
                                      student['username'] ??
                                          student['name'] ??
                                          'Unknown',
                                      record?['status'] ?? 'not_recorded',
                                      studentId,
                                      record?['_id'],
                                      student,
                                    );
                                  },
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (err, stack) =>
                                  Center(child: Text("Error: $err")),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Unable to load attendance.'),
                                TextButton(
                                  onPressed: _initTodayAttendance,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String date,
    String name,
    String status,
    String studentId,
    String? attendanceId,
    Map<String, dynamic> studentData,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              date,
              style: const TextStyle(color: Color(0xFF444444), fontSize: 13),
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeacherContextFrame(
                        classData: widget.classData,
                        student: studentData,
                        child: StudentProfileScreen(
                          studentData: studentData,
                          classId: widget.classData.id,
                        ),
                      ),
                    ),
                  );
                },
                child: Text(
                  '$name${studentData['Id'] == null ? '' : '\n${studentData['Id']}'}',
                  style: const TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 86,
            child: _buildStatusDropdown(status, studentId, attendanceId),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(
    String status,
    String studentId,
    String? attendanceId,
  ) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status.toLowerCase()) {
      case 'present':
        bgColor = const Color(0xFFCBEAD7);
        textColor = const Color(0xFF388D5E);
        text = "Present";
        break;
      case 'absent':
        bgColor = const Color(0xFFF7CFD1);
        textColor = const Color(0xFFC04345);
        text = "Absent";
        break;
      case 'late':
      case 'tardy':
        bgColor = const Color(0xFFCFE1EB);
        textColor = const Color(0xFF4C7B90);
        text = "Late";
        break;
      case 'excused':
        bgColor = const Color(0xFFCFE1EB);
        textColor = const Color(0xFF4C7B90);
        text = 'Excused';
        break;
      case 'holiday':
        bgColor = const Color(0xFFCFE1EB);
        textColor = const Color(0xFF4C7B90);
        text = 'Holiday';
        break;
      default:
        bgColor = const Color(0xFFF7CFD1);
        textColor = const Color(0xFFC04345);
        text = "Not recorded";
    }

    return PopupMenuButton<String>(
      enabled: attendanceId != null && !_savingIds.contains(attendanceId),
      onSelected: (newStatus) {
        if (attendanceId != null) {
          _updateStatus(studentId, attendanceId, newStatus);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'present', child: Text('Present')),
        const PopupMenuItem(value: 'absent', child: Text('Absent')),
        const PopupMenuItem(value: 'late', child: Text('Late')),
        const PopupMenuItem(value: 'excused', child: Text('Excused')),
        const PopupMenuItem(value: 'holiday', child: Text('Holiday')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            if (_savingIds.contains(attendanceId))
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            else
              Icon(Icons.keyboard_arrow_down, color: textColor, size: 16),
          ],
        ),
      ),
    );
  }
}
