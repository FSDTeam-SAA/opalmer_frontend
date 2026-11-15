import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/teacher_provider.dart';
import 'app_home_button.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});
  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  static const categories = {
    'enabled': 'Allow notifications',
    'message': 'Messages',
    'homework': 'Assignments',
    'quiz': 'Assessments',
    'grades': 'Grades and feedback',
    'announcements': 'Announcements',
    'lesson': 'Lessons',
    'documents': 'Academic documents',
    'behavior': 'Behavior updates',
    'class': 'Class enrollment',
  };
  Map<String, bool> _preferences = {};
  bool _loading = true, _saving = false;
  bool _loaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loaded = false;
      _error = null;
    });
    try {
      final response = await ref.read(apiClientProvider).get('/users/me');
      final values = response.data['data']['notificationPreferences'];
      if (!mounted) return;
      setState(() {
        _preferences = {
          if (values is Map)
            for (final entry in values.entries)
              if (entry.value is bool)
                entry.key.toString(): entry.value as bool,
        };
        _loading = false;
        _loaded = true;
      });
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = 'Unable to load notification preferences.';
        });
    }
  }

  Future<void> _save() async {
    final userId = ref.read(authStateProvider)?.id;
    if (userId == null || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(apiClientProvider)
          .put(
            '/users/$userId',
            data: {'notificationPreferences': _preferences},
          );
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preferences saved.')),
        );
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to save. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notification Settings'),
      actions: const [AppHomeButton()],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: _load,
                  child: const Text('Retry loading'),
                ),
              ],
              for (final entry in categories.entries)
                SwitchListTile.adaptive(
                  title: Text(entry.value),
                  value: _preferences[entry.key] != false,
                  onChanged:
                      !_loaded ||
                          _saving ||
                          (entry.key != 'enabled' &&
                              _preferences['enabled'] == false)
                      ? null
                      : (value) =>
                            setState(() => _preferences[entry.key] = value),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: !_loaded || _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save preferences'),
              ),
            ],
          ),
  );
}
