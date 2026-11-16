import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/services/api_client.dart';

class PasswordResetScreen extends StatefulWidget {
  final String initialIdentifier;
  final ApiClient? apiClient;
  const PasswordResetScreen({
    super.key,
    this.initialIdentifier = '',
    this.apiClient,
  });
  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _identifier;
  final _code = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController();
  late final ApiClient _api;
  bool _sent = false, _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _identifier = TextEditingController(text: widget.initialIdentifier);
    _api = widget.apiClient ?? ApiClient();
  }

  @override
  void dispose() {
    _identifier.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final identifier = _identifier.text.trim();
      if (!_sent) {
        await _api.post('/users/forgot-password', data: {'Id': identifier});
        if (mounted) setState(() => _sent = true);
      } else {
        await _api.post(
          '/users/reset-password',
          data: {
            'Id': identifier,
            'code': _code.text.trim(),
            'newPassword': _password.text,
          },
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset. Sign in with your new password.'),
          ),
        );
        Navigator.pop(context, identifier);
      }
    } on DioException catch (error) {
      if (mounted) {
        setState(
          () => _error = error.response?.data is Map
              ? error.response!.data['message']?.toString()
              : 'Unable to connect. Please try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Unable to complete your request. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reset password')),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            _sent
                ? 'If this account has an email, a reset code has been sent. Check your inbox and spam folder. Codes expire in 15 minutes.'
                : 'Enter your account ID or email to request a password reset code.',
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _identifier,
            enabled: !_busy && !_sent,
            decoration: const InputDecoration(labelText: 'ID or email'),
            validator: (value) => value?.trim().isEmpty != false
                ? 'Enter your ID or email.'
                : null,
          ),
          if (_sent) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _code,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 8,
              autofillHints: const [AutofillHints.oneTimeCode],
              decoration: const InputDecoration(labelText: 'Reset code'),
              validator: (value) => RegExp(r'^\d{8}$').hasMatch(value ?? '')
                  ? null
                  : 'Enter the 8-digit code.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              enabled: !_busy,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: const InputDecoration(labelText: 'New password'),
              validator: (value) =>
                  value == null || value.length < 8 || value.length > 128
                  ? 'Use 8 to 128 characters.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirm,
              enabled: !_busy,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
              ),
              validator: (value) =>
                  value == _password.text ? null : 'Passwords do not match.',
            ),
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(
              _busy
                  ? 'Please wait...'
                  : _sent
                  ? 'Reset password'
                  : 'Send reset code',
            ),
          ),
          if (_sent)
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                      _sent = false;
                      _error = null;
                    }),
              child: const Text('Change account or request a new code'),
            ),
        ],
      ),
    ),
  );
}
