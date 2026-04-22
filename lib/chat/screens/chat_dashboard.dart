import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/notification/notification.dart';

import '../models/chat_role.dart';
import '../models/chat_session_model.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_dashboard_header.dart';
import '../widgets/chat_dashboard_tabs.dart';
import '../widgets/chat_room_list.dart';
import 'call_history.dart';
import 'send_to.dart';

class ChatDashboard extends ConsumerStatefulWidget {
  final int initialTab;
  final ChatRole role;

  const ChatDashboard({
    super.key,
    this.initialTab = 0,
    this.role = ChatRole.teacher,
  });

  @override
  ConsumerState<ChatDashboard> createState() => _ChatDashboardState();
}

class _ChatDashboardState extends ConsumerState<ChatDashboard> {
  late int _selectedTab;
  int? _openedIndex;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  void _handleSlide(int tab, int index) {
    final uniqueId = tab * 1000 + index;
    if (_openedIndex == uniqueId) return;

    setState(() {
      _openedIndex = uniqueId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _DashboardContent(
            role: widget.role,
            selectedTab: _selectedTab,
            openedIndex: _openedIndex,
            onTabChanged: (index) => setState(() => _selectedTab = index),
            onSlide: _handleSlide,
            directRooms: _roomsForType(ChatSessionType.direct),
            draftRooms: _roomsForType(ChatSessionType.draft),
            groupRooms: _roomsForType(ChatSessionType.group),
          ),
          if (widget.role.canComposeNewChat)
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                heroTag: 'chat_fab_${widget.role.name}',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendToScreen(role: widget.role),
                    ),
                  );
                },
                backgroundColor: const Color(0xFF871DAD),
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
        ],
      ),
    );
  }

  List<ChatSessionModel> _roomsForType(ChatSessionType type) {
    final rooms = ref.watch(chatNotifierProvider).rooms;
    return rooms.where((room) => room.type == type).toList();
  }
}

class _DashboardContent extends ConsumerWidget {
  final ChatRole role;
  final int selectedTab;
  final int? openedIndex;
  final ValueChanged<int> onTabChanged;
  final void Function(int tab, int index) onSlide;
  final List<ChatSessionModel> directRooms;
  final List<ChatSessionModel> draftRooms;
  final List<ChatSessionModel> groupRooms;

  const _DashboardContent({
    required this.role,
    required this.selectedTab,
    required this.openedIndex,
    required this.onTabChanged,
    required this.onSlide,
    required this.directRooms,
    required this.draftRooms,
    required this.groupRooms,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatNotifierProvider);

    return Column(
      children: [
        ChatDashboardHeader(
          onOpenCallHistory: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CallHistoryScreen(),
              ),
            );
          },
          onOpenNotifications: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ChatDashboardTabs(
          selectedTab: selectedTab,
          groupTabLabel: role.groupTabLabel,
          onChanged: onTabChanged,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: chatState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : chatState.error != null
              ? Center(
                  child: Text(
                    chatState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : IndexedStack(
                  index: selectedTab,
                  children: [
                    ChatRoomList(
                      sessions: directRooms,
                      tab: 0,
                      role: role,
                      openedIndex: openedIndex,
                      onSlide: onSlide,
                    ),
                    ChatRoomList(
                      sessions: draftRooms,
                      tab: 1,
                      role: role,
                      openedIndex: openedIndex,
                      onSlide: onSlide,
                    ),
                    ChatRoomList(
                      sessions: groupRooms,
                      tab: 2,
                      role: role,
                      openedIndex: openedIndex,
                      onSlide: onSlide,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
