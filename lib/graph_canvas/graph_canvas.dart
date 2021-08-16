import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neural_graph/arrow.dart';
import 'package:neural_graph/diagram/graph.dart';
import 'package:neural_graph/diagram/node.dart';
import 'package:neural_graph/gestured_canvas/gestured_canvas.dart';
import 'package:neural_graph/gestured_canvas/gestures.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/widgets/gesture_listener.dart';
import 'package:neural_graph/widgets/scrollable.dart';
import 'package:neural_graph/widgets/scrollable_extended.dart';

class GraphView extends HookWidget {
  final Graph graph;

  const GraphView({required this.graph});

  @override
  Widget build(BuildContext context) {
    final graphCanvas = graph.graphCanvas;

    useEffect(
      () => GlobalKeyboardListener.keyboardStream.listen((event) {
        if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
          graph.deleteSelected();
        }
      }).cancel,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Observer(
              builder: (context) {
                return Text(graphCanvas.mousePosition.toString());
              },
            ),
            Observer(
              builder: (context) {
                final addingConnection = graph.addingConnection;
                final isAdding = !addingConnection.isNone();
                return FlatButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {},
                  // onPressed: isAdding
                  //     ? () {
                  //         // graph.addingConnection =
                  //         //     const AddingConnectionState.none();
                  //       }
                  //     : graph.startAddingConnection,
                  color: isAdding ? Colors.black12 : null,
                  label: const Text('Connection'),
                );
              },
            ),
            Observer(
              builder: (context) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Scale: '),
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
        Expanded(
          child: CanvasView(graph: graph),
        ),
      ],
    );
  }
}

class CanvasView extends HookWidget {
  const CanvasView({Key? key, required this.graph}) : super(key: key);
  final Graph graph;

  @override
  Widget build(BuildContext context) {
    final graphCanvas = graph.graphCanvas;

    return ScrollableCanvasWrapper(
      graph: graph,
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          final offset = graphCanvas.toCanvasOffset(details.offset);
          final constructor = Layer.layerConstructors[details.data];
          if (constructor != null) {
            graph.createNode(offset, constructor);
          } else {
            log.e('Wrong layer name ${details.data}');
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Observer(
            builder: (context) {
              return MouseRegion(
                onHover: graph.addingConnection.isAddedInput()
                    ? (hoverEvent) {
                        graphCanvas.setMousePosition(hoverEvent.position);
                      }
                    : null,
                opaque: false,
                child: Observer(
                  key: const Key('nodes'),
                  builder: (context) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GesturedCanvasDetector(
                        gestures: Gestures(
                          onPanEnd: (details) {
                            graph.selectConnectionPoint(
                                graph.selectedConnection, null);
                          },
                          onPanUpdate: (details) {
                            graphCanvas.mousePosition = graphCanvas
                                .toCanvasOffset(details.globalPosition);
                          },
                        ),
                        builder: (context, regions) => Observer(
                          builder: (context) => CustomPaint(
                            size: graph.graphCanvas.size,
                            willChange: true,
                            painter: ConnectionsPainter(
                              regions: regions,
                              nodes: graph.nodes,
                              selectedConnection: graph.selectedConnection,
                              selectedConnectionPoint:
                                  graph.selectedConnectionPoint,
                              graph: graph,
                            ),
                          ),
                        ),
                      ),
                      Observer(
                        builder: (context) => CustomPaint(
                          willChange: true,
                          painter: PartialConnectionsPainter(
                            addingConnectionState: graph.addingConnection,
                            mousePosition: graphCanvas.mousePosition,
                          ),
                        ),
                      ),
                      ...graph.nodes.entries.map(
                        (e) {
                          return NodeView(
                            key: Key(e.key.toString()),
                            node: e.value,
                          );
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ScrollableCanvasWrapper extends StatelessWidget {
  final Graph graph;
  final Widget child;

  const ScrollableCanvasWrapper({
    Key? key,
    required this.graph,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final graphCanvas = graph.graphCanvas;

    return MultiScrollable(
      horizontal: graphCanvas.horizontal,
      vertical: graphCanvas.vertical,
      child: Builder(builder: (context) {
        graphCanvas.setContext(context);
        return MouseScrollListener(
          controller: graphCanvas,
          child: Observer(
            builder: (context) => CustomScrollGestures(
              canvas: graphCanvas,
              allowDrag: !graph.isDragging,
              child: Observer(
                builder: (context) => SizedBox(
                  width: graphCanvas.size.width,
                  height: graphCanvas.size.height,
                  child: child,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
