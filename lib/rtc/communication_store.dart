import 'dart:async';

import 'package:artemis/artemis.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/api.graphql.dart';
import 'package:gql_websocket_link/gql_websocket_link.dart';
import "package:web_socket_channel/web_socket_channel.dart";
import 'package:neural_graph/rtc/peer_connection.dart';
import 'package:neural_graph/rtc/peer_protocol.dart';

class CommunicationStore {
  CommunicationStore({
    required this.gqlClient,
    required this.userId,
  }) {
    remoteSignalStream =
        this.gqlClient.stream(SignalsSubscription()).asBroadcastStream();

    remoteSignalStream.listen((event) {
      if (event.hasErrors) {
        return;
      }
      final data = event.data!.signals;
      if (!peers.containsKey(data.peerId)) {
        _peerSignals.putIfAbsent(data.peerId, () => []).add(event);
      }
    });
  }
  final ArtemisClient gqlClient;

  final rooms = ObservableMap<String, Room>();
  final peers = ObservableMap<String, PeerConnectionState>();
  final _peerSignals =
      ObservableMap<String, List<GraphQLResponse<Signals$SubscriptionRoot>>>();
  final String? userId;

  // static const _headers = {
  //   "content-type": "application/json",
  //   "accept": "application/json",
  // };

  late final Stream<GraphQLResponse<Signals$SubscriptionRoot>>
      remoteSignalStream;

  static Future<CommunicationStore?> create(String url) async {
    try {
      final response =
          await ArtemisClient(url).execute(CreateSessionMutation());

      if (response.hasErrors) {
        return null;
      }
      final data = response.data!.createSessionId;
      final wsUrl = url.replaceAll(RegExp("https?://"), "ws://");
      final channel = WebSocketChannel.connect(
        Uri.parse("$wsUrl?token=${data.token}"),
      );

      final client = ArtemisClient.fromLink(
        WebSocketLink(null, channelGenerator: () => channel),
      );

      return CommunicationStore(
        gqlClient: client,
        userId: data.userId,
      );
    } catch (e, s) {
      print("CommunicationStore.create $e\n$s");
      return null;
    }
  }

  void sendMessageToRoom(Room room, String text) {
    if (!room.isInitialized) return;

    final now = DateTime.now();
    final message = RtcMessage(
      text: text,
      roomId: room.id,
      timestamp: now,
    );
    for (final peerId in room.users.value) {
      final peerConn = this.peers[peerId];

      if (peerConn != null && peerConn.canSendMessage) {
        peerConn.sendText(message);
      }
    }
    room.messages[now] = message;
  }

  Future<Room> subscribeToRoom(String roomId) async {
    if (this.rooms.containsKey(roomId)) {
      return this.rooms[roomId]!;
    }
    final _roomsQuery =
        RoomSubscription(variables: RoomArguments(roomId: roomId));

    Room? room;
    // ignore: cancel_subscriptions
    final _subscription = this.gqlClient.stream(_roomsQuery).listen((event) {
      if (event.hasErrors) {
        print(event.errors);
        print(event.errors!.map((e) => e.message).join());
        return unsubscribeFromRoom(roomId);
      }
      final remotePeers = event.data!.room.users.toSet();
      final newPeers = remotePeers.difference(room!.users.value);
      final disconnectedPeers = room.users.value.difference(remotePeers);

      room.users.value = remotePeers;

      for (final peerId in newPeers) {
        if (peerId == userId) {
          continue;
        }
        final protocol = GraphQlPeerSignalProtocol(
          peerId: peerId,
          client: gqlClient,
          signals: (() async* {
            yield* Stream.fromIterable(_peerSignals.remove(peerId) ?? []);
            yield* remoteSignalStream;
          })() as Stream<GraphQLResponse<Signals$SubscriptionRoot>>,
        );

        final peerConn = PeerConnectionState(
          protocol: protocol,
          isInitializer: peerId.compareTo(userId!) > 0,
          peerId: peerId,
          userId: userId,
        );

        this.peers[peerId] = peerConn;

        void _listener() {
          if (peerConn.canSendMessage) {
            peerConn.removeListener(_listener);
            room!._listenMessageStream(peerConn.messageStream);
            peerConn.sendTexts(room.messages.values);
          }
        }

        peerConn.addListener(_listener);
      }

      _tryRemovePeers(room, disconnectedPeers);
    });
    room = Room(roomId, _subscription);
    this.rooms[roomId] = room;
    return room;
  }

  void unsubscribeFromRoom(String roomId) {
    final room = this.rooms.remove(roomId);
    if (room == null) return;

    _tryRemovePeers(room, room.users.value);
    room.close();
  }

  void _tryRemovePeers(Room? room, Iterable<String> peerIds) {
    for (final peerId in peerIds) {
      final inOtherRoom = rooms.values.any(
        (_room) => _room != room && _room.users.value.contains(peerId),
      );
      if (!inOtherRoom) {
        final connection = this.peers.remove(peerId);
        connection?.close();
      }
    }
  }
}

class Room {
  final StreamSubscription<GraphQLResponse<Room$SubscriptionRoot>>
      _subscription;
  final List<StreamSubscription<RtcMessage>> _messagesSubscription = [];

  final users = ValueNotifier<Set<String>>({});
  final messages = ObservableMap<DateTime, RtcMessage>.splayTreeMapFrom({});
  final String id;

  bool get isInitialized => users.value.isNotEmpty;

  Room(this.id, this._subscription);

  void close() {
    _subscription.cancel();
    for (final subs in _messagesSubscription) {
      subs.cancel();
    }
  }

  void _listenMessageStream(Stream<RtcMessage> messageStream) {
    _messagesSubscription.add(messageStream.listen((event) {
      messages[event.timestamp] = event;
    }));
  }
}
