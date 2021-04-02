import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SystemMouseCursors;
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart' as hooks;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/diagram/connection.dart';
import 'package:neural_graph/diagram/graph.dart';

export 'package:neural_graph/diagram/connection.dart';

abstract class NodeData {
  Widget nodeView();

  Iterable<Port> get ports;
}

class Node<T extends NodeData> {
  final String key;
  final Graph<T> graph;

  Node({
    required this.key,
    required this.graph,
    required Offset offset,
    required T Function(Node<T>) dataBuilder,
  }) : _offset = Observable<Offset>(offset) {
    data = dataBuilder(this);
  }

  final Observable<Offset> _offset;
  Offset get offset => _offset.value;
  double get top => _offset.value.dy;
  double get left => _offset.value.dx;

  final _size = Observable(const Size(0, 0));
  double get width => _size.value.width;
  double get height => _size.value.height;

  Offset get center => Offset(left + width / 2, top + height / 2);

  Iterable<Connection<T, T>> inputs() {
    return this
        .data
        .ports
        .expand((port) => port.connections.cast<Connection<T, T>>())
        .where((conn) => conn.to.node == this);
  }

  Iterable<Connection<T, T>> outputs() {
    return this
        .data
        .ports
        .expand((port) => port.connections.cast<Connection<T, T>>())
        .where((conn) => conn.from.node == this);
  }

  late final T data;

  void move(Offset delta) {
    runInAction(() {
      _offset.value += delta;
    }, name: "move");
  }

  void updateSize(BuildContext ctx) {
    final newWidth = ctx.size!.width + _nodePadding * 2;
    final newHeight = ctx.size!.height + _nodePadding * 2;
    if (newWidth != width || newHeight != height) {
      runInAction(() {
        _size.value = Size(newWidth, newHeight);
      }, name: "updateSize");
    }
  }

  static Node<T>? fromJson<T extends NodeData>(Map<String, dynamic>? json) {
    return null;
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

// class NodeRef {
//   const NodeRef(this.key);
//   final String key;

//   Node get value => RootStore.instance.nodes[key];

//   @override
//   bool operator ==(dynamic other) {
//     if (other is NodeRef) {
//       return key == other.key;
//     }
//     return false;
//   }

//   @override
//   int get hashCode => key.hashCode;
// }

const _nodePadding = 2.0;
const _nodeBorderRadius = BorderRadius.all(Radius.circular(4.0));
const _nodeEdgeInsets = EdgeInsets.all(_nodePadding);

class NodeView extends hooks.HookWidget {
  const NodeView({
    required this.node,
    Key? key,
  }) : super(key: key);
  final Node node;

  @override
  Widget build(BuildContext context) {
    final graph = node.graph;

    return Observer(
      builder: (ctx) => Positioned(
        top: node.top,
        left: node.left,
        child: MouseRegion(
          cursor: graph.addingConnection.isNone()
              ? SystemMouseCursors.grab
              : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) => graph.setIsDragging(true),
            onPanEnd: (_) => graph.setIsDragging(false),
            dragStartBehavior: DragStartBehavior.down,
            onTap: () => graph.selectNode(node),
            onPanUpdate: (details) => node.move(details.delta),
            child: LayoutBuilder(
              builder: (ctx, box) {
                SchedulerBinding.instance!.addPostFrameCallback(
                  (_) => node.updateSize(ctx),
                );
                return node.data.nodeView();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class NodeContainer extends StatelessWidget {
  const NodeContainer({
    Key? key,
    required this.isSelected,
    required this.child,
  }) : super(key: key);

  final bool isSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _nodeEdgeInsets,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _nodeBorderRadius,
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            spreadRadius: 0.5,
            color: isSelected ? Colors.blue[900]! : Colors.black26,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(),
      ),
      child: child,
    );
  }
}
