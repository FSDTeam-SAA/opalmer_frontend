import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/policy_content_service.dart';

class PolicyContentScreen extends ConsumerStatefulWidget {
  final PolicyContentType type;
  const PolicyContentScreen({super.key, required this.type});
  @override
  ConsumerState<PolicyContentScreen> createState() =>
      _PolicyContentScreenState();
}

class _PolicyContentScreenState extends ConsumerState<PolicyContentScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(policyContentProvider(widget.type));
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(policyContentProvider(widget.type));
    try {
      await ref.read(policyContentProvider(widget.type).future);
    } catch (_) {
      // The provider renders the retry state when refreshing fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == PolicyContentType.about
        ? 'About Us'
        : 'Terms and Conditions';
    final content = ref.watch(policyContentProvider(widget.type));
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          const AppHomeButton(),
          IconButton(
            onPressed: () => ref.invalidate(policyContentProvider(widget.type)),
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: content.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Unable to load this page. Check your connection and retry.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(policyContentProvider(widget.type)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (document) => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: document == null || document.html.trim().isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Content has not been published yet.'),
                        )
                      : SelectionArea(
                          child: HtmlWidget(
                            document.html,
                            textStyle: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(height: 1.6),
                            onTapUrl: (url) async {
                              final uri = Uri.tryParse(url);
                              if (uri == null ||
                                  ![
                                    'https',
                                    'http',
                                    'mailto',
                                    'tel',
                                  ].contains(uri.scheme)) {
                                return false;
                              }
                              return launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
