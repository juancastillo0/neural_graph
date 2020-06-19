import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neural_graph/arrow.dart';
import 'package:neural_graph/graph_canvas/adding_node_state.dart';
import 'package:neural_graph/graph_canvas/store_graph_canvas.dart';
import 'package:neural_graph/node.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/widgets/scrollable.dart';
import 'package:styled_widget/styled_widget.dart';

class GraphView extends HookWidget {
  @override
  Widget build(BuildContext ctx) {
    final root = useRoot();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Observer(
              builder: (ctx) {
                final isAdding = !root.addingConnection.isNone();
                return FlatButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: isAdding
                      ? () => root.addingConnection =
                          const AddingConnectionState.none()
                      : root.startAddingConnection,
                  color: isAdding ? Colors.black12 : null,
                  label: const Text("Connection"),
                );
              },
            ),
            Observer(
              builder: (ctx) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Scale: "),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      root.graphCanvas.scale -= 0.1;
                    },
                  ),
                  Text(root.graphCanvas.scale.toStringAsPrecision(2)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      root.graphCanvas.scale += 0.1;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: MultiScrollable(
            setScale: (s) => root.graphCanvas.scale = s,
            builder: (ctx, controller) {
              return MouseScrollListener(
                controller: controller,
                child: Observer(
                  builder: (ctx) {
                    return CustomScrollGestures(
                      controller: controller,
                      allowDrag: !root.isDragging,
                      child: DragTarget<String>( 
                        onAcceptWithDetails: (details) {
                          final offset =
                              controller.toCanvasOffset(details.offset);
                          if (details.data == "Convolutional") {
                            root.createNode(offset);
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Observer(
                            builder: (ctx) {
                              return MouseRegion(
                                onHover: root.addingConnection.isNone()
                                    ? null
                                    : (hoverEvent) {
                                        root.graphCanvas.mousePosition =
                                            controller.toCanvasOffset(
                                                hoverEvent.position);
                                      },
                                child: CustomPaint(
                                  painter: ConnectionsPainter(
                                    root.nodes,
                                    root.addingConnection,
                                    root.graphCanvas.mousePosition,
                                  ),
                                  child: Observer(
                                    key: const Key("nodes"),
                                    builder: (ctx) => Stack(
                                      children: root.nodes.entries.map(
                                        (e) {
                                          return NodeView(
                                            node: e.value,
                                            key: Key(e.key.toString()),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CustomScrollGestures extends HookWidget {
  const CustomScrollGestures({
    Key key,
    @required this.child,
    @required this.controller,
    this.allowDrag = true,
  }) : super(key: key);
  final Widget child;
  final MultiScrollController controller;
  final bool allowDrag;

  @override
  Widget build(BuildContext ctx) {
    final prevPoint = useState(const Offset(0, 0));
    final graphCanvas = useRoot().graphCanvas;

    return LayoutBuilder(
      builder: (ctx, box) {
        // final center = Offset(box.maxWidth / 2, box.maxHeight / 2);
        // final fromCenter = prevPoint.value - center;
        void onScaleUpdate(ScaleUpdateDetails d) {
          if (d.scale != 1) {
            controller.onScale(d.scale);
          } else {
            controller.onDrag(d.localFocalPoint - prevPoint.value);
            prevPoint.value = d.localFocalPoint;
          }
        }

        return Observer(
          builder: (ctx) {
            final _height = graphCanvas.size.height * graphCanvas.scale;
            final _width = graphCanvas.size.width * graphCanvas.scale;
            return Container(
              height: max(_height, box.maxHeight),
              width: max(_width, box.maxWidth),
              color: Colors.white,
              child: child
                  .translate(offset: graphCanvas.translateOffset)
                  .scale(graphCanvas.scale),
            );
          },
        )
            .scrollable(
              controller: controller.vertical,
              physics: const NeverScrollableScrollPhysics(),
            )
            .scrollable(
              controller: controller.horizontal,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
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
  const MouseScrollListener({
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
  bool isCtrlPressed = false;
  GraphCanvasStore graphCanvas = RootStore.instance.graphCanvas;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      if (isCtrlPressed) {
        final newScale = graphCanvas.scale - pointerSignal.scrollDelta.dy / 400;
        widget.controller.onScale(newScale);
      } else if (isShiftPressed) {
        widget.controller.onDrag(Offset(-pointerSignal.scrollDelta.dy, 0));
      } else {
        widget.controller.onDrag(Offset(0, -pointerSignal.scrollDelta.dy));
      }
    }
  }

  void _onKey(RawKeyEvent event) {
    setState(() {
      isShiftPressed = event.data.isShiftPressed;
      isCtrlPressed = event.data.isControlPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _focusNode.requestFocus(),
      onExit: (_) => _focusNode.unfocus(
          disposition: UnfocusDisposition.previouslyFocusedChild),
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: _focusNode,
        onKey: _onKey,
        child: Listener(
          onPointerSignal: _onPointerSignal,
          child: widget.child,
        ),
      ),
    );
  }
}
