import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDetails extends StatelessWidget {
  final String title;
  final Map<String, dynamic> record;
  const NotificationDetails({
    super.key,
    required this.title,
    required this.record,
  });
  @override
  Widget build(BuildContext context) {
    final document = record['document'];
    return Scaffold(
      appBar: AppBar(actions: [const AppHomeButton()], title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (record['title'] != null)
            Text(
              record['title'].toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          for (final field in ['description', 'objective', 'note', 'message'])
            if (record[field]?.toString().isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(record[field].toString()),
              ),
          if (record['status'] != null) Text('Status: ${record['status']}'),
          if (record['state'] != null) Text('Category: ${record['state']}'),
          if (record['date'] != null)
            Text(
              'Date: ${DateTime.tryParse(record['date'].toString())?.toLocal() ?? record['date']}',
            ),
          if (document is Map && document['url'] != null)
            TextButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open attachment'),
              onPressed: () async {
                final uri = Uri.tryParse(document['url'].toString());
                if (uri != null && uri.isScheme('https')) {
                  await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                }
              },
            ),
        ],
      ),
    );
  }
}
