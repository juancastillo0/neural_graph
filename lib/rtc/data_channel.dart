import 'dart:core';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neural_graph/common/extensions.dart';
import 'package:neural_graph/rtc/async_result.dart';
import 'package:neural_graph/rtc/communication_store.dart';

class DataChannelSample extends StatefulWidget {
  const DataChannelSample({Key? key}) : super(key: key);

  @override
  _DataChannelSampleState createState() => _DataChannelSampleState();
}

class _DataChannelSampleState extends State<DataChannelSample> {
  late final TextEditingController urlController;
  AsyncResult<CommunicationStore, String> storeResult =
      const AsyncResult.idle();

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController(text: "http://localhost:8080/");
  }

  Future<void> initServerConnection() async {
    if (storeResult.isLoading) return;

    storeResult = const AsyncResult.loading();
    setState(() {});
    final _uri = Uri.tryParse(urlController.text);
    if (_uri != null) {
      final _store = await CommunicationStore.create(urlController.text);
      if (_store != null) {
        storeResult = AsyncResult.success(_store);
      } else {
        storeResult = const AsyncResult.error("Can't connect to server");
      }
    } else {
      storeResult = const AsyncResult.error("Invalid url");
    }
    setState(() {});
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  // void _makeCall(String peerId) async {
  //   if (_peerConnection != null) return;

  //   try {} catch (e) {
  //     print(e.toString());
  //   }
  //   if (!mounted) return;

  //   setState(() {
  //     _inCalling = true;
  //   });
  // }

  // void _hangUp() async {
  //   try {
  //     await _peerConnection.close();
  //     _peerConnection = null;
  //   } catch (e) {
  //     print(e.toString());
  //   }
  //   setState(() {
  //     _inCalling = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (!storeResult.isSuccess) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Connect to a signaling server"),
          TextField(
            controller: urlController,
            onChanged: (value) {
              urlController.value = urlController.value.copyWith(
                text: value.replaceAll(RegExp(r"\s"), ""),
              );
            },
          ),
          ElevatedButton(
            onPressed: initServerConnection,
            child: storeResult.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : const Text("Init Connection"),
          ),
          if (storeResult.isError) Text(storeResult.errorOrNull!)
        ],
      );
    } else {
      return RoomsView(store: storeResult.valueOrNull!);
    }
  }
}

class RoomsView extends StatefulWidget {
  final CommunicationStore store;

  const RoomsView({Key? key, required this.store}) : super(key: key);
  @override
  _RoomsViewState createState() => _RoomsViewState();
}

class _RoomsViewState extends State<RoomsView> {
  CommunicationStore get store => widget.store;

  final _rand = Random();
  late final TextEditingController roomController;
  final messageController = TextEditingController();
  Room? room;

  @override
  void initState() {
    super.initState();
    roomController = TextEditingController(text: _rand.generateKey(24));
  }

  Future<void> _joinRoom() async {
    final roomId = roomController.text;
    room = await this.store.subscribeToRoom(roomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (room == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: roomController,
            onChanged: (value) {
              roomController.value = roomController.value.copyWith(
                text: value.replaceAll(RegExp(r"\s"), ""),
              );
            },
          ),
          ElevatedButton(
            onPressed: _joinRoom,
            child: const Text("Join Room"),
          )
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Room Id"),
                Text(roomController.text),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Peers"),
                AnimatedBuilder(
                  animation: room!.users,
                  builder: (context, _) {
                    return Text(room!.users.value.length.toString());
                  },
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 200,
          child: Column(
            children: [
              Expanded(
                child: Observer(
                  builder: (context) {
                    return ListView(
                      children: [
                        ...room!.messages.values.map(
                          (msg) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(msg.text!),
                              Text(msg.timestamp.toIso8601String()),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (messageController.text.isEmpty) return;
                      store.sendMessageToRoom(room!, messageController.text);
                      messageController.clear();
                    },
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
