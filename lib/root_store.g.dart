// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RootStore on _RootStore, Store {
  final _$nodesAtom = Atom(name: '_RootStore.nodes');

  @override
  ObservableMap<String, Node> get nodes {
    _$nodesAtom.reportRead();
    return super.nodes;
  }

  @override
  set nodes(ObservableMap<String, Node> value) {
    _$nodesAtom.reportWrite(value, super.nodes, () {
      super.nodes = value;
    });
  }

  final _$isDraggingAtom = Atom(name: '_RootStore.isDragging');

  @override
  bool get isDragging {
    _$isDraggingAtom.reportRead();
    return super.isDragging;
  }

  @override
  set isDragging(bool value) {
    _$isDraggingAtom.reportWrite(value, super.isDragging, () {
      super.isDragging = value;
    });
  }

  final _$addingConnectionAtom = Atom(name: '_RootStore.addingConnection');

  @override
  AddingConnectionState get addingConnection {
    _$addingConnectionAtom.reportRead();
    return super.addingConnection;
  }

  @override
  set addingConnection(AddingConnectionState value) {
    _$addingConnectionAtom.reportWrite(value, super.addingConnection, () {
      super.addingConnection = value;
    });
  }

  final _$selectedNodeAtom = Atom(name: '_RootStore.selectedNode');

  @override
  Node get selectedNode {
    _$selectedNodeAtom.reportRead();
    return super.selectedNode;
  }

  @override
  set selectedNode(Node value) {
    _$selectedNodeAtom.reportWrite(value, super.selectedNode, () {
      super.selectedNode = value;
    });
  }

  final _$graphCanvasAtom = Atom(name: '_RootStore.graphCanvas');

  @override
  GraphCanvasStore get graphCanvas {
    _$graphCanvasAtom.reportRead();
    return super.graphCanvas;
  }

  @override
  set graphCanvas(GraphCanvasStore value) {
    _$graphCanvasAtom.reportWrite(value, super.graphCanvas, () {
      super.graphCanvas = value;
    });
  }

  final _$_RootStoreActionController = ActionController(name: '_RootStore');

  @override
  void deleteSelected() {
    final _$actionInfo = _$_RootStoreActionController.startAction(
        name: '_RootStore.deleteSelected');
    try {
      return super.deleteSelected();
    } finally {
      _$_RootStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void startAddingConnection() {
    final _$actionInfo = _$_RootStoreActionController.startAction(
        name: '_RootStore.startAddingConnection');
    try {
      return super.startAddingConnection();
    } finally {
      _$_RootStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addConnection(Node node) {
    final _$actionInfo = _$_RootStoreActionController.startAction(
        name: '_RootStore.addConnection');
    try {
      return super.addConnection(node);
    } finally {
      _$_RootStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void createNode(Offset offset, Layer Function(Node) layer) {
    final _$actionInfo =
        _$_RootStoreActionController.startAction(name: '_RootStore.createNode');
    try {
      return super.createNode(offset, layer);
    } finally {
      _$_RootStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
nodes: ${nodes},
isDragging: ${isDragging},
addingConnection: ${addingConnection},
selectedNode: ${selectedNode},
graphCanvas: ${graphCanvas}
    ''';
  }
}
