import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/diagram/graph.dart';
import 'package:neural_graph/diagram/node.dart';
import 'package:neural_graph/graph_canvas/adding_node_state.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/common/extensions.dart';

class Connection<NF extends NodeData, NT extends NodeData> {
  final Port<NF> from;
  final Port<NT> to;

  NF get fromData => from.node.data;
  NT get toData => to.node.data;

  final ObservableList<Offset?> innerPoints = ObservableList<Offset>();

  Connection(this.from, this.to);

  static Connection<NF, NT>? fromJson<NF extends NodeData, NT extends NodeData>(
      Map<String, dynamic>? map) {
    return null;
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

class Port<N extends NodeData> {
  final Node<N> node;
  final connections = ObservableList<Connection<N, N>>();

  N? get firstFromData =>
      connections.isEmpty ? null : connections.first.from.node.data;

  final localOffset = ValueNotifier(const Offset(0, 0));
  Offset get offset => node.offset + localOffset.value;

  Port(this.node);

  @action
  void addConnection(Port<N> other) {
    final conn = Connection(this, other);
    this.connections.add(conn);
    other.connections.add(conn);
  }

  void onBuild(BuildContext context) {
    Future.delayed(Duration.zero, () {
      localOffset.value = node.graph.graphCanvas
              .toCanvasOffset(context.globalPaintBounds!.center) -
          node.offset;
    });
  }
}

class PortView<N extends NodeData> extends StatelessWidget {
  final Widget child;
  final Port<N> port;
  final bool canBeStart;
  final bool Function(Port<N>) canBeEnd;

  static bool defaultCanBeEnd(Port _) => false;

  const PortView({
    Key? key,
    required this.port,
    required this.child,
    this.canBeStart = false,
    this.canBeEnd = defaultCanBeEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final graph = port.node.graph;
    port.onBuild(context);

    return Observer(builder: (context) {
      final _canBeEnd = graph.addingConnection.maybeWhen(
        addedInput: (n) => canBeEnd(n),
        orElse: () => false,
      );
      final isTapable =
          canBeStart && graph.addingConnection.isNone() || _canBeEnd;

      return MouseRegion(
        cursor:
            isTapable ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          behavior: HitTestBehavior.opaque,
          onPanStart: canBeStart
              ? (_) {
                  graph.addConnection(port);
                }
              : null,
          onTap: _canBeEnd
              ? () {
                  graph.addConnection(port);
                }
              : null,
          child: child,
        ),
      );
    });
  }
}
