import 'package:flutter/material.dart';
import '../core/services/api_client.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});
  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  final _api = ApiClient();
  final _password = TextEditingController();
  bool _enabled = false;
  bool _loading = true;
  bool _busy = false;
  String _email = '';
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await _api.get('/users/me');
      if (!mounted) return;
      setState(() {
        _enabled = response.data['data']['isTwoFactorAuthEnabled'] == true;
        _email = response.data['data']['email']?.toString() ?? '';
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Unable to load security settings. Please retry.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle() async {
    if (_password.text.isEmpty) {
      setState(() => _error = 'Enter your current password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _api.dio.put('/users/toggle', data: {'password': _password.text});
      _password.clear();
      await _load();
      if (mounted && _error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _enabled
                  ? 'Two-factor authentication enabled'
                  : 'Two-factor authentication disabled',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Unable to update. Check your current password and account email.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Two-Factor Authentication')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                _enabled ? 'Enabled' : 'Disabled',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                _email.isEmpty
                    ? 'Add an email to your profile before enabling two-factor authentication.'
                    : 'When enabled, a six-digit code is sent to $_email after your password is verified at sign-in.',
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy || _email.isEmpty ? null : _toggle,
                child: Text(
                  _busy
                      ? 'Saving...'
                      : _enabled
                      ? 'Disable two-factor authentication'
                      : 'Enable two-factor authentication',
                ),
              ),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                TextButton(onPressed: _load, child: const Text('Retry')),
              ],
            ],
          ),
  );
}
