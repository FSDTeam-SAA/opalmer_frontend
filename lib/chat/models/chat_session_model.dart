enum ChatSessionType { direct, group, draft }

enum MessagePreviewType { text, voice, photo }

class ChatSessionModel {
  final String id;
  final ChatSessionType type;
  final String title;
  final String subtitle;
  final DateTime updatedAt;
  final List<String> participantIds;
  final String? avatarUrl;
  final MessagePreviewType previewType;
  final bool showReadReceipt;

  const ChatSessionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.updatedAt,
    required this.participantIds,
    this.avatarUrl,
    this.previewType = MessagePreviewType.text,
    this.showReadReceipt = false,
  });

  String get displayDate {
    final month = updatedAt.month.toString().padLeft(2, '0');
    final day = updatedAt.day.toString().padLeft(2, '0');
    final year = (updatedAt.year % 100).toString().padLeft(2, '0');
    return '$month/$day/$year';
  }

  bool get isGroupOrDraft => type != ChatSessionType.direct;
}
