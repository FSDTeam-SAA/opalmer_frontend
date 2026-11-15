import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:opalmer_education/chat/controllers/call_session_controller.dart';
import 'package:opalmer_education/chat/models/call_models.dart';
import 'package:opalmer_education/chat/services/call_socket_service.dart';

class SignalSocket implements CallSocketService {
  final signals = StreamController<CallSignalEvent>.broadcast(sync: true);
  @override
  Stream<CallSignalEvent> get userSignal => signals.stream;
  @override
  Stream<CallSignalEvent> get returnedSignal => const Stream.empty();
  @override
  Stream<CallAcceptedEvent> get callAccepted => const Stream.empty();
  @override
  Stream<CallDeclinedEvent> get callDeclined => const Stream.empty();
  @override
  Stream<CallEndedEvent> get callEnded => const Stream.empty();
  @override
  Stream<List<String>> get allUsers => const Stream.empty();
  @override
  Stream<String> get userJoined => const Stream.empty();
  @override
  Stream<String> get userLeft => const Stream.empty();
  @override
  void sendSignal({
    required String targetSocketId,
    required Map<String, dynamic> signal,
    required bool isCaller,
  }) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SignalPeer extends RTCPeerConnection {
  final events = <String>[];
  int closes = 0;
  @override
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    events.add('remote:${description.type}');
  }

  @override
  Future<void> setLocalDescription(RTCSessionDescription description) async {
    events.add('local:${description.type}');
  }

  @override
  Future<void> addCandidate(RTCIceCandidate candidate) async {
    events.add('candidate');
  }

  @override
  Future<RTCSessionDescription> createAnswer([
    Map<String, dynamic>? constraints,
  ]) async => RTCSessionDescription('test answer', 'answer');
  @override
  Future<void> close() async {
    closes++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SignalRenderer implements RTCVideoRenderer {
  @override
  MediaStream? srcObject;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SignalStream implements MediaStream {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SignalTrack implements MediaStreamTrack {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'concurrent ICE and offer create one peer, wait for remote SDP and only report connected after transport connects',
    () async {
      final socket = SignalSocket(), peer = SignalPeer();
      final creating = Completer<RTCPeerConnection>();
      var creations = 0, connected = 0;
      final controller = CallSessionController(
        callSocketService: socket,
        roomId: 'room',
        peerName: 'Peer',
        isCaller: false,
        isVideoCall: false,
        localRenderer: SignalRenderer(),
        remoteRenderer: SignalRenderer(),
        onStatusChanged: (_) {},
        onConnected: () => connected++,
        onRemoteEnd: (_) async {},
        peerConnectionFactory: (_) {
          creations++;
          return creating.future;
        },
      );
      controller.bindSocketListeners();
      void signal(Map<String, dynamic> value) =>
          socket.signals.add(CallSignalEvent(socketId: 'peer', signal: value));
      signal({'type': 'candidate', 'candidate': 'first', 'sdpMLineIndex': 0});
      signal({'type': 'offer', 'sdp': 'test offer'});
      signal({'type': 'candidate', 'candidate': 'second', 'sdpMLineIndex': 0});
      await pumpEventQueue();
      expect(creations, 1);
      creating.complete(peer);
      await pumpEventQueue();
      expect(creations, 1);
      expect(peer.events, [
        'remote:offer',
        'candidate',
        'local:answer',
        'candidate',
      ]);
      peer.onTrack?.call(
        RTCTrackEvent(streams: [SignalStream()], track: SignalTrack()),
      );
      expect(connected, 0);
      peer.onConnectionState?.call(
        RTCPeerConnectionState.RTCPeerConnectionStateConnected,
      );
      expect(connected, 1);
      await controller.dispose();
      await controller.dispose();
      expect(peer.closes, 1);
      await socket.signals.close();
    },
  );
}
