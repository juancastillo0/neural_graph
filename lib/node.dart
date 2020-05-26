import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart' as hooks;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/root_store.dart';
import 'package:styled_widget/styled_widget.dart';

part 'node.g.dart';

class Node = _Node with _$Node;

abstract class _Node with Store {
  @observable
  String name;
  @observable
  double top;
  @observable
  double left;

  Set<int> inputs;
  @observable
  double width = 0;
  @observable
  double height = 0;

  @computed
  Offset get center => Offset(left + width / 2, top + height / 2);

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

  _Node(this.name, this.top, this.left, this.inputs);
}

const _nodePadding = 18.0;
const _nodeBorderRadius = const BorderRadius.all(const Radius.circular(6.0));
const _nodeEdgeInsets = const EdgeInsets.all(_nodePadding);

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
          child: Container(
            padding: _nodeEdgeInsets,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _nodeBorderRadius,
              border: Border.all(width: 1),
            ),
            child: LayoutBuilder(
              builder: (ctx, box) {
                SchedulerBinding.instance
                    .addPostFrameCallback((_) => node.updateSize(ctx));

                return Text(node.name);
              },
            ),
          ).gestures(
            onPanDown: (_) => root.isDragging = true,
            onPanEnd: (_) => root.isDragging = false,
            dragStartBehavior: DragStartBehavior.down,
            onPanUpdate: node.move,
            behavior: HitTestBehavior.opaque,
          ),
        );
      },
    );
  }
}
