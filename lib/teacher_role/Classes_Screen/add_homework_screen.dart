import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/teacher_provider.dart';
import '../../core/services/attachment_service.dart';

class AddHomeworkScreen extends ConsumerStatefulWidget {
  final String classId;
  const AddHomeworkScreen({super.key, required this.classId});
  @override
  ConsumerState<AddHomeworkScreen> createState() => _AddHomeworkScreenState();
}

class _AddHomeworkScreenState extends ConsumerState<AddHomeworkScreen> {
  final _title = TextEditingController();
  final _instructions = TextEditingController();
  final _points = TextEditingController(text: '100');
  DateTime? _due;
  List<PlatformFile> _files = [];
  bool _notifyStudent = true,
      _notifyParent = true,
      _draft = false,
      _busy = false;
  String? _error;
  @override
  void dispose() {
    _title.dispose();
    _instructions.dispose();
    _points.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final points = double.tryParse(_points.text);
    if (_title.text.trim().isEmpty || points == null || points <= 0) {
      setState(() => _error = 'Enter a title and valid points possible.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = ref.read(authStateProvider);
      if (user == null) throw StateError('Sign in required');
      final data = FormData.fromMap({
        'classId': widget.classId,
        'userId': user.id,
        'title': _title.text.trim(),
        'description': _instructions.text.trim(),
        'pointsPossible': points,
        'status': _draft ? 'draft' : 'published',
        'notifyStudent': _notifyStudent,
        'notifyParent': _notifyParent,
        if (_due != null) 'dueDate': _due!.toUtc().toIso8601String(),
      });
      for (final file in _files) {
        data.files.add(
          MapEntry('file', await AttachmentService.multipart(file)),
        );
      }
      await ref
          .read(apiClientProvider)
          .post(
            '/homework/create',
            data: data,
            options: AttachmentService.uploadOptions,
          );
      ref.invalidate(classHomeworkProvider(widget.classId));
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted)
        setState(() => _error = AttachmentService.errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [const AppHomeButton()],
      title: const Text('Create assignment'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Assignment title'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _instructions,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Instructions'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _points,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Points possible'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            _due == null
                ? 'Choose due date'
                : 'Due: ${_due!.toLocal().toString().split(' ')[0]}',
          ),
          trailing: const Icon(Icons.calendar_month),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 730)),
              initialDate: _due ?? DateTime.now(),
            );
            if (mounted && date != null)
              setState(
                () => _due = DateTime(date.year, date.month, date.day, 23, 59),
              );
          },
        ),
        TextButton.icon(
          icon: const Icon(Icons.attach_file),
          label: Text(
            _files.isEmpty
                ? 'Add PDF, video or other resources'
                : '${_files.length} attachment(s)',
          ),
          onPressed: _busy
              ? null
              : () async {
                  final selected = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    withData: true,
                    type: FileType.custom,
                    allowedExtensions: [
                      'pdf',
                      'mp4',
                      'webm',
                      'mov',
                      'png',
                      'jpg',
                      'jpeg',
                      'doc',
                      'docx',
                      'ppt',
                      'pptx',
                    ],
                  );
                  if (mounted && selected != null) {
                    for (final file in selected.files) {
                      final error = AttachmentService.validate(file);
                      if (error != null) {
                        setState(() => _error = error);
                        return;
                      }
                    }
                    setState(() {
                      _files = selected.files;
                      _error = null;
                    });
                  }
                },
        ),
        ..._files.map(
          (file) => ListTile(
            title: Text(file.name),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _files.remove(file)),
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Save as draft'),
          value: _draft,
          onChanged: (value) => setState(() => _draft = value),
        ),
        CheckboxListTile(
          title: const Text('Notify student'),
          value: _notifyStudent,
          onChanged: (value) => setState(() => _notifyStudent = value ?? true),
        ),
        CheckboxListTile(
          title: const Text('Notify parent'),
          value: _notifyParent,
          onChanged: (value) => setState(() => _notifyParent = value ?? true),
        ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(
            _busy
                ? 'Saving...'
                : _draft
                ? 'Save draft'
                : 'Publish assignment',
          ),
        ),
      ],
    ),
  );
}
