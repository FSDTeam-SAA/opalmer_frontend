import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/chat/providers/chat_provider.dart';
import 'package:opalmer_education/chat/services/chat_api_service.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';

import '../models/chat_role.dart';
import 'chat_screen.dart';

class SendToScreen extends ConsumerStatefulWidget {
  final ChatRole role;

  const SendToScreen({super.key, this.role = ChatRole.teacher});

  @override
  ConsumerState<SendToScreen> createState() => _SendToScreenState();
}

class _SendToScreenState extends ConsumerState<SendToScreen> {
  final ChatApiService _apiService = ChatApiService();
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await _apiService.getContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          "Send To",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Search",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contacts.isEmpty
                    ? const Center(child: Text("No contacts found"))
                    : _buildGroupedListView(),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () async {
                        try {
                          final user = ref.read(authStateProvider);
                          if (user == null) return;

                          // Create room or go to existing
                          final participants = _selectedIds.toList();
                          final room = await _apiService.createRoom(
                            participants,
                            user.id,
                          );
                          if (room != null && mounted) {
                            // Register room with notifier
                            ref
                                .read(chatNotifierProvider.notifier)
                                .addRoom(room);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                    session: room, role: widget.role),
                              ),
                            );
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Failed to create chat room. You may not have permission.")),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            String message = e.toString();
                            if (message.contains("403")) {
                              message =
                                  "Access denied. You can only message students in your classes.";
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF871DAD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "(${_selectedIds.length}) SEND",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedListView() {
    // Group contacts by type
    final teachers = _contacts
        .where((c) => c['type'] == 'teacher' || c['role'] == 'administrator')
        .toList();
    final students = _contacts.where((c) => c['type'] == 'student').toList();
    final parents = _contacts.where((c) => c['type'] == 'parent').toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (teachers.isNotEmpty) ...[
          _buildSectionHeader("Teachers"),
          ...teachers.map((c) => _buildListTile(c)),
        ],
        if (students.isNotEmpty) ...[
          _buildSectionHeader("Students"),
          ...students.map((c) => _buildListTile(c)),
        ],
        if (parents.isNotEmpty) ...[
          _buildSectionHeader("Parents"),
          ...parents.map((c) => _buildListTile(c)),
        ],
        const SizedBox(height: 80), // Space for button
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF871DAD),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildListTile(Map<String, dynamic> contact) {
    final String id = contact['id']?.toString() ?? "";
    final String name = contact['username'] ?? contact['name'] ?? "User";
    final String? avatarUrl = contact['avatar'] ?? contact['imageUrl'];
    bool isSelected = _selectedIds.contains(id);

    return GestureDetector(
      onTap: () => _toggleSelection(id),
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        color: Colors.transparent,
        child: Row(
          children: [
            Stack(
              children: [
                if (avatarUrl != null &&
                    avatarUrl.isNotEmpty &&
                    !avatarUrl.toLowerCase().endsWith('.pdf'))
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: NetworkImage(avatarUrl),
                    onBackgroundImageError: (_, __) {
                      // Fallback handled by the "else" block or stacked Icon
                    },
                  )
                else
                  _buildPlaceholderAvatar(),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF871DAD).withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.check, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF222222),
                    ),
                  ),
                  if (contact['subtitle'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      contact['subtitle'].toString(),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      (contact['type'] ?? contact['role'] ?? 'USER')
                          .toString()
                          .toUpperCase(),
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF871DAD).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Color(0xFF871DAD), size: 28),
    );
  }
}
