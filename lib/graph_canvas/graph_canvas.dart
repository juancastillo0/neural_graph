import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neural_graph/arrow.dart';
import 'package:neural_graph/graph_canvas/adding_node_state.dart';
import 'package:neural_graph/graph_canvas/store_graph_canvas.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/node.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/widgets/scrollable.dart';
import 'package:styled_widget/styled_widget.dart';

class GraphView extends HookWidget {
  @override
  Widget build(BuildContext ctx) {
    final root = useRoot();
    final graphCanvas = root.graphCanvas;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Observer(
              builder: (ctx) {
                return Text(graphCanvas.mousePosition.toString());
              },
            ),
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
                      graphCanvas.scale -= 0.1;
                    },
                  ),
                  Text(
                    graphCanvas.scale.toStringAsPrecision(2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      graphCanvas.scale += 0.1;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const Expanded(
          child: CanvasView(),
        ),
      ],
    );
  }
}

class CanvasView extends HookWidget {
  const CanvasView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    final root = useRoot();
    final graphCanvas = root.graphCanvas;

    return MultiScrollable(
        setScale: (s) => root.graphCanvas.scale = s,
        builder: (ctx, controller) {
          graphCanvas.controller = controller;

          return MouseScrollListener(
            controller: controller,
            child: Observer(builder: (ctx) {
              return CustomScrollGestures(
                controller: controller,
                allowDrag: !root.isDragging,
                child: Observer(
                  builder: (context) => SizedBox(
                    width: graphCanvas.size.width,
                    height: graphCanvas.size.height,
                    child: DragTarget<String>(
                      onAcceptWithDetails: (details) {
                        final offset =
                            graphCanvas.toCanvasOffset(details.offset);
                        final constructor =
                            Layer.layerConstructors[details.data];
                        if (constructor != null) {
                          root.createNode(offset, constructor());
                        } else {
                          logger.e("Wrong layer name ${details.data}");
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Observer(
                          builder: (ctx) {
                            return MouseRegion(
                              onHover: root.addingConnection.isAddedInput()
                                  ? (hoverEvent) {
                                      graphCanvas.mousePosition = graphCanvas
                                          .toCanvasOffset(hoverEvent.position);
                                    }
                                  : null,
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
                  ),
                ),
              );
            }),
          );
        });
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
    final graphCanvas = useRoot().graphCanvas;
    final prevPoint = useState(const Offset(0, 0));
    final initScale = useState(graphCanvas.scale);

    return LayoutBuilder(
      builder: (ctx, box) {
        void onScaleUpdate(ScaleUpdateDetails d) {
          if (d.scale != 1) {
            // print(
            //     "graphCanvas.toCanvasOffset(d.focalPoint) ${graphCanvas.toCanvasOffset2(d.focalPoint)}");
            // print(
            //     "graphCanvas.toCanvasOffset(prevPoint.value) ${graphCanvas.toCanvasOffset2(prevPoint.value)}");
            final _p = graphCanvas.toCanvasOffset(prevPoint.value);
            final _prev = graphCanvas.scale;
            controller.onScale(d.scale * initScale.value);
            final _p2 = graphCanvas.toCanvasOffset(prevPoint.value);
            print("$_p $_p2");
            final center = Offset(box.maxWidth / 2, box.maxHeight / 2);
            final fromCenter =
                (prevPoint.value - center) * _prev / graphCanvas.scale;
            controller.onDrag((_p2 - _p) * graphCanvas.scale);
            prevPoint.value = d.localFocalPoint;
          } else {
            controller.onDrag(d.localFocalPoint - prevPoint.value);
            prevPoint.value = d.localFocalPoint;
          }
        }

        return GestureDetector(
          onScaleStart: (details) {
            initScale.value = graphCanvas.scale;
            prevPoint.value = details.localFocalPoint;
          },
          dragStartBehavior: DragStartBehavior.down,
          onScaleUpdate: allowDrag ? onScaleUpdate : null,
          child: SingleChildScrollView(
            controller: controller.horizontal,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SingleChildScrollView(
              controller: controller.vertical,
              physics: const NeverScrollableScrollPhysics(),
              child: Observer(
                builder: (ctx) {
                  final multiplier = graphCanvas.scale;
                  final _height = graphCanvas.size.height * multiplier;
                  final _width = graphCanvas.size.width * multiplier;

                  return SizedBox(
                    height: _height,
                    width: _width,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: 0.0,
                        minHeight: 0.0,
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: child
                            .scale(graphCanvas.scale)
                            .translate(offset: graphCanvas.translateOffset),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
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
