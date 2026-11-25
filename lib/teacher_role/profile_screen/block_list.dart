import 'package:opalmer_education/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/teacher_provider.dart';
import '../../core/services/attachment_service.dart';
import '../../core/widgets/app_home_button.dart';

class BlockListScreen extends ConsumerStatefulWidget {
  const BlockListScreen({super.key});
  @override
  ConsumerState<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends ConsumerState<BlockListScreen> {
  List<dynamic>? _rooms;
  String? _error;
  final _busy = <String>{};
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await ref.read(apiClientProvider).get('/rooms/my-rooms');
      final userId = ref.read(authStateProvider)?.id;
      if (mounted) {
        setState(() {
          _rooms = (response.data['data'] as List)
              .where(
                (room) => (room['blockedBy'] as List? ?? []).contains(userId),
              )
              .toList();
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = AttachmentService.errorMessage(error));
      }
    }
  }

  Future<void> _unblock(String id) async {
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));
    try {
      await ref
          .read(apiClientProvider)
          .patch('/rooms/$id/block', data: {'blocked': false});
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AttachmentService.errorMessage(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateProvider)?.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Block list'),
        actions: const [AppHomeButton()],
      ),
      body: ResponsiveBody(
        child: _error != null
            ? Center(
                child: TextButton(
                  onPressed: _load,
                  child: Text('$_error Retry'),
                ),
              )
            : _rooms == null
            ? const Center(child: CircularProgressIndicator())
            : _rooms!.isEmpty
            ? const Center(child: Text('No blocked users'))
            : ListView(
                children: _rooms!.map((room) {
                  final peers = (room['participants'] as List)
                      .map((p) => p['userId'])
                      .whereType<Map>()
                      .where((user) => user['_id'] != userId);
                  final name = peers.isEmpty
                      ? 'Participant unavailable'
                      : peers.first['username']?.toString() ?? 'Participant';
                  final id = room['_id'].toString();
                  return ListTile(
                    leading: const Icon(Icons.person_off_outlined),
                    title: Text(name),
                    trailing: TextButton(
                      onPressed: _busy.contains(id) ? null : () => _unblock(id),
                      child: const Text('Unblock'),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
