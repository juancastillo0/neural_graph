import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/diagram/graph.dart';
import 'package:neural_graph/layers/convolutional.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/diagram/node.dart' show Node;

part 'root_store.g.dart';

class RootStore extends _RootStore with _$RootStore {
  static RootStore get instance => GetIt.instance.get<RootStore>();
}

final log = Logger();

abstract class _RootStore with Store {
  _RootStore() {
    final graph = Graph<Layer>();

    final node1 = graph.createNode(
      const Offset(1420, 920),
      (n) => Convolutional(n, name: "conv1"),
    );

    final node2 = graph.createNode(
      const Offset(20, 20),
      (n) => Convolutional(n, name: "conv2"),
    );

    (node2.data as Convolutional)
        .outPort
        .addConnection((node1.data as Convolutional).inPort);

    graph.selectedNodes.add(node1.key);

    this.graphs = ObservableMap.of({graph.key: graph});
    this.selectedGraph = graph;
  }

  @observable
  ObservableMap<String, Graph<Layer>> graphs;

  @observable
  Graph<Layer> selectedGraph;
}

RootStore useRoot() {
  return RootStore.instance;
}
