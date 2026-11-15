import 'package:flutter/material.dart';

class ChatMessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  final bool isSending;

  const ChatMessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled && !isSending,
              maxLength: 5000,
              decoration: InputDecoration(
                hintText: 'Type a message',
                counterText: '',
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            tooltip: 'Send message',
            onPressed: enabled && !isSending ? onSend : null,
            icon: isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
          ),
        ],
      ),
    );
  }
}
