import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/graph_canvas/adding_node_state.dart';
import 'package:neural_graph/graph_canvas/store_graph_canvas.dart';
import 'package:neural_graph/layers/convolutional.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/node.dart';

part 'root_store.g.dart';

class RootStore extends _RootStore with _$RootStore {
  static RootStore get instance => GetIt.instance.get<RootStore>();
}

final logger = Logger();

final _charsKey =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-0123456789'
        .split("");

abstract class _RootStore with Store {
  _RootStore() {
    final node1 = Node('1', "conv1", 100, 300, {}, Convolutional());
    nodes = ObservableMap.of({
      '1': node1,
      '2': Node('2', "conv2", 20, 20, {const NodeRef('1')}, Convolutional()),
    });
    selectedNode = node1;
  }

  final random = Random();

  @observable
  ObservableMap<String, Node> nodes;

  @observable
  bool isDragging = false;

  @observable
  AddingConnectionState addingConnection = const AddingConnectionState.none();

  @observable
  Node selectedNode;

  @action
  void deleteSelected() {
    if (selectedNode != null) {
      final nodeRef = NodeRef(selectedNode.key);
      nodes.remove(selectedNode.key);

      for (final node in nodes.values) {
        node.inputs.remove(nodeRef);
      }
      selectedNode = nodes.values.first;
    }
  }

  @action
  void startAddingConnection() {
    addingConnection = const AddingConnectionState.adding();
  }

  @action
  void addConnection(Node node) {
    addingConnection = addingConnection.when(
      none: () => addingConnection,
      adding: () => AddingConnectionState.addedInput(node),
      addedInput: (inputNode) {
        node.inputs.add(NodeRef(inputNode.key));
        return const AddingConnectionState.none();
      },
    );
  }

  @observable
  GraphCanvasStore graphCanvas = GraphCanvasStore();

  @action
  void createNode(Offset offset, Layer layer) {
    final newKey = _generateKey();
    final newNode = Node(newKey, "", offset.dy, offset.dx, {}, layer);
    nodes[newKey] = newNode;
    selectedNode = newNode;
  }

  String _generateKey([int length = 7]) {
    return Iterable<int>.generate(length).map((_) {
      final _index = (random.nextDouble() * _charsKey.length).floor();
      return _charsKey[_index];
    }).join("");
  }
}

RootStore useRoot() {
  return RootStore.instance;
}
