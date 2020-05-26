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
  final _focusNode = FocusNode();

  @override
  Widget build(ctx) {
    final root = useRoot();

    return MultiScrollable(
      builder: (ctx, {verticalController, horizontalController}) {
        final _dragCanvas = (Offset delta) {
          final hp = horizontalController.position;
          final dx = (horizontalController.offset - delta.dx)
              .clamp(0, hp.maxScrollExtent);
          horizontalController.jumpTo(dx);

          final vp = verticalController.position;
          final dy = (verticalController.offset - delta.dy)
              .clamp(0, vp.maxScrollExtent);
          verticalController.jumpTo(dy);
        };

        return Observer(
          builder: (ctx) {
            bool isShiftPressed = false;
            return StatefulBuilder(
              builder: (context, setState) {
                return RawKeyboardListener(
                  autofocus: true,
                  focusNode: _focusNode,
                  onKey: (RawKeyEvent event) => setState(
                      () => isShiftPressed = event.data.isShiftPressed),
                  child: Listener(
                    onPointerSignal: (pointerSignal) {
                      if (pointerSignal is PointerScrollEvent) {
                        if (isShiftPressed) {
                          _dragCanvas(Offset(-pointerSignal.scrollDelta.dy, 0));
                        } else {
                          _dragCanvas(Offset(0, -pointerSignal.scrollDelta.dy));
                        }
                      }
                    },
                    child: KeyedSubtree(
                      key: Key("Canvas"),
                      child: Container(
                        height: 1000,
                        width: 1500,
                        color: Colors.white,
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
                      )
                          .scrollable(
                            controller: verticalController,
                            physics: NeverScrollableScrollPhysics(),
                          )
                          .scrollable(
                            controller: horizontalController,
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                          )
                          .gestures(
                            onPanUpdate: root.isDragging
                                ? null
                                : (d) => _dragCanvas(d.delta),
                          ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
