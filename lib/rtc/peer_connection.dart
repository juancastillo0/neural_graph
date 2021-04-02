import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:neural_graph/rtc/peer_protocol.dart';

import 'package:neural_graph/rtc/signal.model.dart';

class PeerConnectionState extends ChangeNotifier {
  PeerConnectionState({
    required SingalProtocol<String> protocol,
    required this.peerId,
    required this.userId,
    this.offerSdpConstraints = const <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': false,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    },
    required this.isInitializer,
    RTCDataChannelInit? dataChannelConfig,
  }) : this.protocol = protocol.map<RTCSignal?>(
          (s) => RTCSignal.fromJson(jsonDecode(s) as Map<String, dynamic>),
          (s) => jsonEncode(s!.toJson()),
        ) {
    this._remoteSubscription =
        this.protocol.remoteSignalStream.listen(_onSignal);

    _createConnection().then((_) {
      if (isInitializer) {
        dataChannelConfig ??= RTCDataChannelInit()
          ..id = 1
          ..ordered = true
          ..maxRetransmitTime = -1
          ..maxRetransmits = -1
          ..protocol = 'sctp'
          ..negotiated = false;

        connection!
            .createDataChannel('defaultDataChannel', dataChannelConfig!)
            .then(_onDataChannel);
      }
      connectionCompleter.complete(connection);
    });
  }

  Future<void> _createConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ]
    };

    final loopbackConstraints = <String, dynamic>{
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };

    connection = await createPeerConnection(
      configuration,
      loopbackConstraints,
    );

    connection!.onSignalingState = _onSignalingState;
    connection!.onIceGatheringState = _onIceGatheringState;
    connection!.onIceConnectionState = _onIceConnectionState;
    connection!.onConnectionState = _onConnectionState;
    connection!.onIceCandidate = _onIceCandidate;
    connection!.onRenegotiationNeeded = _onRenegotiationNeeded;
    connection!.onDataChannel = _onDataChannel;
  }

  final SingalProtocol<RTCSignal?> protocol;
  StreamSubscription<RTCSignal?>? _remoteSubscription;
  final String peerId;
  final String? userId;

  bool _initialRenegotiation = false;
  final bool isInitializer;
  final connectionCompleter = Completer<RTCPeerConnection>();
  RTCPeerConnection? connection;
  final Map<String, dynamic> offerSdpConstraints;

  final dataChannelCompleter = Completer<RTCDataChannel>();
  RTCDataChannel? dataChannel;
  final _messageStreamController = StreamController<RtcMessage>.broadcast();
  Stream<RtcMessage> get messageStream => _messageStreamController.stream;
  bool get canSendMessage =>
      dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen;

  void _log(Object data) {
    final now = DateTime.now();
    print(
        "$userId | ${now.hour}:${now.minute}:${now.second}:${now.millisecond} | $data");
  }

  Future<void> _onSignal(RTCSignal? signal) async {
    _log("_onSignal ${signal!.toJson()}");
    try {
      await connectionCompleter.future;
      signal.when(
        answer: (answer) async {
          await this
              .connection!
              .setRemoteDescription(RTCSessionDescription(answer, "answer"));
        },
        offer: (offer) async {
          await this.connection!.setRemoteDescription(
                RTCSessionDescription(offer, "offer"),
              );
          final answer =
              await this.connection!.createAnswer(offerSdpConstraints);
          // this.sdp = answer.sdp;
          await this.connection!.setLocalDescription(answer);

          this._sendSignal(RTCSignal.answer(answer.sdp));
        },
        candidate: (candidate) async {
          await this.connection!.addCandidate(candidate);
        },
      );
    } catch (e, s) {
      print("_onSignal error ${signal.toJson()} \n$e\n$s");
    }
  }

  void _onSignalingState(RTCSignalingState state) {
    _log("RTCSignalingState $state");
    notifyListeners();
  }

  void _onConnectionState(RTCPeerConnectionState state) {
    _log("RTCPeerConnectionState $state");
    notifyListeners();
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    _log("RTCIceGatheringState $state");
    notifyListeners();
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    _log("RTCIceConnectionState $state");
    notifyListeners();
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    _log('_onIceCandidate: ${candidate?.toMap()}');
    // connection.addCandidate(candidate);
    if (candidate == null) {
      print('onIceCandidate: complete!');
      return;
    }

    _sendSignal(RTCSignal.candidate(candidate));
  }

  Future<bool?> _sendSignal(RTCSignal signal) {
    _log('protocol.sendSignal ${signal.toJson()}');
    return protocol.sendSignal(signal);
  }

  void _onRenegotiationNeeded() {
    _log('_onRenegotiationNeeded');
    _createAndSendOffer();

    notifyListeners();
  }

  void _onDataChannelState(RTCDataChannelState? state) {
    _log("RTCDataChannelState $state");
    notifyListeners();
  }

  Future<void> _createAndSendOffer() async {
    final description = await connection!.createOffer(offerSdpConstraints);
    // this.sdp = description.sdp;
    await connection!.setLocalDescription(description);

    _sendSignal(RTCSignal.offer(description.sdp));
  }

  /// Send some sample messages and handle incoming messages.
  void _onDataChannel(RTCDataChannel _dataChannel) {
    if (dataChannelCompleter.isCompleted) return;

    _log("_onDataChannel");
    this.dataChannel = _dataChannel;
    dataChannelCompleter.complete(dataChannel);

    _onDataChannelState(dataChannel!.state);
    dataChannel!.onDataChannelState = _onDataChannelState;
    dataChannel!.onMessage = (message) {
      _log("messageStream");
      _log("messageStream ${message.text}");

      if (message.type == MessageType.text) {
        final _payload = jsonDecode(message.text) as List;
        _payload.forEach(
          (p) => _messageStreamController.add(
            RtcMessage.fromJson(p as Map<String, dynamic>),
          ),
        );
      } else {
        // do something with message.binary

      }
    };

    dataChannel!.messageStream.listen((event) {
      _log("messageStreamListen");
      _log("messageStreamListen ${event.text}");
    });

    // messageStream = dataChannel.messageStream.expand().asBroadcastStream();

    notifyListeners();
  }

  Future<void> sendText(RtcMessage message) async {
    _log("sendText ${message.toJson()}");
    return sendTexts([message]);
  }

  Future<void> sendTexts(Iterable<RtcMessage> messages) async {
    if (messages.isEmpty) return;
    try {
      return dataChannel!.send(
        RTCDataChannelMessage(
          jsonEncode(messages.map((m) => m.toJson()).toList()),
        ),
      );
    } catch (e, s) {
      print("sendTexts error $e\n$s");
    }
  }

  Future<void> close() async {
    protocol.dispose();
    _remoteSubscription?.cancel();
    dataChannel?.close();
    connection?.close();
    _messageStreamController.close();
  }
}

class RtcMessage {
  final String? text;
  final String? roomId;
  final DateTime timestamp;

  const RtcMessage({
    required this.text,
    required this.roomId,
    required this.timestamp,
  });

  static RtcMessage fromJson(Map<String, dynamic> map) {
    return RtcMessage(
      text: map['text'] as String?,
      roomId: map['roomId'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "roomId": roomId,
      "timestamp": timestamp.toIso8601String(),
    };
  }
}
