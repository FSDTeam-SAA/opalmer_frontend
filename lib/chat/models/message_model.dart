enum MessageDeliveryStatus { sending, sent, delivered, read, failed }

class MessageModel {
  final String id;
  final String chatSessionId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final MessageDeliveryStatus deliveryStatus;

  const MessageModel({
    required this.id,
    required this.chatSessionId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.deliveryStatus = MessageDeliveryStatus.sent,
  });

  MessageModel copyWith({
    String? id,
    String? chatSessionId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
    MessageDeliveryStatus? deliveryStatus,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}
