import 'package:opalmer_education/core/responsive/responsive.dart';
import 'package:opalmer_education/core/widgets/app_home_button.dart';
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
        actions: [const AppHomeButton()],
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
      body: ResponsiveBody(
        child: ref
            .watch(teacherMaterialsProvider(key))
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: TextButton(
                  onPressed: () =>
                      ref.invalidate(teacherMaterialsProvider(key)),
                  child: const Text('Unable to load resources. Retry'),
                ),
              ),
              data: (rows) {
                final filtered = rows
                    .where(
                      (r) =>
                          student == null ||
                          r['studentId'] == null ||
                          r['studentId'].toString() ==
                              student!['_id'].toString(),
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
          onTap: () => openTeachingResource(
            context,
            (item['file']['downloadUrl'] ?? item['file']['url']).toString(),
          ),
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
    appBar: AppBar(
      actions: [const AppHomeButton()],
      title: const Text('Add Resource'),
    ),
    body: ResponsiveBody(
      child: ListView(
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
            decoration: const InputDecoration(
              labelText: 'HTTPS link (optional)',
            ),
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
                                        (id is Map ? id['_id'] : id)
                                            .toString() ==
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
                          : (id) => setState(
                              () => _studentId = id == '' ? null : id,
                            ),
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

/// Compose and send an announcement to one or more classes. Every student in
/// the selected classes, and their linked parents, are notified by the API.
class TeacherAnnouncementsScreen extends ConsumerStatefulWidget {
  /// Class to pre-select, e.g. when opened from a class's own tools.
  final TeacherClassModel? classData;
  const TeacherAnnouncementsScreen({super.key, this.classData});
  @override
  ConsumerState<TeacherAnnouncementsScreen> createState() =>
      _TeacherAnnouncementsScreenState();
}

class _TeacherAnnouncementsScreenState
    extends ConsumerState<TeacherAnnouncementsScreen> {
  final _title = TextEditingController(), _message = TextEditingController();
  bool _students = true, _parents = true, _busy = false;
  String? _error;

  /// Selected class IDs, kept in the order the teacher's classes are listed.
  final Set<String> _selected = {};

  /// Every class the screen knows about, for labels and history.
  final Map<String, TeacherClassModel> _classes = {};

  @override
  void initState() {
    super.initState();
    final initial = widget.classData;
    if (initial != null) {
      _classes[initial.id] = initial;
      _selected.add(initial.id);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  String _label(String classId) {
    final cls = _classes[classId];
    return cls == null ? 'Class' : classLabel(cls);
  }

  List<String> get _selectedInOrder =>
      _classes.keys.where(_selected.contains).toList();

  Future<void> _send() async {
    if (_title.text.trim().isEmpty ||
        _message.text.trim().isEmpty ||
        (!_students && !_parents)) {
      setState(
        () => _error = 'Enter a title, a message and choose an audience.',
      );
      return;
    }
    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one class.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    final targets = _selectedInOrder;
    final sent = <String>[];
    final failed = <String, String>{};
    var deliveryWarning = false;
    String? singleWarning;
    final api = ref.read(apiClientProvider);
    // One announcement per class keeps per-class history and retry intact.
    for (final classId in targets) {
      try {
        final result = await api.post(
          '/teacher-tools/announcements',
          data: {
            'classId': classId,
            'title': _title.text.trim(),
            'message': _message.text.trim(),
            'notifyStudent': _students,
            'notifyParent': _parents,
          },
        );
        sent.add(classId);
        final warning = result.data is Map
            ? result.data['notificationWarning'] as String?
            : null;
        if (warning != null) {
          deliveryWarning = true;
          singleWarning = warning;
        }
      } catch (error) {
        failed[classId] = AttachmentService.errorMessage(error);
      }
    }

    for (final classId in targets) {
      ref.invalidate(teacherAnnouncementsProvider(classId));
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (failed.isEmpty) {
        _title.clear();
        _message.clear();
      } else {
        // Keep the text and only the classes that still need it, so the
        // teacher can simply tap Send again.
        _selected
          ..clear()
          ..addAll(failed.keys);
        _error = sent.isEmpty
            ? failed.values.first
            : 'Sent to ${sent.length} of ${targets.length} classes. '
                  'Not sent to ${failed.keys.map(_label).join(', ')}: '
                  '${failed.values.first} Tap Send to try these again.';
      }
    });
    if (sent.isEmpty) return;
    final String message;
    if (targets.length == 1) {
      message = singleWarning ?? 'Announcement sent.';
    } else if (deliveryWarning) {
      message =
          'Announcement sent to ${sent.length} classes. Some notifications '
          'failed; retry from the history below.';
    } else {
      message = 'Announcement sent to ${sent.length} classes.';
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _retry(Map item) async {
    final id = item['_id'].toString();
    final classId = item['classId']?.toString();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(apiClientProvider)
          .post('/teacher-tools/announcements/$id/retry');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
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
      if (classId != null) {
        ref.invalidate(teacherAnnouncementsProvider(classId));
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _classSelector() {
    final classesAsync = ref.watch(teacherClassesProvider);
    for (final cls in classesAsync.valueOrNull ?? const <TeacherClassModel>[]) {
      _classes[cls.id] = cls;
    }
    final all = _classes.keys.toList();
    final allSelected = all.isNotEmpty && _selected.length == all.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Send to classes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (all.length > 1)
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        if (allSelected) {
                          _selected.clear();
                        } else {
                          _selected.addAll(all);
                        }
                      }),
                child: Text(allSelected ? 'Clear' : 'Select all'),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (classesAsync.isLoading && all.isEmpty)
          const LinearProgressIndicator()
        else if (all.isEmpty)
          classesAsync.hasError
              ? TextButton(
                  onPressed: () => ref.invalidate(teacherClassesProvider),
                  child: const Text('Unable to load classes. Retry'),
                )
              : const Text('You have no classes yet.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in all)
                FilterChip(
                  key: ValueKey('announcement-class-$id'),
                  label: Text(_label(id)),
                  selected: _selected.contains(id),
                  onSelected: _busy
                      ? null
                      : (value) => setState(() {
                          value ? _selected.add(id) : _selected.remove(id);
                          _error = null;
                        }),
                ),
            ],
          ),
        if (_selected.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Will be sent to ${_selected.length} classes.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _history() {
    final ids = _selectedInOrder;
    if (ids.isEmpty) {
      return const ListTile(
        title: Text('Select a class to see its announcement history.'),
      );
    }
    final results = {
      for (final id in ids) id: ref.watch(teacherAnnouncementsProvider(id)),
    };
    final failedIds = [
      for (final entry in results.entries)
        if (entry.value.hasError && !entry.value.isLoading) entry.key,
    ];
    if (failedIds.isNotEmpty) {
      return TextButton(
        onPressed: () {
          for (final id in failedIds) {
            ref.invalidate(teacherAnnouncementsProvider(id));
          }
        },
        child: const Text('Unable to load history. Retry'),
      );
    }
    if (results.values.any((value) => !value.hasValue)) {
      return const LinearProgressIndicator();
    }
    final rows = <Map>[
      for (final entry in results.entries)
        for (final item in entry.value.value!)
          if (item is Map) {...item, 'classId': item['classId'] ?? entry.key},
    ];
    rows.sort(
      (a, b) => '${b['createdAt'] ?? ''}'.compareTo('${a['createdAt'] ?? ''}'),
    );
    if (rows.isEmpty) {
      return const ListTile(title: Text('No announcements yet.'));
    }
    return Column(
      children: [
        for (final item in rows)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ids.length > 1)
                    Text(
                      _label('${item['classId']}'),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
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
                      onPressed: _busy ? null : () => _retry(item),
                      child: const Text('Retry notifications'),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [const AppHomeButton()],
      title: const Text('Announcements'),
    ),
    body: ResponsiveBody(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _classSelector(),
          const SizedBox(height: 12),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          FilledButton.icon(
            onPressed: _busy ? null : _send,
            icon: const Icon(Icons.send_outlined),
            label: Text(_busy ? 'Sending...' : 'Send announcement'),
          ),
          const SizedBox(height: 24),
          Text(
            'Announcement history',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          _history(),
        ],
      ),
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
