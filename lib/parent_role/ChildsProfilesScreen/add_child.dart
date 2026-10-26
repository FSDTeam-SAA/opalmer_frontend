import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:opalmer_education/core/services/api_client.dart';

class AddChildDialog extends StatefulWidget {
  final ApiClient? apiClient;
  const AddChildDialog({super.key, this.apiClient});
  @override
  State<AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<AddChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final _student = TextEditingController();
  final _invitation = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _student.dispose();
    _invitation.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response = await (widget.apiClient ?? ApiClient()).post(
        '/parent/child',
        data: {
          'childId': _student.text.trim(),
          'invitationCode': _invitation.text.trim().toUpperCase(),
        },
      );
      if (response.data['success'] != true) {
        throw StateError('Unable to link student');
      }
      if (mounted) Navigator.pop(context, true);
    } on DioException catch (error) {
      if (mounted) {
        setState(
          () => _error = error.response?.data is Map
              ? error.response!.data['message']?.toString()
              : 'Unable to link student.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to link student. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF871DAD);
    InputDecoration input(String hint, IconData icon) => InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF777777)),
    );
    return PopScope(
      canPop: !_busy,
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: purple.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.family_restroom_outlined,
                          color: purple,
                          size: 26,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: _busy ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF777777)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Link Your Student',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the student ID and invitation code provided by the school. The invitation must match your account email.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF777777),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Student ID',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _student,
                    enabled: !_busy,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: input('Enter student ID', Icons.badge_outlined),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter the student ID.'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Invitation code',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _invitation,
                    enabled: !_busy,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: input(
                      'Enter invitation code',
                      Icons.key_outlined,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter the invitation code.'
                        : null,
                    onFieldSubmitted: (_) => _link(),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _busy ? null : _link,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Link student',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy ? null : () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF777777)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
