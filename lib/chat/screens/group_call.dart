import 'package:flutter/material.dart';
import 'package:opalmer_education/teacher_role/profile_screen/language.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupName;

  const GroupChatScreen({super.key, required this.groupName});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        centerTitle: false,
        titleSpacing: 0,
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
        title: Text(
          widget.groupName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF871DAD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.translate,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildMessage(text: "Good Morning!", time: "17:47", isMe: true),
                _buildMessage(
                  text: "Hey! How are you?",
                  time: "17:47",
                  isMe: false,
                  imageUrl: "https://i.pravatar.cc/150?u=sarah",
                ),
                _buildMessage(
                  text: "He skips homework sometimes.",
                  time: "17:47",
                  isMe: true,
                ),
                _buildMessage(
                  text: "Science is going well.",
                  time: "17:47",
                  isMe: false,
                  imageUrl: "https://i.pravatar.cc/150?u=teacher2",
                ),
                _buildMessage(
                  text: "Any suggestions for home?",
                  time: "17:47",
                  isMe: false,
                  imageUrl: "https://i.pravatar.cc/150?u=parent1",
                ),
                _buildMessage(
                  text: "Short quizzes, fun learning. I'll share resources.",
                  time: "17:47",
                  isMe: true,
                ),
                _buildMessage(
                  text: "Thank you very much.",
                  time: "17:47",
                  isMe: false,
                  imageUrl: "https://i.pravatar.cc/150?u=sarah",
                ),
              ],
            ),
          ),
          // Bottom Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  suffixIcon: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF871DAD),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF871DAD),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.send, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage({
    required String text,
    required String time,
    required bool isMe,
    String? imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe && imageUrl != null) ...[
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: CustomPaint(
                  painter: _UnifiedBubblePainter(
                    isMe: isMe,
                    color: isMe
                        ? const Color(0xFFF1F0F0)
                        : const Color(0xFF871DAD),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 15,
                            color: isMe
                                ? const Color(0xFF222222)
                                : Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe
                                    ? Colors.grey.shade400
                                    : Colors.white70,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.done_all,
                                size: 14,
                                color: Color(0xFF4FA0F3),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!isMe) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 48), // Align with bubble
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Text(
                      "Translate",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.refresh,
                      size: 16,
                      color: const Color(0xFF871DAD).withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnifiedBubblePainter extends CustomPainter {
  final bool isMe;
  final Color color;

  _UnifiedBubblePainter({required this.isMe, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const r = 16.0;
    final w = size.width;
    final h = size.height;

    if (isMe) {
      path.moveTo(r, 0);
      path.lineTo(w - r, 0);
      path.quadraticBezierTo(w, 0, w, r);
      path.lineTo(w, h - 8);
      path.lineTo(w + 8, h);
      path.lineTo(w - r, h);
      path.quadraticBezierTo(w - r - 4, h, w - r - 4, h);
      path.lineTo(r, h);
      path.quadraticBezierTo(0, h, 0, h - r);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
    } else {
      path.moveTo(r, 0);
      path.lineTo(w - r, 0);
      path.quadraticBezierTo(w, 0, w, r);
      path.lineTo(w, h - r);
      path.quadraticBezierTo(w, h, w - r, h);
      path.lineTo(r, h);
      path.lineTo(-8, h);
      path.lineTo(0, h - 8);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
