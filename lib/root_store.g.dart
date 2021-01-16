// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RootStore on _RootStore, Store {
  final _$graphsAtom = Atom(name: '_RootStore.graphs');

  @override
  ObservableMap<String, Graph<Layer>> get graphs {
    _$graphsAtom.reportRead();
    return super.graphs;
  }

  @override
  set graphs(ObservableMap<String, Graph<Layer>> value) {
    _$graphsAtom.reportWrite(value, super.graphs, () {
      super.graphs = value;
    });
  }

  final _$selectedGraphAtom = Atom(name: '_RootStore.selectedGraph');

  @override
  Graph<Layer> get selectedGraph {
    _$selectedGraphAtom.reportRead();
    return super.selectedGraph;
  }

  @override
  set selectedGraph(Graph<Layer> value) {
    _$selectedGraphAtom.reportWrite(value, super.selectedGraph, () {
      super.selectedGraph = value;
    });
  }

  @override
  String toString() {
    return '''
graphs: ${graphs},
selectedGraph: ${selectedGraph}
    ''';
  }
}
