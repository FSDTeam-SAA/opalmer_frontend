import 'package:opalmer_education/core/responsive/responsive.dart';
import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:opalmer_education/core/constants/api_constants.dart';
import 'package:opalmer_education/core/services/api_client.dart';
import 'package:opalmer_education/core/services/secure_storage_service.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/parent_role/SubjectsScreen/models/subject.dart';
import 'package:opalmer_education/parent_role/SubjectsScreen/subject_detail_screen.dart';
import 'homework_screen.dart';
import 'attendance_screen.dart';
import 'lessons_screen.dart';
import 'behavior_record_screen.dart';
import 'academic_documents_screen.dart';
import 'grading_progress_screen.dart';

enum ParentStudyFeature {
  subjects('Subjects', Icons.school_outlined),
  homework('Homework & Groups', Icons.assignment_outlined),
  attendance('Attendance', Icons.how_to_reg_outlined),
  lessons('Lessons', Icons.menu_book_outlined),
  behavior('Behavior Records', Icons.star_outline),
  documents('Academic Documents', Icons.folder_open_outlined),
  grades('Grades & Progress', Icons.insights_outlined);

  final String title;
  final IconData icon;
  const ParentStudyFeature(this.title, this.icon);
}

class SubjectsScreen extends StatefulWidget {
  final String initialChildId;
  final String? initialChildName;
  final ParentStudyFeature feature;

  const SubjectsScreen({
    super.key,
    this.initialChildId = '',
    this.initialChildName,
    this.feature = ParentStudyFeature.subjects,
  });

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final ApiClient _api = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  late String _selectedChildId;
  List<ChildProfile> _children = [];
  List<Subject> _subjects = [];
  bool _isLoadingChildren = true;
  bool _isLoadingSubjects = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _selectedChildId = widget.initialChildId;
    _loadChildren();
    if (_selectedChildId.isNotEmpty) _loadSubjects(_selectedChildId);
  }

  Future<void> _loadChildren() async {
    if (mounted) setState(() => _loadError = null);
    try {
      final userData = await _storage.getUserData();
      if (userData == null) throw StateError('Sign in required');
      final parentId =
          (jsonDecode(userData)['id'] ?? jsonDecode(userData)['_id'])
              .toString();

      final response = await _api.get(ApiConstants.childrenByParent(parentId));
      final List relations =
          (response.data is Map && response.data['data'] is Map)
          ? (response.data['data']['children'] as List? ?? const [])
          : const [];

      final children = relations
          .map((rel) {
            final child = rel['childId'];
            if (child is! Map) return null;
            return ChildProfile.fromJson(Map<String, dynamic>.from(child));
          })
          .whereType<ChildProfile>()
          .toList();

      if (!mounted) return;
      setState(() {
        _children = children;
      });
      if (_selectedChildId.isEmpty && children.isNotEmpty) {
        _selectedChildId = children.first.id;
        await _loadSubjects(_selectedChildId);
      } else if (children.isEmpty) {
        setState(() => _isLoadingSubjects = false);
      }
    } catch (e) {
      debugPrint('Failed to load children list: $e');
      if (mounted) {
        setState(
          () => _loadError = 'Unable to load students. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingChildren = false;
          if (_selectedChildId.isEmpty) _isLoadingSubjects = false;
        });
      }
    }
  }

  Future<void> _loadSubjects(String childId) async {
    setState(() {
      _isLoadingSubjects = true;
      _loadError = null;
      _subjects = [];
    });
    try {
      final response = await _api.get(ApiConstants.classesByStudent(childId));
      final classes = (response.data is Map && response.data['data'] is Map)
          ? (response.data['data']['classes'] as List? ?? const [])
          : const [];

      final subjects = classes
          .map((c) => Subject.fromJson(Map<String, dynamic>.from(c as Map)))
          .toList();

      if (!mounted || childId != _selectedChildId) return;
      setState(() {
        _subjects = subjects;
      });
    } catch (e) {
      debugPrint('Failed to load subjects: $e');
      if (mounted && childId == _selectedChildId) {
        setState(() {
          _subjects = [];
          _loadError = 'Unable to load subjects. Please try again.';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load subjects: $e')));
      }
    } finally {
      if (mounted && childId == _selectedChildId) {
        setState(() => _isLoadingSubjects = false);
      }
    }
  }

  void _onSelectChild(String childId) {
    if (childId == _selectedChildId) return;
    setState(() => _selectedChildId = childId);
    _loadSubjects(childId);
  }

  String _selectedChildName() {
    for (final c in _children) {
      if (c.id == _selectedChildId) return c.name;
    }
    return widget.initialChildName ?? '';
  }

  void _openSubjectDetail(Subject subject) {
    final childId = _selectedChildId;
    final childName = _selectedChildName();
    final page = switch (widget.feature) {
      ParentStudyFeature.subjects => SubjectDetailScreen(
        subject: subject,
        studentId: childId,
        studentName: childName,
      ),
      ParentStudyFeature.homework => HomeworkScreen(
        childId: childId,
        classId: subject.id,
        subjectName: subject.name,
      ),
      ParentStudyFeature.attendance => AttendanceScreen(
        subjectName: subject.name,
        classId: subject.id,
        studentId: childId,
        studentName: childName,
      ),
      ParentStudyFeature.lessons => LessonsScreen(
        childId: childId,
        classId: subject.id,
        subjectName: subject.name,
      ),
      ParentStudyFeature.behavior => BehaviorRecordScreen(
        subjectName: subject.name,
        childId: childId,
        childName: childName,
      ),
      ParentStudyFeature.documents => AcademicDocumentsScreen(
        subjectName: subject.name,
        childId: childId,
        childName: childName,
      ),
      ParentStudyFeature.grades => GradingProgressScreen(
        subjectName: subject.name,
        childId: childId,
        classId: subject.id,
      ),
    };
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  ImageProvider? _avatarProvider(String url) {
    if (url.isEmpty) return null;
    return NetworkImage(url);
  }

  Widget _initialFallback(String name) {
    final letter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Text(
      letter,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF666666),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: ResponsiveBody(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: AppPageHeader(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryMid,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.feature.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Child Selector ──
              SizedBox(
                height: 56,
                child: _isLoadingChildren && _children.isEmpty
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _children.length,
                        itemBuilder: (context, index) =>
                            _buildChildChip(_children[index]),
                      ),
              ),

              const SizedBox(height: 12),

              // ── Subjects List ──
              Expanded(
                child: _isLoadingSubjects
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                    ? Center(
                        child: TextButton(
                          onPressed: () => _selectedChildId.isEmpty
                              ? _loadChildren()
                              : _loadSubjects(_selectedChildId),
                          child: Text('$_loadError Retry'),
                        ),
                      )
                    : _subjects.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => _loadSubjects(_selectedChildId),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: _subjects.length,
                          itemBuilder: (context, index) {
                            return _buildSubjectCard(_subjects[index]);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Selectable pill (avatar + name) for each linked child.
  Widget _buildChildChip(ChildProfile child) {
    final isSelected = _selectedChildId == child.id;
    return Semantics(
      label: 'Select ${child.name}',
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => _onSelectChild(child.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryMid : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryMid
                  : AppColors.primaryMid.withValues(alpha: 0.2),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryMid.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: _avatarProvider(child.imageUrl),
                backgroundColor: Colors.grey.shade200,
                child: child.imageUrl.isEmpty
                    ? _initialFallback(child.name)
                    : null,
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  child.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Friendly empty state; pull down or tap Refresh to check again.
  Widget _buildEmptyState() {
    final noChildren = _children.isEmpty;
    final name = _selectedChildName();
    final title = noChildren ? 'No linked students' : 'No subjects yet';
    final message = noChildren
        ? 'Open My Students and link your child with the invitation code from the school.'
        : '${name.isEmpty ? 'Your child' : name} hasn\'t been added to any class yet. '
              'Subjects will appear here once the school assigns classes.';

    return RefreshIndicator(
      onRefresh: () =>
          noChildren ? _loadChildren() : _loadSubjects(_selectedChildId),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.primaryMid.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        noChildren
                            ? Icons.family_restroom_outlined
                            : widget.feature.icon,
                        size: 44,
                        color: AppColors.primaryMid,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => noChildren
                          ? _loadChildren()
                          : _loadSubjects(_selectedChildId),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryMid,
                        side: BorderSide(
                          color: AppColors.primaryMid.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return GestureDetector(
      onTap: () {
        _openSubjectDetail(subject);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            // Upper Part: Subject Info & Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryMid,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monitor_heart,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name
                  Expanded(
                    child: Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  // Stats
                  Row(
                    children: [
                      _buildStat(
                        Icons.calendar_today_rounded,
                        subject.attendance,
                      ),
                      const SizedBox(width: 14),
                      _buildStat(
                        Icons.bar_chart_rounded,
                        subject.performance,
                        color: const Color(0xFFF4B84F),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey.shade100),

            // Lower Part: Teacher Info & View Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: _avatarProvider(subject.teacherAvatar),
                    backgroundColor: Colors.grey.shade200,
                    child: subject.teacherAvatar.isEmpty
                        ? _initialFallback(subject.teacherName)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.teacherName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          subject.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _openSubjectDetail(subject),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryMid,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(80, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "View",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    IconData icon,
    String value, {
    Color color = const Color(0xFF4CB07D),
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
