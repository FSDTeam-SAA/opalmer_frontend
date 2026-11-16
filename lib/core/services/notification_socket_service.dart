import 'package:flutter/foundation.dart';
import 'package:opalmer_education/core/services/secure_storage_service.dart';
import 'package:opalmer_education/core/constants/api_constants.dart';
import 'package:opalmer_education/core/models/notification_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

typedef NotificationCallback = void Function(NotificationModel notification);

class NotificationSocketService {
  NotificationSocketService._internal();
  static final NotificationSocketService _instance =
      NotificationSocketService._internal();
  factory NotificationSocketService() => _instance;

  io.Socket? _socket;
  String? _joinedUserId;
  String? _token;
  int _generation = 0;
  NotificationCallback? onNotification;
  void Function(Map<String, dynamic> event)? onDataChanged;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect(String userId) async {
    final generation = ++_generation;
    String? token;
    try {
      token = await SecureStorageService().getToken();
    } catch (e) {
      debugPrint('NotificationSocket: token unavailable: $e');
    }
    if (generation != _generation) return;
    if (token == null || token.isEmpty) {
      disconnect();
      return;
    }
    if (_socket != null && _joinedUserId == userId && _token == token) {
      if (!_socket!.connected) _socket!.connect();
      return;
    }

    _socket?.dispose();
    _joinedUserId = userId;
    _token = token;

    final socket = io.io(
      ApiConstants.socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableForceNew()
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .build(),
    );

    socket.onConnect((_) {
      debugPrint(
        'NotificationSocket: connected to authenticated notification stream',
      );
    });

    socket.on('newNotification', (data) {
      if (_socket != socket || _joinedUserId != userId) return;
      if (data is Map) {
        try {
          final notification = NotificationModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          onNotification?.call(notification);
        } catch (e) {
          debugPrint('NotificationSocket: failed to parse payload: $e');
        }
      }
    });

    socket.on('dataChanged', (data) {
      if (_socket != socket || _joinedUserId != userId || data is! Map) return;
      onDataChanged?.call(Map<String, dynamic>.from(data));
    });

    socket.onDisconnect((_) => debugPrint('NotificationSocket: disconnected'));
    socket.onConnectError(
      (err) => debugPrint('NotificationSocket: connect error: $err'),
    );
    socket.onError((err) => debugPrint('NotificationSocket: error: $err'));

    _socket = socket;
  }

  void disconnect() {
    _generation++;
    _socket?.dispose();
    _socket = null;
    _joinedUserId = null;
    _token = null;
  }
}
