import 'package:flutter/material.dart';

import '../models/chat_role.dart';
import 'compose_message.dart';

class SendToScreen extends StatefulWidget {
  final ChatRole role;

  const SendToScreen({super.key, this.role = ChatRole.teacher});

  @override
  State<SendToScreen> createState() => _SendToScreenState();
}

class _SendToScreenState extends State<SendToScreen> {
  final Set<int> _selectedIndices = {};

  List<Map<String, dynamic>> get _frequentChats {
    if (widget.role == ChatRole.parent) {
      return [
        {
          "name": "Ms. Sarah Michelle",
          "time": "11/19/19",
          "message": "Science progress update",
          "imageUrl": "https://i.pravatar.cc/150?u=sarah",
        },
        {
          "name": "Subject Teachers - Science",
          "time": "11/19/19",
          "message": "Ask the science teaching team",
          "icon": Icons.co_present_outlined,
        },
        {
          "name": "Mr. Randolph",
          "time": "11/19/19",
          "message": "Math homework support",
          "imageUrl": "https://i.pravatar.cc/150?u=randolph",
        },
      ];
    }

    return [
      {
        "name": "Sarah Michelle",
        "time": "11/19/19",
        "message": "0:14",
        "imageUrl": "https://i.pravatar.cc/150?u=sarah",
        "icon": Icons.mic_none_outlined,
      },
      {
        "name": "Grade 6 - Science",
        "time": "11/19/19",
        "message": "Actually I wanted to check with you...",
        "icon": Icons.school_outlined,
      },
      {
        "name": "Tabitha Potter",
        "time": "11/19/19",
        "message": "Actually I wanted to check with you...",
        "imageUrl": "https://i.pravatar.cc/150?u=tabitha",
      },
    ];
  }

  List<Map<String, dynamic>> get _recentChats {
    if (widget.role == ChatRole.parent) {
      return [
        {
          "name": "Subject Teachers - Math",
          "time": "11/19/19",
          "message": "Practice sheets are ready",
          "icon": Icons.co_present_outlined,
        },
        {
          "name": "Ms. Tabitha Potter",
          "time": "11/19/19",
          "message": "Reading notes for Mia",
          "imageUrl": "https://i.pravatar.cc/150?u=tabitha",
        },
      ];
    }

    return [
      {
        "name": "Grade 5 - Science",
        "time": "11/19/19",
        "message": "Actually I wanted to check with you...",
        "icon": Icons.school_outlined,
      },
      {
        "name": "Grade 3 - Science",
        "time": "11/19/19",
        "message": "Actually I wanted to check with you...",
        "icon": Icons.school_outlined,
      },
      {
        "name": "Kiron Doston",
        "time": "11/19/19",
        "message": "Ok, have a good day",
        "imageUrl": "https://i.pravatar.cc/150?u=kiron",
        "showCheck": true,
      },
      {
        "name": "Maximillian Jacobson",
        "time": "11/19/19",
        "message": "Actually I wanted to check with you...",
        "imageUrl": "https://i.pravatar.cc/150?u=max",
      },
    ];
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIndices.contains(id)) {
        _selectedIndices.remove(id);
      } else {
        _selectedIndices.add(id);
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Text(
                  widget.role.frequentSectionLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_frequentChats.length, (index) {
                  return _buildListTile(index, _frequentChats[index]);
                }),
                const SizedBox(height: 16),
                Text(
                  widget.role.recentSectionLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_recentChats.length, (index) {
                  return _buildListTile(index + 100, _recentChats[index]);
                }),
              ],
            ),
          ),
          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedIndices.isEmpty
                    ? null
                    : () {
                        // Find the first selected recipient's info
                        Map<String, dynamic> selectedChat;
                        if (_selectedIndices.isNotEmpty) {
                          int id = _selectedIndices.first;
                          if (id < 100) {
                            selectedChat = _frequentChats[id];
                          } else {
                            selectedChat = _recentChats[id - 100];
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComposeMessageScreen(
                                name: selectedChat['name'],
                                imageUrl:
                                    selectedChat['imageUrl'] ??
                                    "https://i.pravatar.cc/150?u=${selectedChat['name'].hashCode}",
                                role: widget.role,
                              ),
                            ),
                          );
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
                  "(${_selectedIndices.length}) SEND",
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

  Widget _buildListTile(int id, Map<String, dynamic> chat) {
    bool isSelected = _selectedIndices.contains(id);

    return GestureDetector(
      onTap: () => _toggleSelection(id),
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        color: Colors.transparent, // For reliable tapping
        child: Row(
          children: [
            Stack(
              children: [
                if (chat['imageUrl'] != null)
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(chat['imageUrl']),
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
                      chat['icon'],
                      color: const Color(0xFF871DAD),
                      size: 28,
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF871DAD).withValues(alpha: 0.4),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF222222),
                        ),
                      ),
                      Text(
                        chat['time'],
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
                      if (chat['icon'] != null && chat['imageUrl'] != null) ...[
                        Icon(
                          chat['icon'],
                          size: 16,
                          color: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (chat['showCheck'] == true) ...[
                        const Icon(
                          Icons.done_all,
                          size: 16,
                          color: Color(0xFF4FA0F3),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          chat['message'],
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
    );
  }
}
