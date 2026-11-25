import 'package:opalmer_education/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/teacher_provider.dart';
import '../../core/widgets/app_home_button.dart';
import '../../chat/models/chat_role.dart';
import '../../chat/models/chat_session_model.dart';
import '../../chat/screens/chat_screen.dart';
import 'student_profile.dart';
import 'widgets/teacher_assignment_list.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> roomData;
  final String classId;
  const GroupDetailScreen({
    super.key,
    required this.roomData,
    required this.classId,
  });
  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  late Map<String, dynamic> _room;
  bool _busy = false;
  String _id(dynamic user) =>
      (user is Map ? user['_id'] : user)?.toString() ?? '';
  List get _participants => _room['participants'] as List? ?? [];
  bool get _canManage =>
      _id(_room['createdBy']) == ref.read(authStateProvider)?.id;

  @override
  void initState() {
    super.initState();
    _room = Map<String, dynamic>.from(widget.roomData);
  }

  Future<void> _update(Map<String, dynamic> data) async {
    setState(() => _busy = true);
    try {
      final response = await ref
          .read(apiClientProvider)
          .patch('/rooms/${_room['_id']}', data: data);
      if (!mounted) return;
      setState(() => _room = Map<String, dynamic>.from(response.data['data']));
      ref.invalidate(userRoomsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update group. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rename() async {
    var editedName = _room['name']?.toString() ?? '';
    final name = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Rename group'),
        content: TextFormField(
          initialValue: editedName,
          onChanged: (value) => editedName = value,
          autofocus: true,
          maxLength: 100,
          decoration: const InputDecoration(labelText: 'Group name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (editedName.trim().isNotEmpty) {
                Navigator.pop(dialog, editedName.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null && mounted) await _update({'name': name});
  }

  Future<void> _remove(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text('Remove $name from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _update({
        'participants': _participants
            .map((p) => _id(p['userId']))
            .where((value) => value != id)
            .toList(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(classStudentsProvider(widget.classId));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _room['name']?.toString() ?? 'Group',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_canManage)
            IconButton(
              tooltip: 'Rename group',
              onPressed: _busy ? null : _rename,
              icon: const Icon(Icons.edit_outlined),
            ),
          const AppHomeButton(),
        ],
      ),
      body: ResponsiveBody(
        child: Column(
          children: [
            if (_busy) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Open group chat'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      session: ChatSessionModel.fromJson(_room),
                      role: ChatRole.teacher,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'Members (${_participants.length})'),
                        const Tab(text: 'Class assignments'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          students.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (_, _) => Center(
                              child: TextButton(
                                onPressed: () => ref.invalidate(
                                  classStudentsProvider(widget.classId),
                                ),
                                child: const Text('Retry loading members'),
                              ),
                            ),
                            data: (roster) {
                              final byId = {
                                for (final row in roster)
                                  if (row['studentId'] is Map)
                                    _id(row['studentId']): row['studentId'],
                              };
                              return ListView(
                                children: _participants.map<Widget>((
                                  participant,
                                ) {
                                  final user = participant['userId'];
                                  final id = _id(user);
                                  final person =
                                      byId[id] ?? (user is Map ? user : null);
                                  final name =
                                      person?['username']?.toString() ??
                                      'Group member';
                                  final isStudent = byId.containsKey(id);
                                  return ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.person_outline),
                                    ),
                                    title: Text(name),
                                    subtitle: Text(
                                      isStudent ? 'Student' : 'Member',
                                    ),
                                    onTap: isStudent
                                        ? () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  StudentProfileScreen(
                                                    studentData:
                                                        Map<
                                                          String,
                                                          dynamic
                                                        >.from(person),
                                                    classId: widget.classId,
                                                  ),
                                            ),
                                          )
                                        : null,
                                    trailing:
                                        _canManage &&
                                            isStudent &&
                                            _participants.length > 2
                                        ? IconButton(
                                            tooltip: 'Remove $name',
                                            onPressed: _busy
                                                ? null
                                                : () => _remove(id, name),
                                            icon: const Icon(
                                              Icons.person_remove_outlined,
                                            ),
                                          )
                                        : null,
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          TeacherAssignmentList(classId: widget.classId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
