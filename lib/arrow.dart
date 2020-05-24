import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neural_graph/node.dart';

class ConnectionsPainter extends CustomPainter {
  Map<int, Operation> operations;
  ConnectionsPainter(this.operations);
  static final _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    for (final op in operations.values) {
      for (final input in op.inputs) {
        final other = operations[input];
        canvas.drawLine(op.center, other.center, _paint);

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
        paragraph.layout(ui.ParagraphConstraints(width: 200));

        canvas.drawParagraph(
          paragraph,
          Offset.lerp(other.center, op.center, 0.5).translate(-100, -12),
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

  @override
  bool shouldRepaint(ConnectionsPainter oldDelegate) => true;
}
