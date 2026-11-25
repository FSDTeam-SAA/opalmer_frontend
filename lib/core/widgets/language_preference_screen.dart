import 'package:opalmer_education/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/teacher_provider.dart';
import 'app_home_button.dart';

class LanguagePreferenceScreen extends ConsumerStatefulWidget {
  const LanguagePreferenceScreen({super.key});
  @override
  ConsumerState<LanguagePreferenceScreen> createState() =>
      _LanguagePreferenceScreenState();
}

class _LanguagePreferenceScreenState
    extends ConsumerState<LanguagePreferenceScreen> {
  static const languages = {
    'en': 'English (US)',
    'en-GB': 'English (UK)',
    'bn': 'Bangla',
    'fr': 'French',
    'de': 'German',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ru': 'Russian',
    'it': 'Italian',
    'es': 'Spanish',
  };
  String _selected = 'en', _search = '';
  bool _loading = true, _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await ref.read(apiClientProvider).get('/users/me');
      if (!mounted) return;
      final code = response.data['data']['language']?.toString() ?? 'en';
      setState(() {
        _selected = code == 'en_us'
            ? 'en'
            : code == 'en_uk'
            ? 'en-GB'
            : code;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Unable to load your language preference.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    final userId = ref.read(authStateProvider)?.id;
    if (userId == null || _saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(apiClientProvider)
          .put('/users/$userId', data: {'language': _selected});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Language preference saved.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Language preference'),
      actions: const [AppHomeButton()],
    ),
    body: ResponsiveBody(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _load();
                },
                child: Text('$_error Retry'),
              ),
            )
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Save your preferred language to your profile. App menus currently use English.',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Find a language',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) =>
                        setState(() => _search = value.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final entry in languages.entries.where(
                        (entry) => entry.value.toLowerCase().contains(_search),
                      ))
                        ListTile(
                          title: Text(entry.value),
                          selected: _selected == entry.key,
                          trailing: _selected == entry.key
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF871DAD),
                                )
                              : const Icon(Icons.radio_button_unchecked),
                          onTap: _saving
                              ? null
                              : () => setState(() => _selected = entry.key),
                        ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? 'Saving...' : 'Save preference'),
                    ),
                  ),
                ),
              ],
            ),
    ),
  );
}
