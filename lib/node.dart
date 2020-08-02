import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SystemMouseCursors;
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart' as hooks;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/root_store.dart';

part 'node.g.dart';

class Node = _Node with _$Node;

abstract class _Node with Store {
  String key;

  @observable
  String name;
  @observable
  double top;
  @observable
  double left;

  Set<NodeRef> inputs;
  @observable
  double width = 0;
  @observable
  double height = 0;

  @computed
  Offset get center => Offset(left + width / 2, top + height / 2);

  Layer data;

  @action
  void move(DragUpdateDetails d) {
    left += d.delta.dx;
    top += d.delta.dy;
  }

  @action
  void updateSize(BuildContext ctx) {
    final newWidth = ctx.size.width + _nodePadding * 2;
    final newHeight = ctx.size.height + _nodePadding * 2;
    if (newWidth != width || newHeight != height) {
      width = newWidth;
      height = newHeight;
    }
  }

  _Node(this.key, this.name, this.top, this.left, this.inputs, this.data);
}

class NodeRef {
  const NodeRef(this.key);
  final String key;

  Node get value => RootStore.instance.nodes[key];

  @override
  bool operator ==(dynamic other) {
    if (other is NodeRef) {
      return key == other.key;
    }
    return false;
  }

  @override
  int get hashCode => key.hashCode;
}

const _nodePadding = 18.0;
const _nodeBorderRadius = BorderRadius.all(Radius.circular(6.0));
const _nodeEdgeInsets = EdgeInsets.all(_nodePadding);

class NodeView extends hooks.HookWidget {
  const NodeView({this.node, Key key}) : super(key: key);
  final Node node;

  @override
  Widget build(BuildContext context) {
    final root = useRoot();

    return Observer(
      builder: (ctx) {
        return Positioned(
          top: node.top,
          left: node.left,
          child: MouseRegion(
            cursor: root.addingConnection.isNone()
                ? SystemMouseCursors.grab
                : SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (_) => root.isDragging = true,
              onPanEnd: (_) => root.isDragging = false,
              dragStartBehavior: DragStartBehavior.down,
              onTap: () {
                root.selectedNode = node;
                if (!root.addingConnection.isNone()) {
                  root.addConnection(node);
                }
              },
              onPanUpdate: node.move,
              child: NodeContainer(
                isSelected: root.selectedNode == node,
                child: LayoutBuilder(
                  builder: (ctx, box) {
                    SchedulerBinding.instance.addPostFrameCallback(
                      (_) => node.updateSize(ctx),
                    );
                    return Observer(
                      builder: (ctx) => Text(node.name),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class NodeContainer extends StatelessWidget {
  const NodeContainer({
    Key key,
    @required this.isSelected,
    @required this.child,
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
            color: isSelected ? Colors.blue[900] : Colors.black26,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(),
      ),
      child: child,
    );
  }
}
