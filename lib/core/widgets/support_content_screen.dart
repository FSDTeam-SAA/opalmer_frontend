import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/teacher_provider.dart';
import 'app_home_button.dart';
import 'access_guide_screen.dart';
import '../../chat/models/chat_role.dart';
import '../../chat/screens/chat_dashboard.dart';

final supportContentProvider =
    FutureProvider.autoDispose<Map<String, List<Map<String, dynamic>>>>((
      ref,
    ) async {
      final api = ref.watch(apiClientProvider);
      final responses = await Future.wait([
        api.get('/featuresAndQuestions/AppFeatures'),
        api.get('/featuresAndQuestions/FAQquestions'),
      ]);
      List<Map<String, dynamic>> rows(dynamic body) => (body['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      return {
        'features': rows(responses[0].data),
        'faqs': rows(responses[1].data),
      };
    });

class SupportContentScreen extends ConsumerWidget {
  const SupportContentScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(supportContentProvider);
    final type = ref.watch(authStateProvider)?.type ?? 'teacher';
    final role = ChatRole.values.firstWhere(
      (role) => role.name == type,
      orElse: () => ChatRole.teacher,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Center'),
        actions: const [AppHomeButton()],
      ),
      body: content.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(supportContentProvider),
            child: const Text('Unable to load help. Retry'),
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(supportContentProvider);
            await ref.read(supportContentProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'For an account, class or record problem, contact your school. Include what happened and the affected record.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatDashboard(role: role)),
                ),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Open messages'),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AccessGuideScreen(role: type),
                  ),
                ),
                child: const Text('School contact details and guide'),
              ),
              const SizedBox(height: 20),
              Text(
                'App Features',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (data['features']!.isEmpty)
                const Text('No features have been published yet.'),
              for (final feature in data['features']!)
                Card(
                  child: ListTile(
                    title: Text(feature['question']?.toString() ?? ''),
                    subtitle: Text(feature['answer']?.toString() ?? ''),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (data['faqs']!.isEmpty)
                const Text('No FAQs have been published yet.'),
              for (final faq in data['faqs']!)
                ExpansionTile(
                  key: ValueKey(faq['_id']),
                  title: Text(faq['question']?.toString() ?? ''),
                  childrenPadding: const EdgeInsets.all(16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(faq['answer']?.toString() ?? ''),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
