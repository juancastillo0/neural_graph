import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/diagram/graph.dart';
import 'package:neural_graph/layers/codegen_helper.dart';
import 'package:neural_graph/layers/convolutional_layer.dart';
import 'package:neural_graph/layers/generator.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/layers/neural_network.dart';
import 'package:neural_graph/tasks/tasks_store.dart';

part 'root_store.g.dart';

class RootStore extends _RootStore with _$RootStore {
  static RootStore get instance => GetIt.instance.get<RootStore>();
}

final log = Logger();

abstract class _RootStore with Store {
  final graph = Graph<Layer>();
  _RootStore() {
    final node1 = graph.createNode(
      const Offset(1420, 920),
      (n) => Convolutional(n, name: 'conv1'),
    );

    final node2 = graph.createNode(
      const Offset(20, 20),
      (n) => Convolutional(n, name: 'conv2'),
    );

    (node2.data as Convolutional)
        .outPort
        .addConnection((node1.data as Convolutional).inPort);

    graph.selectedNodes.add(node1.key);
  }

  late final ObservableMap<String, NeuralNetwork> networks =
      ObservableMap.of({graph.key: selectedNetwork});

  @observable
  late NeuralNetwork selectedNetwork = NeuralNetwork(graph: graph);

  @observable
  ProgrammingLanguage language = ProgrammingLanguage.python;

  @computed
  String get generatedSourceCode {
    return generateNeuralNetworkCode(
      this.selectedNetwork,
      this.language,
    );
  }

  final tasksStore = TasksStore();
}

RootStore useRoot() {
  return RootStore.instance;
}
