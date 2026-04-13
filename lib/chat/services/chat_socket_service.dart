import 'dart:async';

import '../models/message_model.dart';

enum ChatSocketConnectionStatus { disconnected, connecting, connected }

class ChatSocketService {
  final StreamController<MessageModel> _messageController =
      StreamController<MessageModel>.broadcast();

  ChatSocketConnectionStatus _status = ChatSocketConnectionStatus.disconnected;

  ChatSocketConnectionStatus get status => _status;
  Stream<MessageModel> get messages => _messageController.stream;

  Future<void> connect({required String userId}) async {
    _status = ChatSocketConnectionStatus.connecting;

    // TODO: Replace this with Socket.IO or WebSocket connection setup.
    _status = ChatSocketConnectionStatus.connected;
  }

  Future<void> disconnect() async {
    // TODO: Disconnect the underlying Socket.IO or WebSocket client.
    _status = ChatSocketConnectionStatus.disconnected;
  }

  void emitMessage(MessageModel message) {
    // TODO: Send this through the connected socket client.
    _messageController.add(message);
  }

  void onMessageReceived(MessageModel message) {
    _messageController.add(message);
  }

  void dispose() {
    _messageController.close();
  }
}
