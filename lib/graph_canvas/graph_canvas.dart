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
import 'package:neural_graph/widgets/scrollable_extended.dart';
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
                          root.createNode(offset, constructor);
                        } else {
                          log.e("Wrong layer name ${details.data}");
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
