import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/teacher_class_model.dart';
import '../../core/providers/teacher_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/attachment_service.dart';
import 'teacher_workspace.dart';

final teacherMaterialsProvider = FutureProvider.autoDispose
    .family<List<dynamic>, String>((ref, key) async {
      final parts = key.split('|');
      ref.watch(authStateProvider);
      final response = await ref
          .read(apiClientProvider)
          .get(
            parts.length > 1
                ? '/teacher-tools/homework/${parts[1]}/help'
                : '/teacher-tools/resources',
            queryParameters: parts.length > 1 ? null : {'classId': parts[0]},
          );
      return response.data['data'] as List;
    });

Future<void> openTeachingResource(BuildContext context, String raw) async {
  final uri = Uri.tryParse(raw);
  try {
    if (uri == null ||
        !['https', 'http'].contains(uri.scheme) ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('link');
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open this resource. Please retry.'),
        ),
      );
    }
  }
}

class TeacherMaterialsScreen extends ConsumerWidget {
  final TeacherClassModel classData;
  final Map<String, dynamic>? homework;
  final Map<String, dynamic>? student;
  const TeacherMaterialsScreen({
    super.key,
    required this.classData,
    this.homework,
    this.student,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key =
        '${classData.id}${homework == null ? '' : '|${homework!['_id']}'}';
    return Scaffold(
      appBar: AppBar(
        title: Text(homework == null ? 'Resources' : 'Homework Help'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add resource'),
        onPressed: () async {
          final warning = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherContextFrame.carry(
                context,
                AddTeachingResource(
                  classData: classData,
                  homework: homework,
                  student: student,
                ),
              ),
            ),
          );
          ref.invalidate(teacherMaterialsProvider(key));
          if (warning != null && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(warning)));
          }
        },
      ),
      body: ref
          .watch(teacherMaterialsProvider(key))
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(teacherMaterialsProvider(key)),
                child: const Text('Unable to load resources. Retry'),
              ),
            ),
            data: (rows) {
              final filtered = rows
                  .where(
                    (r) =>
                        student == null ||
                        r['studentId'] == null ||
                        r['studentId'].toString() == student!['_id'].toString(),
                  )
                  .toList();
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  if (homework != null)
                    Text(
                      '${homework!['title']}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  if (student != null)
                    Text(
                      '${student!['username']} · ${student!['Id'] ?? 'ID unavailable'}',
                    ),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No resources yet. Add a file or link to get started.',
                      ),
                    ),
                  ...filtered.map((item) => resourceTile(context, item)),
                ],
              );
            },
          ),
    );
  }
}

Widget resourceTile(BuildContext context, dynamic item) => Card(
  child: Column(
    children: [
      ListTile(
        leading: Icon(
          item['file']?['url'] != null ? Icons.attach_file : Icons.link,
        ),
        title: Text('${item['title']}'),
        subtitle: Text(
          item['studentId'] == null
              ? 'Class resource'
              : 'Student-specific help',
        ),
      ),
      if (item['file']?['url'] != null)
        ListTile(
          dense: true,
          title: Text('${item['file']['filename'] ?? 'Open file'}'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () =>
              openTeachingResource(context, item['file']['url'].toString()),
        ),
      if ((item['link'] as String? ?? '').isNotEmpty)
        ListTile(
          dense: true,
          title: Text('${item['link']}'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => openTeachingResource(context, item['link'].toString()),
        ),
    ],
  ),
);

class AddTeachingResource extends ConsumerStatefulWidget {
  final TeacherClassModel classData;
  final Map<String, dynamic>? homework;
  final Map<String, dynamic>? student;
  const AddTeachingResource({
    super.key,
    required this.classData,
    this.homework,
    this.student,
  });
  @override
  ConsumerState<AddTeachingResource> createState() =>
      _AddTeachingResourceState();
}

class _AddTeachingResourceState extends ConsumerState<AddTeachingResource> {
  final _title = TextEditingController(), _link = TextEditingController();
  PlatformFile? _file;
  String? _studentId;
  bool _notifyStudent = true, _notifyParent = true, _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _studentId = widget.student?['_id']?.toString();
  }

  @override
  void dispose() {
    _title.dispose();
    _link.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: widget.homework == null
            ? AttachmentService.resourceExtensions
            : ['pdf', 'mp4', 'webm', 'mov'],
      );
      if (!mounted || result == null) return;
      final file = result.files.single;
      final error = AttachmentService.validate(file);
      setState(() {
        _error = error;
        if (error == null) _file = file;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = AttachmentService.errorMessage(error));
      }
    }
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty ||
        (_file == null && _link.text.trim().isEmpty)) {
      setState(
        () => _error =
            'Enter a title and choose a file or enter a resource link.',
      );
      return;
    }
    if (_link.text.trim().isNotEmpty) {
      final uri = Uri.tryParse(_link.text.trim());
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty) {
        setState(() => _error = 'Enter a valid HTTPS link.');
        return;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final data = FormData.fromMap({
        'classId': widget.classData.id,
        'title': _title.text.trim(),
        if (_link.text.trim().isNotEmpty) 'link': _link.text.trim(),
        if (widget.homework != null) 'homeworkId': widget.homework!['_id'],
        if (_studentId != null) 'studentId': _studentId,
        'notifyStudent': _notifyStudent,
        'notifyParent': _notifyParent,
      });
      if (_file != null) {
        data.files.add(
          MapEntry('file', await AttachmentService.multipart(_file!)),
        );
      }
      final result = await ref
          .read(apiClientProvider)
          .post(
            '/teacher-tools/resources',
            data: data,
            options: AttachmentService.uploadOptions,
          );
      if (mounted) {
        Navigator.pop(
          context,
          result.data['notificationWarning'] as String? ?? 'Resource saved.',
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = AttachmentService.errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add Resource')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Grade ${widget.classData.grade} · ${widget.classData.subject}'),
        if (widget.homework != null)
          Text('Assignment: ${widget.homework!['title']}'),
        TextField(
          controller: _title,
          maxLength: 200,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: 'Resource title'),
        ),
        TextField(
          controller: _link,
          enabled: !_busy,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(labelText: 'HTTPS link (optional)'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _busy ? null : _pick,
          icon: const Icon(Icons.attach_file),
          label: Text(
            _file?.name ??
                (widget.homework == null
                    ? 'Choose file (up to 100 MB)'
                    : 'Choose PDF or video (up to 100 MB)'),
          ),
        ),
        if (_file != null)
          TextButton(
            onPressed: _busy ? null : () => setState(() => _file = null),
            child: const Text('Remove file'),
          ),
        if (widget.homework != null) ...[
          if (widget.student != null)
            ListTile(
              title: Text('${widget.student!['username']}'),
              subtitle: Text('${widget.student!['Id'] ?? 'ID unavailable'}'),
            )
          else
            ref
                .watch(classStudentsProvider(widget.classData.id))
                .when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => TextButton(
                    onPressed: () => ref.invalidate(
                      classStudentsProvider(widget.classData.id),
                    ),
                    child: const Text('Retry students'),
                  ),
                  data: (rows) => DropdownButtonFormField<String>(
                    initialValue: _studentId ?? '',
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Help audience',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Everyone assigned this homework'),
                      ),
                      ...rows
                          .where((row) {
                            final targets =
                                widget.homework!['studentIds'] as List? ?? [];
                            return targets.isEmpty ||
                                targets.any(
                                  (id) =>
                                      (id is Map ? id['_id'] : id).toString() ==
                                      row['studentId']['_id'].toString(),
                                );
                          })
                          .map(
                            (row) => DropdownMenuItem(
                              value: row['studentId']['_id'].toString(),
                              child: Text(
                                '${row['studentId']['username']} · ${row['studentId']['Id'] ?? ''}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                    ],
                    onChanged: _busy
                        ? null
                        : (id) =>
                              setState(() => _studentId = id == '' ? null : id),
                  ),
                ),
          CheckboxListTile(
            title: const Text('Notify student'),
            value: _notifyStudent,
            onChanged: _busy
                ? null
                : (value) => setState(() => _notifyStudent = value ?? false),
          ),
          CheckboxListTile(
            title: const Text('Notify parent'),
            value: _notifyParent,
            onChanged: _busy
                ? null
                : (value) => setState(() => _notifyParent = value ?? false),
          ),
        ],
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(_busy ? 'Saving...' : 'Save resource'),
        ),
      ],
    ),
  );
}

final teacherAnnouncementsProvider = FutureProvider.autoDispose
    .family<List<dynamic>, String>((ref, classId) async {
      ref.watch(authStateProvider);
      final result = await ref
          .read(apiClientProvider)
          .get(
            '/teacher-tools/announcements',
            queryParameters: {'classId': classId},
          );
      return result.data['data'] as List;
    });

class TeacherAnnouncementsScreen extends ConsumerStatefulWidget {
  final TeacherClassModel classData;
  const TeacherAnnouncementsScreen({super.key, required this.classData});
  @override
  ConsumerState<TeacherAnnouncementsScreen> createState() =>
      _TeacherAnnouncementsScreenState();
}

class _TeacherAnnouncementsScreenState
    extends ConsumerState<TeacherAnnouncementsScreen> {
  final _title = TextEditingController(), _message = TextEditingController();
  bool _students = true, _parents = true, _busy = false;
  String? _error;
  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send({String? retryId}) async {
    if (retryId == null &&
        (_title.text.trim().isEmpty ||
            _message.text.trim().isEmpty ||
            (!_students && !_parents))) {
      setState(
        () => _error = 'Enter a title, a message and choose an audience.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(apiClientProvider)
          .post(
            retryId == null
                ? '/teacher-tools/announcements'
                : '/teacher-tools/announcements/$retryId/retry',
            data: retryId == null
                ? {
                    'classId': widget.classData.id,
                    'title': _title.text.trim(),
                    'message': _message.text.trim(),
                    'notifyStudent': _students,
                    'notifyParent': _parents,
                  }
                : null,
          );
      if (!mounted) return;
      if (retryId == null) {
        _title.clear();
        _message.clear();
      }
      ref.invalidate(teacherAnnouncementsProvider(widget.classData.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.data['notificationWarning'] as String? ??
                'Announcement sent.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = AttachmentService.errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Announcements')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Grade ${widget.classData.grade} · ${widget.classData.subject}'),
        TextField(
          controller: _title,
          maxLength: 200,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        TextField(
          controller: _message,
          maxLines: 4,
          maxLength: 10000,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: 'Message'),
        ),
        CheckboxListTile(
          title: const Text('Send to students'),
          value: _students,
          onChanged: _busy
              ? null
              : (value) => setState(() => _students = value ?? false),
        ),
        CheckboxListTile(
          title: const Text('Send to parents'),
          value: _parents,
          onChanged: _busy
              ? null
              : (value) => setState(() => _parents = value ?? false),
        ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        FilledButton.icon(
          onPressed: _busy ? null : () => _send(),
          icon: const Icon(Icons.send_outlined),
          label: Text(_busy ? 'Sending...' : 'Send announcement'),
        ),
        const SizedBox(height: 24),
        Text(
          'Announcement history',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ref
            .watch(teacherAnnouncementsProvider(widget.classData.id))
            .when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => TextButton(
                onPressed: () => ref.invalidate(
                  teacherAnnouncementsProvider(widget.classData.id),
                ),
                child: const Text('Unable to load history. Retry'),
              ),
              data: (rows) => Column(
                children: [
                  if (rows.isEmpty)
                    const ListTile(title: Text('No announcements yet.')),
                  ...rows.map(
                    (item) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['title']}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text('${item['message']}'),
                            Text(
                              '${item['deliveryStatus']} · ${item['notifyStudent'] == true ? 'Students ' : ''}${item['notifyParent'] == true ? 'Parents' : ''}',
                            ),
                            if (item['deliveryStatus'] != 'sent')
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : () => _send(
                                        retryId: item['_id'].toString(),
                                      ),
                                child: const Text('Retry notifications'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    ),
  );
}

/// Shared recipient view. Authorization and student targeting are enforced by API.
class HomeworkHelpPanel extends ConsumerWidget {
  final String homeworkId;
  final String? studentId;
  const HomeworkHelpPanel({
    super.key,
    required this.homeworkId,
    this.studentId,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = '$homeworkId|${studentId ?? ''}';
    return ref
        .watch(homeworkHelpRecipientProvider(key))
        .when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => TextButton(
            onPressed: () => ref.invalidate(homeworkHelpRecipientProvider(key)),
            child: const Text('Unable to load homework help. Retry'),
          ),
          data: (rows) => rows.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Homework Help',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ...rows.map((item) => resourceTile(context, item)),
                  ],
                ),
        );
  }
}

final homeworkHelpRecipientProvider = FutureProvider.autoDispose
    .family<List<dynamic>, String>((ref, key) async {
      ref.watch(authStateProvider);
      final parts = key.split('|');
      final result = await ref
          .read(apiClientProvider)
          .get(
            '/teacher-tools/homework/${parts[0]}/help',
            queryParameters: parts.length > 1 && parts[1].isNotEmpty
                ? {'studentId': parts[1]}
                : null,
          );
      return result.data['data'] as List;
    });
