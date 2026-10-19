import 'package:flutter/material.dart';
import 'package:opalmer_education/core/services/api_client.dart';

class StudentDetailScreen extends StatefulWidget {
  final String resultId;
  const StudentDetailScreen({super.key, required this.resultId});
  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _api = ApiClient();
  final _score = TextEditingController();
  final _feedback = TextEditingController();
  final _reason = TextEditingController();
  Map<String, dynamic>? _result;
  String? _error;
  bool _busy = false;
  bool _notifyStudent = true;
  bool _notifyParent = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _score.dispose();
    _feedback.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await _api.get('/grading/results/${widget.resultId}');
      final result = Map<String, dynamic>.from(response.data['data']['result']);
      if (!mounted) return;
      setState(() {
        _result = result;
        _error = null;
        _score.text = '${result['score'] ?? 0}';
        _feedback.text = result['feedback']?.toString() ?? '';
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to load this submission.');
    }
  }

  Future<void> _save(bool release) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (release) {
        await _api.post(
          '/grading/results/${widget.resultId}/release',
          data: {
            'notifyStudent': _notifyStudent,
            'notifyParent': _notifyParent,
          },
        );
      } else {
        await _api.dio.patch(
          '/grading/results/${widget.resultId}/review',
          data: {
            'score': double.tryParse(_score.text),
            'feedback': _feedback.text,
            'reason': _reason.text,
          },
        );
      }
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(release ? 'Grade published' : 'Review saved')),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error =
              'Unable to save. Check the score and enter a reason for an override.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Review submission')),
      body: result == null
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
                  '${result['studentId']?['username'] ?? 'Student'} · ${result['studentId']?['Id'] ?? ''}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('Status: ${result['gradeStatus'] ?? 'pending_review'}'),
                const SizedBox(height: 16),
                TextField(
                  controller: _score,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        'Points out of ${result['progress']?['totalQuestions'] ?? 0}',
                  ),
                ),
                TextField(
                  controller: _reason,
                  decoration: const InputDecoration(
                    labelText: 'Reason for overriding the score',
                  ),
                ),
                TextField(
                  controller: _feedback,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Feedback for student and parent',
                  ),
                ),
                const SizedBox(height: 16),
                ...((result['answers'] as List?) ?? []).map(
                  (answer) => Card(
                    child: ListTile(
                      title: Text('${answer['question']}'),
                      subtitle: Text('Response: ${answer['selectedAnswer']}'),
                      trailing: Icon(
                        answer['isCorrect'] == true
                            ? Icons.check_circle
                            : Icons.cancel_outlined,
                      ),
                    ),
                  ),
                ),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy ? null : () => _save(false),
                  child: const Text('Save review'),
                ),
                CheckboxListTile(
                  value: _notifyStudent,
                  onChanged: (value) =>
                      setState(() => _notifyStudent = value ?? true),
                  title: const Text('Notify student'),
                ),
                CheckboxListTile(
                  value: _notifyParent,
                  onChanged: (value) =>
                      setState(() => _notifyParent = value ?? true),
                  title: const Text('Notify parent'),
                ),
                FilledButton(
                  onPressed: _busy || result['gradeStatus'] != 'reviewed'
                      ? null
                      : () => _save(true),
                  child: const Text('Publish reviewed grade'),
                ),
              ],
            ),
    );
  }
}
