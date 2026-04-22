import 'package:flutter/material.dart';

class CallHistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  final String? currentUserId;

  const CallHistoryList({
    super.key,
    required this.logs,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(child: Text('No call history found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: logs.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
      itemBuilder: (context, index) {
        final log = logs[index];
        final isIncoming = log['to'] == currentUserId;
        final participant = isIncoming ? log['from_user'] : log['to_user'];

        return _CallHistoryItem(
          name: participant?['username'] ?? 'Unknown',
          date: log['startedAt'] ?? 'Unknown',
          isIncoming: isIncoming,
          imageUrl: participant?['avatar'] ?? '',
          status: log['status'] ?? 'ended',
        );
      },
    );
  }
}

class _CallHistoryItem extends StatelessWidget {
  final String name;
  final String date;
  final bool isIncoming;
  final String imageUrl;
  final String status;

  const _CallHistoryItem({
    required this.name,
    required this.date,
    required this.isIncoming,
    required this.imageUrl,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
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
                      '$date • $status',
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
