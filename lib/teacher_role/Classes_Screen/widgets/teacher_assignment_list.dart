import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/teacher_provider.dart';
import '../../../core/services/attachment_service.dart';
import '../../../core/widgets/assignment_details_screen.dart';
import '../../navigation/teacher_workspace.dart';
import '../add_homework_screen.dart';

class TeacherAssignmentList extends ConsumerStatefulWidget {
  final String classId;
  const TeacherAssignmentList({super.key, required this.classId});
  @override
  ConsumerState<TeacherAssignmentList> createState() =>
      _TeacherAssignmentListState();
}

class _TeacherAssignmentListState extends ConsumerState<TeacherAssignmentList> {
  bool _archived = false;
  final Set<String> _busy = {};

  Future<void> _edit([Map<String, dynamic>? homework]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherContextFrame.carry(
          context,
          AddHomeworkScreen(classId: widget.classId, homework: homework),
        ),
      ),
    );
    if (mounted) ref.invalidate(classHomeworkProvider(widget.classId));
  }

  Future<void> _change(
    Map<String, dynamic> homework, {
    bool delete = false,
  }) async {
    final id = homework['_id'].toString();
    if (_busy.contains(id)) return;
    if (delete) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: const Text('Delete assignment?'),
          content: Text(
            'Delete "${homework['title']}"? This cannot be undone.',
          ),
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
        await api.delete('/homework/delete/$id');
      } else {
        await api.patch(
          '/homework/archive/$id',
          data: {'archived': !_archived},
        );
      }
      ref.invalidate(classHomeworkProvider(widget.classId));
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AttachmentService.errorMessage(error))),
        );
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final homework = ref.watch(classHomeworkProvider(widget.classId));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FilledButton.icon(
          onPressed: () => _edit(),
          icon: const Icon(Icons.add),
          label: const Text('Add assignment'),
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
        homework.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => TextButton(
            onPressed: () =>
                ref.invalidate(classHomeworkProvider(widget.classId)),
            child: const Text('Unable to load assignments. Retry'),
          ),
          data: (items) {
            final visible = items
                .where((item) => (item['archived'] == true) == _archived)
                .toList();
            if (visible.isEmpty)
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _archived
                      ? 'No archived assignments.'
                      : 'No active assignments.',
                ),
              );
            return Column(
              children: visible.map((item) {
                final hw = Map<String, dynamic>.from(item as Map);
                final busy = _busy.contains(hw['_id'].toString());
                final due = DateTime.tryParse(
                  hw['dueDate']?.toString() ?? '',
                )?.toLocal();
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(hw['title']?.toString() ?? 'Assignment'),
                          subtitle: Text(hw['description']?.toString() ?? ''),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeacherContextFrame.carry(
                                context,
                                AssignmentDetailsScreen(
                                  homeworkId: hw['_id'].toString(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${hw['status'] == 'draft' ? 'Draft' : 'Published'} · ${hw['pointsPossible'] ?? 100} points${due == null ? '' : ' · Due ${due.toString().split(' ').first}'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const Divider(),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: busy ? null : () => _edit(hw),
                              child: const Text('Edit'),
                            ),
                            TextButton(
                              onPressed: busy ? null : () => _change(hw),
                              child: Text(_archived ? 'Restore' : 'Archive'),
                            ),
                            TextButton(
                              onPressed: busy
                                  ? null
                                  : () => _change(hw, delete: true),
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
