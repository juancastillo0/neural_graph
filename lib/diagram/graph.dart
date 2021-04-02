import 'dart:math' show Random;

import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/common/extensions.dart';
import 'package:neural_graph/diagram/connection.dart' show Connection, Port;
import 'package:neural_graph/diagram/graph_item.dart';
import 'package:neural_graph/diagram/node.dart' show Node, NodeData;
import 'package:neural_graph/graph_canvas/adding_node_state.dart';
import 'package:neural_graph/graph_canvas/store_graph_canvas.dart';
import 'package:uuid/uuid.dart';

class Graph<N extends NodeData> {
  static const _uuid = Uuid();
  factory Graph() {
    return Graph._(_uuid.v4());
  }

  Graph._(this.key) {
    reaction<Set<String>>(
      (r) => this.nodes.keys.toSet(),
      (keys) {
        this.selectedNodes.retainWhere(keys.contains);
      },
      equals: (keys, prevKeys) => keys!.difference(prevKeys!).isEmpty,
    );
  }

  final String key;

  final nodes = ObservableMap<String, Node<N>>();

  final selectedNodes = ObservableSet<String>();

  final graphCanvas = GraphCanvasStore();

  Node<N>? get selectedNode =>
      selectedNodes.isEmpty ? null : nodes[selectedNodes.last];

  void selectNode(Node<N> node, {bool selectMany = false}) {
    runInAction(() {
      if (!selectMany) {
        this.selectedNodes.clear();
      }
      this.selectedNodes.add(node.key);
      selectSingleItem(GraphItem.node(node));
      // if (!this.addingConnection.isNone()) {
      //   this.addConnection(node);
      // }
    });
  }

  final _isDragging = Observable(false);
  bool get isDragging => _isDragging.value;

  // ignore: avoid_positional_boolean_parameters
  void setIsDragging(bool value) {
    runInAction(() {
      _isDragging.value = value;
    });
  }

  final _addingConnection = Observable(AddingConnectionState<N>.none());
  AddingConnectionState<N> get addingConnection => _addingConnection.value;

  final _selectedConnection = Observable<Connection<N, N>?>(null);
  Connection<N, N>? get selectedConnection => _selectedConnection.value;

  final _selectedConnectionPoint = Observable<int?>(null);

  Computed<int?>? __selectedConnectionPointComp;
  int? get selectedConnectionPoint {
    __selectedConnectionPointComp ??= Computed(() {
      final _curr = _selectedConnectionPoint.value;
      if (_curr != null) {
        if (selectedConnection == null ||
            _curr >= selectedConnection!.innerPoints.length) {
          _selectedConnectionPoint.value = null;
        }
      }
      return _selectedConnectionPoint.value;
    });

    return __selectedConnectionPointComp!.value;
  }

  ReactionDisposer? pointDragDisposer;

  final selectedItems = ObservableSet<GraphItem<N>>();

  void deleteSelected() {
    runInAction(() {
      if (!this.addingConnection.isNone()) {
        this._addingConnection.value = AddingConnectionState<N>.none();
        return;
      }
      for (final item in selectedItems) {
        item.when(
          connection: (conn) {
            conn!.from.connections.remove(conn);
            conn.to.connections.remove(conn);
          },
          node: (node) {
            this.nodes.remove(node!.key);
          },
          connectionPoint: (connection, point) {
            connection!.innerPoints.removeAt(point!);
          },
        );
      }
      selectedItems.clear();
      // if (selectedConnectionPoint != null) {
      //   selectedConnection.innerPoints.removeAt(selectedConnectionPoint);
      //   return;
      // }
      // if (selectedNodes.isNotEmpty) {
      //   nodes.removeWhere((k, node) => selectedNodes.contains(k));

      //   // for (final node in nodes.values) {
      //   //   node.inputs.remove(nodeRef);
      //   // }
      //   selectedNodes.clear();
      // }
    });
  }

  void selectSingleItem(GraphItem<N> item) {
    runInAction(() {
      this.selectedItems.clear();
      this.selectedItems.add(item);
    });
  }

  void selectConnection(Connection<N, N> conn) {
    runInAction(() {
      _selectedConnection.value = conn;
      _selectedConnectionPoint.value = null;
      selectSingleItem(GraphItem.connection(conn));
    });
  }

  void selectConnectionPoint(Connection<N, N>? conn, int? index) {
    runInAction(() {
      _selectedConnection.value = conn;
      if (index == null) {
        pointDragDisposer?.call();
        _selectedConnectionPoint.value = null;
      } else {
        selectSingleItem(GraphItem.connectionPoint(conn, index));
        _selectedConnectionPoint.value = index;
        pointDragDisposer = reaction<Offset?>(
          (reaction) {
            if (selectedConnectionPoint != index) {
              reaction.dispose();
            }
            return graphCanvas.mousePosition;
          },
          (pos) => conn!.innerPoints[index] = pos,
        );
      }
    });
  }

  void addConnection(Port<N> port) {
    runInAction(() {
      _addingConnection.value = addingConnection.when(
        none: () {
          this.graphCanvas.mousePosition = port.offset;
          return AddingConnectionState.addedInput(port);
        },
        addedInput: (inputPort) {
          inputPort.addConnection(port);
          return const AddingConnectionState.none();
        },
      );
    });
  }

  Node<N> createNode(Offset offset, N Function(Node<N>) layer) {
    return runInAction(() {
      final newKey = random.generateKey();
      final newNode = Node<N>(
        key: newKey,
        offset: offset,
        graph: this,
        dataBuilder: layer,
      );

      nodes[newKey] = newNode;

      this.selectedNodes.clear();
      this.selectedNodes.add(newNode.key);
      return newNode;
    });
  }

  final random = Random();

  // static Graph<N> of<N extends NodeData>(BuildContext context) =>
  //     Provider.get<Graph<N>>(context) ??
  //     Provider.get<Graph>(context) as Graph<N>;
}

class Provider<T> extends InheritedWidget {
  final T data;

  const Provider({
    required this.data,
    required Widget child,
    Key? key,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(Provider<T> oldWidget) {
    return oldWidget.data != this.data;
  }

  static T? get<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider<T>>()?.data;
  }
}
