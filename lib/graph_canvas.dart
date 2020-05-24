import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neural_graph/arrow.dart';
import 'package:neural_graph/node.dart';
import 'package:styled_widget/styled_widget.dart';

class GraphView extends StatefulWidget {
  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  Map<int, Operation> operations = {
    1: Operation("Conv 1", 50, 100, Set()),
    2: Operation("Conv 2", 20, 20, Set()..add(1)),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: 400,
      color: Colors.white54,
      child: CustomPaint(
          painter: ConnectionsPainter(operations),
          child: Stack(
            children: operations.entries.map((e) {
              final op = e.value;
              return Positioned(
                key: Key(e.key.toString()),
                top: op.top,
                left: op.left,
                child: OperationView(op).gestures(
                  dragStartBehavior: DragStartBehavior.down,
                  onPanUpdate: (d) => setState(() {
                    op.left += d.delta.dx;
                    op.top += d.delta.dy;
                  }),
                ),
              );
            }).toList(),
          ),
      ),
    );
  }
}
