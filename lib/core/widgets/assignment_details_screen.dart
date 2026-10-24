import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/download_client.dart';
import '../../teacher_role/navigation/teacher_materials.dart';

class AssignmentDetailsScreen extends ConsumerStatefulWidget {
  final String homeworkId;
  final String? childId;
  final String? studentId;
  const AssignmentDetailsScreen({
    super.key,
    required this.homeworkId,
    this.childId,
    this.studentId,
  });
  @override
  ConsumerState<AssignmentDetailsScreen> createState() =>
      _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState
    extends ConsumerState<AssignmentDetailsScreen> {
  final _api = ApiClient();
  final _response = TextEditingController();
  Map<String, dynamic>? _homework;
  Map<String, dynamic>? _submission;
  List<dynamic> _submissions = [];
  List<dynamic> _missing = [];
  List<PlatformFile> _files = [];
  bool _busy = false;
  String? _error;
  bool get _teacher => ref.read(authStateProvider)?.type == 'teacher';
  bool get _student => ref.read(authStateProvider)?.type == 'student';
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _response.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await _api.get('/homework/${widget.homeworkId}');
      final homework = Map<String, dynamic>.from(response.data['data']);
      Map<String, dynamic>? submission;
      List<dynamic> submissions = [], missing = [];
      if (_teacher) {
        final result = await _api.get(
          '/homework/${widget.homeworkId}/submissions',
        );
        submissions = result.data['data']['submissions'] as List? ?? [];
        missing = result.data['data']['missing'] as List? ?? [];
        if (widget.studentId != null) {
          submissions = submissions
              .where(
                (row) =>
                    (row['studentId'] is Map
                            ? row['studentId']['_id']
                            : row['studentId'])
                        ?.toString() ==
                    widget.studentId,
              )
              .toList();
          missing = missing
              .where((row) => row['_id']?.toString() == widget.studentId)
              .toList();
        }
      } else if (_student || widget.childId != null) {
        final result = await _api.get(
          '/homework/${widget.homeworkId}/submission',
          queryParameters: widget.childId == null
              ? null
              : {'studentId': widget.childId},
        );
        if (result.data['data'] is Map) {
          submission = Map<String, dynamic>.from(result.data['data']);
        }
      }
      if (!mounted) return;
      setState(() {
        _homework = homework;
        _submission = submission;
        _submissions = submissions;
        _missing = missing;
        _response.text = submission?['response']?.toString() ?? '';
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Unable to load this assignment. Please try again.',
        );
      }
    }
  }

  Future<void> _save(bool submit) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final form = FormData.fromMap({
        'response': _response.text,
        'submit': submit,
      });
      for (final file in _files) {
        if (file.bytes != null) {
          form.files.add(
            MapEntry(
              'files',
              MultipartFile.fromBytes(file.bytes!, filename: file.name),
            ),
          );
        }
      }
      await _api.post('/homework/${widget.homeworkId}/submission', data: form);
      _files = [];
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(submit ? 'Assignment submitted' : 'Draft saved'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Unable to save. Your response is still here; please retry.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openFile(String url, String name) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isScheme('https')) return;
    if (name.toLowerCase().endsWith('.pdf') ||
        Uri.parse(url).path.toLowerCase().endsWith('.pdf')) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(name)),
            body: PdfPreview(
              build: (_) async {
                final response = await dioForDownloadUrl(url).get<List<int>>(
                  url,
                  options: Options(responseType: ResponseType.bytes),
                );
                return Uint8List.fromList(response.data ?? []);
              },
              allowPrinting: false,
              allowSharing: false,
            ),
          ),
        ),
      );
    } else {
      await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
    }
  }

  Future<void> _review(Map item) async {
    final score = TextEditingController(text: '${item['score'] ?? ''}');
    final feedback = TextEditingController(
      text: item['feedback']?.toString() ?? '',
    );
    final release = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text('Review ${item['studentId']?['username'] ?? 'submission'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item['response']?.toString() ?? ''),
              ...((item['files'] as List?) ?? []).map(
                (file) => TextButton(
                  onPressed: () => _openFile(
                    '${file['url']}',
                    '${file['filename'] ?? 'Attachment'}',
                  ),
                  child: Text('${file['filename'] ?? 'Attachment'}'),
                ),
              ),
              TextField(
                controller: score,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      'Points out of ${_homework?['pointsPossible'] ?? 100}',
                ),
              ),
              TextField(
                controller: feedback,
                decoration: const InputDecoration(labelText: 'Feedback'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Save review'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Publish grade'),
          ),
        ],
      ),
    );
    if (release != null) {
      try {
        await _api.dio.patch(
          '/homework/${widget.homeworkId}/submissions/${item['_id']}/review',
          data: {
            'score': double.tryParse(score.text),
            'feedback': feedback.text,
            'release': release,
          },
        );
        await _load();
      } catch (_) {
        if (mounted) {
          setState(
            () => _error =
                'Review could not be saved. Check the points and retry.',
          );
        }
      }
    }
    score.dispose();
    feedback.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homework = _homework;
    final editable =
        _student && (_submission == null || _submission?['status'] == 'draft');
    return Scaffold(
      appBar: AppBar(title: const Text('Assignment')),
      body: homework == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  '${homework['title']}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text('${homework['description'] ?? ''}'),
                if (homework['dueDate'] != null)
                  Text(
                    'Due: ${DateTime.tryParse(homework['dueDate'])?.toLocal()}',
                  ),
                Text('Points possible: ${homework['pointsPossible'] ?? 100}'),
                HomeworkHelpPanel(
                  homeworkId: widget.homeworkId,
                  studentId: widget.childId,
                ),
                const SizedBox(height: 16),
                ...((homework['file'] as List?) ?? []).map(
                  (file) => ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: Text(
                      '${file['filename'] ?? 'Homework help / attachment'}',
                    ),
                    onTap: () => _openFile(
                      '${file['url']}',
                      '${file['filename'] ?? 'Attachment'}',
                    ),
                  ),
                ),
                if (!_teacher) ...[
                  Text('Status: ${_submission?['status'] ?? 'Not started'}'),
                  if (_submission?['status'] == 'released')
                    Text(
                      'Grade: ${_submission?['score']} / ${homework['pointsPossible'] ?? 100}\n${_submission?['feedback'] ?? ''}',
                    ),
                  TextField(
                    controller: _response,
                    readOnly: !editable,
                    maxLines: 8,
                    decoration: const InputDecoration(labelText: 'Response'),
                  ),
                  ...((_submission?['files'] as List?) ?? []).map(
                    (file) => TextButton(
                      onPressed: () => _openFile(
                        '${file['url']}',
                        '${file['filename'] ?? 'Attachment'}',
                      ),
                      child: Text('${file['filename'] ?? 'Attachment'}'),
                    ),
                  ),
                  if (editable) ...[
                    TextButton.icon(
                      onPressed: _busy
                          ? null
                          : () async {
                              final files = await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                                withData: true,
                              );
                              if (mounted && files != null) {
                                setState(() => _files = files.files);
                              }
                            },
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                        _files.isEmpty
                            ? 'Attach files'
                            : '${_files.length} file(s) selected',
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : () => _save(false),
                      child: const Text('Save draft'),
                    ),
                    FilledButton(
                      onPressed: _busy ? null : () => _save(true),
                      child: const Text('Submit assignment'),
                    ),
                  ],
                ],
                if (_teacher) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Submissions (${_submissions.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ..._submissions.map(
                    (item) => ListTile(
                      title: Text(
                        '${item['studentId']?['username']} · ${item['studentId']?['Id']}',
                      ),
                      subtitle: Text('${item['status']}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: item['status'] == 'draft'
                          ? null
                          : () => _review(item),
                    ),
                  ),
                  Text('Not submitted (${_missing.length})'),
                  ..._missing.map(
                    (student) => ListTile(
                      title: Text('${student['username']} · ${student['Id']}'),
                    ),
                  ),
                ],
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ),
    );
  }
}
