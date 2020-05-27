import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neural_graph/arrow.dart';
import 'package:neural_graph/node.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/widgets/scrollable.dart';
import 'package:styled_widget/styled_widget.dart';

class GraphView extends HookWidget {
  @override
  Widget build(ctx) {
    final root = useRoot();

    return MultiScrollable(
      builder: (ctx, controller) {
        return MouseScrollListener(
          controller: controller,
          child: Observer(
            builder: (ctx) {
              return CustomScrollGestures(
                controller: controller,
                allowDrag: !root.isDragging,
                child: CustomPaint(
                  painter: ConnectionsPainter(root.nodes),
                  child: Stack(
                    children: root.nodes.entries.map((e) {
                      return NodeView(
                        node: e.value,
                        key: Key(e.key.toString()),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CustomScrollGestures extends HookWidget {
  const CustomScrollGestures({
    Key key,
    @required this.child,
    @required this.controller,
    this.initialSize = const Size(1500, 1000),
    this.allowDrag = true,
  }) : super(key: key);
  final Widget child;
  final MultiScrollController controller;
  final bool allowDrag;
  final Size initialSize;

  @override
  Widget build(ctx) {
    final prevPoint = useState(Offset(0, 0));
    final scale = useState(1.0);
    final size = useState(initialSize);
    final translateOffset = useState(Offset.zero);

    return LayoutBuilder(
      builder: (ctx, box) {
        // final center = Offset(box.maxWidth / 2, box.maxHeight / 2);
        // final fromCenter = prevPoint.value - center;
        final onScaleUpdate = (ScaleUpdateDetails d) {
          if (d.scale != 1) {
            scale.value = (d.scale).clamp(0.4, 2.5);
            size.value = Size(
              initialSize.width * scale.value,
              initialSize.height * scale.value,
            );

            translateOffset.value = (Offset(750, 500)) * (scale.value - 1);

            controller.horizontal.jumpTo(controller.horizontal.offset + 0.0001);
            controller.vertical.jumpTo(controller.vertical.offset + 0.0001);
          } else {
            controller.onDrag(d.localFocalPoint - prevPoint.value);
          }
          prevPoint.value = d.localFocalPoint;
        };

        return Container(
          height: max(size.value.height, box.maxHeight),
          width: max(size.value.width, box.maxWidth),
          color: Colors.white,
          child:
              child.translate(offset: translateOffset.value).scale(scale.value),
        )
            .scrollable(
              controller: controller.vertical,
              physics: NeverScrollableScrollPhysics(),
            )
            .scrollable(
              controller: controller.horizontal,
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
            )
            .gestures(
              onScaleStart: (details) =>
                  prevPoint.value = details.localFocalPoint,
              dragStartBehavior: DragStartBehavior.down,
              onScaleUpdate: allowDrag ? onScaleUpdate : null,
            );
      },
    );
  }
}

class MouseScrollListener extends StatefulWidget {
  MouseScrollListener({
    Key key,
    @required this.controller,
    @required this.child,
  }) : super(key: key);
  final MultiScrollController controller;
  final Widget child;

  @override
  _MouseScrollListenerState createState() => _MouseScrollListenerState();
}

class _MouseScrollListenerState extends State<MouseScrollListener> {
  final _focusNode = FocusNode();
  bool isShiftPressed = false;

  void _onPointerSignal(PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      if (isShiftPressed) {
        widget.controller.onDrag(Offset(-pointerSignal.scrollDelta.dy, 0));
      } else {
        widget.controller.onDrag(Offset(0, -pointerSignal.scrollDelta.dy));
      }
    }
  }

  void _onKey(RawKeyEvent event) =>
      setState(() => isShiftPressed = event.data.isShiftPressed);

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKey: _onKey,
      child: Listener(
        onPointerSignal: _onPointerSignal,
        child: widget.child,
      ),
    );
  }
}
