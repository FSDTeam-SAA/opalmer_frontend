import 'package:opalmer_education/core/widgets/app_home_button.dart';
import '../../core/widgets/performance_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/chat/providers/chat_provider.dart';
import '../../core/providers/teacher_provider.dart';
import 'package:opalmer_education/chat/models/chat_role.dart';
import 'package:opalmer_education/chat/screens/call.dart';
import 'package:opalmer_education/chat/screens/chat_screen.dart';
import 'package:opalmer_education/chat/services/chat_api_service.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/constants/api_constants.dart';

import 'behavior_record.dart';
import 'academic_documents.dart';
import 'grading_progress.dart';
import '../navigation/teacher_student_actions.dart';
import '../navigation/teacher_workspace.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> studentData;
  final String? classId;

  const StudentProfileScreen({
    Key? key,
    required this.studentData,
    this.classId,
  }) : super(key: key);

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  String _selectedFilter = 'weekly';

  Color _getAttendanceColor(int percentage) {
    if (percentage >= 90) return const Color(0xFF4AA678); // Green
    if (percentage >= 80) return const Color(0xFF3F99B4); // Blue
    if (percentage >= 70) return const Color(0xFFFEBD43); // Yellow
    return const Color(0xFFC04345); // Red
  }

  String _getAttendanceEmoji(int percentage) {
    if (percentage >= 90) return "😋";
    if (percentage >= 80) return "😐";
    if (percentage >= 70) return "😋"; // Using same for now, or 🤑
    return "😡";
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.studentData;
    final studentId = student['_id'] ?? '';
    final classId = widget.classId ?? '';
    final attendanceStatsAsync = ref.watch(
      classDetailsAttendanceProvider('student|$studentId|$classId'),
    );
    final parentsAsync = ref.watch(studentParentsProvider(studentId));

    final analysisAsync = ref.watch(
      studentAnalysisProvider('$classId|$studentId|$_selectedFilter'),
    );

    final progressLabel = analysisAsync.when(
      data: (data) {
        final value = data['performanceSummary']?['percentage'];
        return value is num ? '${value.round()}%' : 'N/A';
      },
      loading: () => '...',
      error: (_, _) => 'N/A',
    );

    // Handle avatar
    final avatar = student['avatar'];
    String? avatarUrl;
    if (avatar is Map) {
      avatarUrl = avatar['url'];
    } else if (avatar is String) {
      avatarUrl = avatar;
    }

    // Fix relative URL using ApiConstants
    avatarUrl = ApiConstants.buildImageUrl(avatarUrl);

    // Handle PDF or invalid image formats in Cloudinary
    if (avatarUrl.toLowerCase().endsWith('.pdf')) {
      avatarUrl = null;
    }

    // Fallback image if avatarUrl is empty
    if (avatarUrl == null || avatarUrl.isEmpty) {
      avatarUrl = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Student Profile",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Student Info Block ──
                    Row(
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFF3F4F6),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: avatarUrl != null
                              ? Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF871DAD),
                                  ),
                                )
                              : const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFF871DAD),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student['username'] ??
                                    student['name'] ??
                                    'Unknown Student',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF222222),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Grade ${student['gradeLevel'] ?? student['grade'] ?? student['grade_level'] ?? 'N/A'} - Age ${student['age'] ?? 'N/A'}",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                student['phoneNumber'] ??
                                    student['phone'] ??
                                    '01700000000',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildAction(
                          Icons.chat_bubble_outline,
                          onTap: () => _handleChat(
                            studentId,
                            student['username'] ?? 'Student',
                            avatarUrl,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildAction(
                          Icons.phone_outlined,
                          onTap: () => _handleCall(
                            student['username'] ?? 'Student',
                            avatarUrl ?? '',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Stats Block ──
                    Row(
                      children: [
                        Expanded(
                          child: attendanceStatsAsync.when(
                            data: (percentage) => _buildStatBox(
                              "Attendance",
                              percentage == null
                                  ? "N/A"
                                  : "$percentage%${_getAttendanceEmoji(percentage)}",
                              _getAttendanceColor(percentage ?? 0),
                            ),
                            loading: () => _buildStatBox(
                              "Attendance",
                              "...%",
                              const Color(0xFF4AA678),
                            ),
                            error: (_, __) => _buildStatBox(
                              "Attendance",
                              "N/A",
                              const Color(0xFFC04345),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatBox(
                            "Progress",
                            progressLabel,
                            const Color(0xFFFEBD43),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Parent Profile Block ──
                    const Text(
                      "Parent Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 16),
                    parentsAsync.when(
                      data: (parents) {
                        if (parents.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 28),
                            child: Text(
                              "No parent linked",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        // For now, show the first parent
                        final parentRelation = parents[0];
                        final parentUser = parentRelation['parentId'];
                        if (parentUser == null) return const SizedBox();

                        final parentName = parentUser['username'] ?? 'Parent';
                        final avatarData = parentUser['avatar'];
                        final String? avatarUrl = ApiConstants.buildImageUrl(
                          (avatarData is Map)
                              ? avatarData['url']
                              : (avatarData is String ? avatarData : null),
                        );

                        return Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF871DAD),
                                      width: 1.5,
                                    ),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child:
                                      avatarUrl != null && avatarUrl.isNotEmpty
                                      ? Image.network(
                                          avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.person_outline,
                                                color: Color(0xFF871DAD),
                                              ),
                                        )
                                      : const Icon(
                                          Icons.person_outline,
                                          color: Color(0xFF871DAD),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    parentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Color(0xFF222222),
                                    ),
                                  ),
                                ),
                                _buildAction(
                                  Icons.chat_bubble_outline,
                                  onTap: () => _handleChat(
                                    parentUser['_id'],
                                    parentName,
                                    avatarUrl,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _buildAction(
                                  Icons.phone_outlined,
                                  onTap: () =>
                                      _handleCall(parentName, avatarUrl ?? ''),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                          ],
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text("Error: $err"),
                      ),
                    ),

                    // ── Progress Chart ──
                    const Text(
                      "Progress",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Progress",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF871DAD),
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedFilter,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  style: const TextStyle(
                                    color: Color(0xFF871DAD),
                                    fontSize: 13,
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF871DAD),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'daily',
                                      child: Text('Day'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'weekly',
                                      child: Text('Week'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'monthly',
                                      child: Text('Month'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null)
                                      setState(() => _selectedFilter = value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: analysisAsync.when(
                              data: (data) {
                                final points = data['performanceChartData'];
                                return PerformanceChart(
                                  points: points is List ? points : [],
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (err, _) =>
                                  Center(child: Text("Error: $err")),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── List Items ──
                    TeacherStudentActions(
                      student: student,
                      classId: widget.classId,
                      onMessage: () => _handleChat(
                        studentId,
                        student['username'] ?? 'Student',
                        avatarUrl,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeacherContextFrame.carry(
                              context,
                              BehaviorRecordScreen(
                                studentId: studentId,
                                student: student,
                                classId: widget.classId,
                              ),
                            ),
                          ),
                        );
                      },
                      child: _buildListTile("Behavior Record"),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeacherContextFrame.carry(
                              context,
                              AcademicDocumentsScreen(
                                studentId: studentId,
                                classId: widget.classId,
                              ),
                            ),
                          ),
                        );
                      },
                      child: _buildListTile("Academic Notes"),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeacherContextFrame.carry(
                              context,
                              GradingProgressScreen(
                                studentId: studentId,
                                classId: classId,
                              ),
                            ),
                          ),
                        );
                      },
                      child: _buildListTile("Grading Progress"),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFF871DAD),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Future<void> _handleChat(
    String otherUserId,
    String name,
    String? avatar,
  ) async {
    final user = ref.read(authStateProvider);
    if (user == null) return;

    final chatApi = ChatApiService();
    // Create or get room
    final room = await chatApi.createRoom([otherUserId], user.id);
    if (room != null && mounted) {
      // Register room with notifier to ensure socket join and local list update
      ref.read(chatNotifierProvider.notifier).addRoom(room);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TeacherContextFrame.carry(
            context,
            ChatScreen(session: room, role: ChatRole.teacher),
          ),
        ),
      );
    }
  }

  void _handleCall(String name, String avatar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherContextFrame.carry(
          context,
          CallScreen(name: name, imageUrl: avatar),
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
