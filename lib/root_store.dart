import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/graph_canvas/store_graph_canvas.dart';
import 'package:neural_graph/layers/convolutional.dart';
import 'package:neural_graph/node.dart';

part 'root_store.g.dart';

class RootStore extends _RootStore with _$RootStore {
  static RootStore get instance => GetIt.instance.get<RootStore>();
}

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
  Node selectedNode;

  @observable
  GraphCanvasStore graphCanvas = GraphCanvasStore();

  @action
  void createNode(Offset offset) {
    final newKey = _generateKey();
    nodes[newKey] = Node(newKey, "", offset.dy, offset.dx, {}, Convolutional());
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
