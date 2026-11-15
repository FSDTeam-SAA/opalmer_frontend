import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/teacher_provider.dart';
import '../../../core/services/attachment_service.dart';
import '../../navigation/teacher_workspace.dart';
import '../create_lesson_screen.dart';
import '../lesson_overview_screen.dart';

class TeacherLessonList extends ConsumerStatefulWidget {
  final String classId;
  const TeacherLessonList({super.key, required this.classId});
  @override
  ConsumerState<TeacherLessonList> createState() => _TeacherLessonListState();
}

class _TeacherLessonListState extends ConsumerState<TeacherLessonList> {
  bool _archived = false;
  final _busy = <String>{};
  Future<void> _edit([Map<String, dynamic>? lesson]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherContextFrame.carry(
          context,
          CreateLessonScreen(classId: widget.classId, lesson: lesson),
        ),
      ),
    );
    if (mounted) ref.invalidate(classLessonsProvider(widget.classId));
  }

  Future<void> _change(
    Map<String, dynamic> lesson, {
    bool delete = false,
  }) async {
    final id = lesson['_id'].toString();
    if (_busy.contains(id)) return;
    if (delete) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: const Text('Delete lesson?'),
          content: Text('Delete "${lesson['title']}"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() => _busy.add(id));
    try {
      final api = ref.read(apiClientProvider);
      if (delete) {
        await api.delete('/lessons/delete/$id');
      } else {
        await api.put('/lessons/update-status/$id');
      }
      ref.invalidate(classLessonsProvider(widget.classId));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AttachmentService.errorMessage(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessons = ref.watch(classLessonsProvider(widget.classId));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FilledButton.icon(
          onPressed: () => _edit(),
          icon: const Icon(Icons.add),
          label: const Text('Add lesson'),
        ),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Active')),
            ButtonSegment(value: true, label: Text('Archived')),
          ],
          selected: {_archived},
          onSelectionChanged: (value) =>
              setState(() => _archived = value.first),
        ),
        const SizedBox(height: 16),
        lessons.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => TextButton(
            onPressed: () =>
                ref.invalidate(classLessonsProvider(widget.classId)),
            child: const Text('Unable to load lessons. Retry'),
          ),
          data: (items) {
            final visible = items
                .where((item) => (item['isArchived'] == true) == _archived)
                .toList();
            if (visible.isEmpty)
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _archived ? 'No archived lessons.' : 'No active lessons.',
                ),
              );
            return Column(
              children: visible.map((item) {
                final lesson = Map<String, dynamic>.from(item as Map);
                final busy = _busy.contains(lesson['_id'].toString());
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson['title']?.toString() ?? 'Lesson',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(lesson['objective']?.toString() ?? ''),
                        const SizedBox(height: 8),
                        Text(
                          lesson['note']?.toString() ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TeacherContextFrame.carry(
                                    context,
                                    LessonOverviewScreen(lesson: lesson),
                                  ),
                                ),
                              ),
                              child: const Text('View'),
                            ),
                            TextButton(
                              onPressed: busy ? null : () => _edit(lesson),
                              child: const Text('Edit'),
                            ),
                            TextButton(
                              onPressed: busy ? null : () => _change(lesson),
                              child: Text(_archived ? 'Restore' : 'Archive'),
                            ),
                            TextButton(
                              onPressed: busy
                                  ? null
                                  : () => _change(lesson, delete: true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
