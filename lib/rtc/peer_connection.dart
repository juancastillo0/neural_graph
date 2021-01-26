import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:neural_graph/rtc/peer_protocol.dart';

import 'package:neural_graph/rtc/signal.model.dart';

class PeerConnectionState extends ChangeNotifier {
  PeerConnectionState({
    @required this.protocol,
    @required this.connection,
    @required this.peerId,
    @required this.offerSdpConstraints,
    @required bool isInitializer,
    RTCDataChannelInit dataChannelConfig,
  }) {
    connection.onSignalingState = _onSignalingState;
    connection.onIceGatheringState = _onIceGatheringState;
    connection.onIceConnectionState = _onIceConnectionState;
    connection.onIceCandidate = _onCandidate;
    connection.onRenegotiationNeeded = _onRenegotiationNeeded;
    connection.onConnectionState = _onConnectionState;

    dataChannelConfig ??= RTCDataChannelInit()
      ..id = 1
      ..ordered = true
      ..maxRetransmitTime = -1
      ..maxRetransmits = -1
      ..protocol = 'sctp'
      ..negotiated = false;

    connection.onDataChannel = _onDataChannel;
    connection.createDataChannel('dataChannel', dataChannelConfig);

    this._remoteSubscription =
        protocol.remoteSignalStream.listen(this._onSignal);

    if (isInitializer) {
      _createAndSendOffer();
    }
  }

  Future<void> _createAndSendOffer() async {
    final description = await connection.createOffer(offerSdpConstraints);
    this.sdp = description.sdp;
    await connection.setLocalDescription(description);

    protocol.sendSignal(RTCSignal.offer(description.sdp));
    //change for loopback.
    //description.type = 'answer';
    //_peerConnection.setRemoteDescription(description);
  }

  final SingalProtocol<RTCSignal> protocol;
  final RTCPeerConnection connection;
  final String peerId;
  final Map<String, dynamic> offerSdpConstraints;
  String sdp;
  RTCDataChannel dataChannel;
  StreamSubscription<RTCSignal> _remoteSubscription;

  void _onSignal(RTCSignal signal) {
    signal.when(
      answer: (answer) async {
        await this
            .connection
            .setRemoteDescription(RTCSessionDescription(answer, "answer"));
      },
      offer: (offer) async {
        await this.connection.setRemoteDescription(
              RTCSessionDescription(offer, "offer"),
            );
        final answer = await this.connection.createAnswer();
        this.sdp = answer.sdp;
        await this.connection.setLocalDescription(answer);

        this.protocol.sendSignal(RTCSignal.answer(answer.sdp));
      },
      candidate: (candidate) async {
        await this.connection.addCandidate(candidate);
      },
    );
  }

  void _onSignalingState(RTCSignalingState state) {
    print("RTCSignalingState $state");
    notifyListeners();
  }

  void _onConnectionState(RTCPeerConnectionState state) {
    print("RTCPeerConnectionState $state");
    notifyListeners();
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    print("RTCIceGatheringState $state");
    notifyListeners();
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    print("RTCIceConnectionState $state");
    notifyListeners();
  }

  void _onCandidate(RTCIceCandidate candidate) {
    print('onCandidate: ${candidate.candidate}');
    connection.addCandidate(candidate);

    protocol.sendSignal(RTCSignal.candidate(candidate));
  }

  void _onRenegotiationNeeded() {
    print('RenegotiationNeeded');
    _createAndSendOffer();
  }

  /// Send some sample messages and handle incoming messages.
  void _onDataChannel(RTCDataChannel _dataChannel) {
    this.dataChannel = _dataChannel;
    // or alternatively:
    dataChannel.messageStream.listen((message) {
      if (message.type == MessageType.text) {
        print(message.text);
      } else {
        // do something with message.binary
      }
    });

    dataChannel.send(RTCDataChannelMessage('Hello! $peerId'));
    notifyListeners();
  }

  Future<void> close() async {
    protocol.dispose();
    await _remoteSubscription.cancel();
    await dataChannel.close();
    await connection.close();
  }
}