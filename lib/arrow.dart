import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neural_graph/diagram/graph.dart';
import 'package:neural_graph/graph_canvas/adding_node_state.dart';
import 'package:neural_graph/diagram/node.dart';
import 'package:touchable/touchable.dart';

class PartialConnectionsPainter extends CustomPainter {
  final AddingConnectionState addingConnectionState;
  final Offset? mousePosition;
  // final BuildContext context;

  const PartialConnectionsPainter({
    // @required this.context,
    required this.addingConnectionState,
    required this.mousePosition,
  });
  static final _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    // final canvas = TouchyCanvas(context, _canvas);
    addingConnectionState.maybeWhen(
      orElse: () {},
      addedInput: (port) {
        canvas.drawLine(port.offset, mousePosition!, _paint);
      },
    );
  }

  @override
  bool shouldRepaint(PartialConnectionsPainter oldDelegate) => true;
}

class ConnectionsPainter extends CustomPainter {
  final Map<String, Node> nodes;
  final int? selectedConnectionPoint;
  final Connection? selectedConnection;
  final BuildContext context;
  final Graph graph;

  ConnectionsPainter({
    required this.context,
    required this.nodes,
    required this.selectedConnectionPoint,
    required this.selectedConnection,
    required this.graph,
  }) {
    // mobx
    graph.nodes.values.forEach((node) => node.data.ports.forEach(
        (port) => port.connections.forEach((conn) => conn.innerPoints.length)));
  }
  static final _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 3.0;
  static final _selectedPaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 3.0;

  @override
  void paint(Canvas _canvas, Size size) {
    final canvas = TouchyCanvas(context, _canvas);

    final List<VoidCallback> circles = [];

    for (final node in nodes.values) {
      for (final port in node.data.ports) {
        for (final conn in port.connections.where((conn) => conn.to == port)) {
          final isSelected = conn == selectedConnection;
          final other = conn.from;

          void Function(DragStartDetails) createOnLongPressStart(
            int insertIndex,
          ) =>
              (DragStartDetails details) {
                conn.innerPoints.insert(insertIndex, details.localPosition);
                graph.selectConnectionPoint(conn, insertIndex);
              };

          void onTapUp(TapUpDetails _) {
            graph.selectConnection(conn);
          }

          Offset curr = port.offset;
          for (final pointIndex
              in Iterable<int>.generate(conn.innerPoints.length)) {
            final innerPoint = conn.innerPoints[pointIndex]!;
            canvas.drawLine(
              curr,
              innerPoint,
              isSelected ? _selectedPaint : _paint,
              onTapUp: onTapUp,
              onPanStart: createOnLongPressStart(pointIndex),
            );
            curr = innerPoint;

            final isPointSelected =
                isSelected && selectedConnectionPoint == pointIndex;
            circles.add(
              () => canvas.drawCircle(
                innerPoint,
                6,
                isPointSelected ? _selectedPaint : _paint,
                onPanStart: (details) {
                  graph.setIsDragging(true);
                  graph.selectConnectionPoint(conn, pointIndex);
                },
              ),
            );
          }
          canvas.drawLine(
            curr,
            other.offset,
            isSelected ? _selectedPaint : _paint,
            onTapUp: onTapUp,
            onPanStart: createOnLongPressStart(conn.innerPoints.length),
          );

          final paragraphB = ui.ParagraphBuilder(ui.ParagraphStyle(
            fontSize: 16,
            textAlign: TextAlign.center,
          ));
          paragraphB.pushStyle(ui.TextStyle(
            color: Colors.black,
            background: Paint()..color = Colors.white,
          ));
          paragraphB.addText("[24, 24, 12]");
          final paragraph = paragraphB.build();
          paragraph.layout(const ui.ParagraphConstraints(width: 200));

          Offset? _paragraphPoint1 = other.offset;
          Offset? _paragraphPoint2 = port.offset;

          if (conn.innerPoints.isNotEmpty) {
            final _pos = ((conn.innerPoints.length - 1) / 2).floor();
            _paragraphPoint1 = conn.innerPoints[_pos];
            if (_pos + 1 < conn.innerPoints.length) {
              _paragraphPoint2 = conn.innerPoints[_pos + 1];
            }
            print(_paragraphPoint1);
            print(_paragraphPoint2);
            print(conn.innerPoints);
            print(_pos);
          }

          canvas.drawParagraph(
            paragraph,
            Offset.lerp(
              _paragraphPoint1,
              _paragraphPoint2,
              0.5,
            )!.translate(-100, -12),
          );

          // // DRAW ARROW TRIANGLE
          // final path = Path();
          // path.moveTo(size.width/2, 0);
          // path.lineTo(0, size.height);
          // path.lineTo(size.height, size.width);
          // path.close();
          // canvas.drawPath(path, _paint);
        }
      }
    }
    for (final call in circles) {
      call();
    }
  }

  @override
  bool shouldRepaint(ConnectionsPainter oldDelegate) => true;
}
