import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:neural_graph/rtc/peer_connection.dart';
import 'package:neural_graph/rtc/peer_protocol.dart';

import 'package:neural_graph/rtc/signal.model.dart';

class DataChannelSample extends StatefulWidget {
  static String tag = 'data_channel_sample';

  @override
  _DataChannelSampleState createState() => _DataChannelSampleState();
}

class _DataChannelSampleState extends State<DataChannelSample> {
  PeerConnectionState _peerConnection;
  bool _inCalling = false;
  String peerId;
  String userId;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    if (_peerConnection != null) return;

    try {
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

      final connection = await createPeerConnection(
        configuration,
        loopbackConstraints,
      );

      final offerSdpConstraints = <String, dynamic>{
        'mandatory': {
          'OfferToReceiveAudio': false,
          'OfferToReceiveVideo': false,
        },
        'optional': [],
      };

      final protocol = GraphQlPeerSignalProtocol(
        peerId: peerId,
        userId: userId,
        uri: Uri.parse("http://localhost:8080/"),
      ).map<RTCSignal>(
        (s) => RTCSignal.fromJson(jsonDecode(s) as Map<String, dynamic>),
        (s) => jsonEncode(s.toJson()),
      );

      _peerConnection = PeerConnectionState(
        protocol: protocol,
        connection: connection,
        offerSdpConstraints: offerSdpConstraints,
        isInitializer: peerId.compareTo(userId) > 0,
        peerId: peerId,
      );
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  void _hangUp() async {
    try {
      await _peerConnection.close();
      _peerConnection = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Channel Test'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              child: _inCalling
                  ? Text(_peerConnection.sdp)
                  : Text('data channel test'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
