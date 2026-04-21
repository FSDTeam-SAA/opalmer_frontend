import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/notification/notification.dart';

import '../models/chat_role.dart';
import '../models/chat_session_model.dart';
import '../providers/chat_provider.dart';
import 'call_history.dart';
import 'chat_screen.dart';
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
    int uniqueId = tab * 1000 + index;
    if (_openedIndex != uniqueId) {
      setState(() {
        _openedIndex = uniqueId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildContent(),
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

  Widget _buildContent() {
    final chatState = ref.watch(chatNotifierProvider);

    return Column(
      children: [
        // Header
        Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 140,
              child: Image.asset(
                'assets/images/Home_dashboard_header.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Chat",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CallHistoryScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            child: Center(
                              child: Image.asset(
                                'assets/images/home_dashboard/call_icons.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/home_dashboard/notification.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Custom Segmented Control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabItem("Chat", 0)),
                Expanded(child: _buildTabItem("Draft", 1)),
                Expanded(child: _buildTabItem(widget.role.groupTabLabel, 2)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Tabs Content
        Expanded(
          child: chatState.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : chatState.error != null
              ? Center(child: Text(chatState.error!, style: const TextStyle(color: Colors.red)))
              : IndexedStack(
                  index: _selectedTab,
                  children: [
                    _buildRoomList(chatState.rooms.where((r) => r.type == ChatSessionType.direct).toList(), 0),
                    _buildRoomList(chatState.rooms.where((r) => r.type == ChatSessionType.draft).toList(), 1),
                    _buildRoomList(chatState.rooms.where((r) => r.type == ChatSessionType.group).toList(), 2),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF871DAD) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomList(List<ChatSessionModel> sessions, int tab) {
    if (sessions.isEmpty) {
      return Center(child: Text("No ${tab == 0 ? 'chats' : tab == 1 ? 'drafts' : 'groups'} found", style: TextStyle(color: Colors.grey.shade400)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: sessions.length,
      itemBuilder: (context, index) =>
          _buildSessionListItem(sessions[index], index, tab),
    );
  }

  Widget _buildSessionListItem(ChatSessionModel session, int index, int tab) {
    return _SlidableListItem(
      index: index,
      tab: tab,
      openedIndex: _openedIndex,
      onSlide: _handleSlide,
      session: session,
      role: widget.role,
      actions: _actionsForSession(session),
    );
  }

  List<_SlidableAction> _actionsForSession(ChatSessionModel session) {
    if (session.type == ChatSessionType.direct) {
      return [
        _SlidableAction(
          color: const Color(0xFFC4C4C4),
          icon: Icons.more_horiz,
          label: "More",
        ),
        _SlidableAction(
          color: const Color(0xFFEA4335),
          icon: Icons.delete_outline,
          label: "Delete",
        ),
      ];
    }

    return [
      _SlidableAction(
        color: const Color(0xFFEA4335),
        icon: Icons.delete_outline,
        label: "Delete",
      ),
    ];
  }
}

class _SlidableAction {
  final Color color;
  final IconData icon;
  final String label;
  _SlidableAction({
    required this.color,
    required this.icon,
    required this.label,
  });
}

class _SlidableListItem extends StatefulWidget {
  final int index;
  final int tab;
  final int? openedIndex;
  final Function(int, int) onSlide;
  final ChatSessionModel session;
  final ChatRole role;
  final List<_SlidableAction> actions;

  const _SlidableListItem({
    required this.index,
    required this.tab,
    required this.openedIndex,
    required this.onSlide,
    required this.session,
    required this.role,
    required this.actions,
  });

  @override
  State<_SlidableListItem> createState() => _SlidableListItemState();
}

class _SlidableListItemState extends State<_SlidableListItem>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  final double _actionWidth = 70.0;

  @override
  void didUpdateWidget(_SlidableListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    int uniqueId = widget.tab * 1000 + widget.index;
    if (widget.openedIndex != uniqueId && _dragExtent != 0) {
      _animateTo(0);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = _controller.drive(Tween<double>(begin: 0, end: 1));
    _controller.addListener(() {
      setState(() {
        _dragExtent = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _maxExtent => -(_actionWidth * widget.actions.length);

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta! < 0 && _dragExtent == 0) {
      widget.onSlide(widget.tab, widget.index);
    }
    setState(() {
      _dragExtent += details.primaryDelta!;
      if (_dragExtent > 0) _dragExtent = 0;
      if (_dragExtent < _maxExtent) _dragExtent = _maxExtent;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragExtent < _maxExtent / 2) {
      _animateTo(_maxExtent);
    } else {
      _animateTo(0);
    }
  }

  void _animateTo(double target) {
    _controller.stop();
    _animation = _controller.drive(
      Tween<double>(begin: _dragExtent, end: target),
    );
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: widget.actions
                  .map(
                    (action) => Container(
                      width: _actionWidth,
                      color: action.color,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(action.icon, color: Colors.white),
                          Text(
                            action.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    session: session,
                    role: widget.role,
                  ),
                ),
              );
            },
            child: Transform.translate(
              offset: Offset(_dragExtent, 0),
              child: Container(
                color: Colors.white,
                child: Row(
                  children: [
                    if (session.avatarUrl != null && session.avatarUrl!.isNotEmpty)
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(session.avatarUrl!),
                      )
                    else
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF871DAD).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _sessionIcon(session),
                          color: const Color(0xFF871DAD),
                          size: 28,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                session.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF222222),
                                ),
                              ),
                              Text(
                                session.displayDate,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (session.previewType != MessagePreviewType.text) ...[
                                Icon(
                                  _previewIcon(session.previewType),
                                  size: 16,
                                  color: const Color(0xFF4CAF50),
                                ),
                                const SizedBox(width: 4),
                              ],
                              if (session.showReadReceipt) ...[
                                const Icon(
                                  Icons.done_all,
                                  size: 16,
                                  color: Color(0xFF4FA0F3),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Expanded(
                                child: Text(
                                  session.subtitle,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _sessionIcon(ChatSessionModel session) {
    switch (session.type) {
      case ChatSessionType.draft:
        return Icons.description_outlined;
      case ChatSessionType.group:
        return widget.role == ChatRole.parent
            ? Icons.co_present_outlined
            : Icons.school_outlined;
      case ChatSessionType.direct:
        return Icons.person_outline;
    }
  }

  IconData? _previewIcon(MessagePreviewType previewType) {
    switch (previewType) {
      case MessagePreviewType.voice:
        return Icons.mic_none_outlined;
      case MessagePreviewType.photo:
        return Icons.camera_alt_outlined;
      case MessagePreviewType.text:
        return null;
    }
  }
}
