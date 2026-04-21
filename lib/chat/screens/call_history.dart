import 'package:flutter/material.dart';
import 'package:opalmer_education/chat/services/chat_api_service.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallHistoryScreen extends ConsumerStatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  ConsumerState<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends ConsumerState<CallHistoryScreen> {
  final ChatApiService _apiService = ChatApiService();
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final logs = await _apiService.getCallLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF871DAD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          "Call History",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _logs.isEmpty
          ? const Center(child: Text("No call history found"))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: _logs.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFF5F5F5)),
              itemBuilder: (context, index) {
                final log = _logs[index];
                final isIncoming = log['to'] == currentUser?.id;
                final participant = isIncoming ? log['from_user'] : log['to_user'];
                
                return _buildCallItem(
                  name: participant?['username'] ?? "Unknown",
                  date: log['startedAt'] ?? "Unknown",
                  isIncoming: isIncoming,
                  imageUrl: participant?['avatar'] ?? "",
                  status: log['status'] ?? "ended",
                );
              },
            ),
    );
  }

  Widget _buildCallItem({
    required String name,
    required String date,
    required bool isIncoming,
    required String imageUrl,
    required String status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          if (imageUrl.isNotEmpty)
            CircleAvatar(radius: 28, backgroundImage: NetworkImage(imageUrl))
          else
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Color(0xFF871DAD)),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isIncoming ? Icons.south_west : Icons.north_east,
                      size: 14,
                      color: status == 'missed' 
                        ? const Color(0xFFEA4335)
                        : const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$date • $status",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF871DAD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
