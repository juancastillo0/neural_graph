import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:neural_graph/resizable.dart';
import 'package:styled_widget/styled_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          children: [
            Resizable(
              defaultWidth: 100,
              horizontal: ResizeHorizontal.right,
              child: Column(
                children: [
                  Text("COL2sssss"),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GraphView().expanded(),
                    Resizable(
                      defaultWidth: 100,
                      horizontal: ResizeHorizontal.left,
                      child: Text("COL2sssss"),
                    ),
                  ],
                ).expanded(),
                Resizable(
                  defaultHeight: 300,
                  vertical: ResizeVertical.top,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('You have pushed the button this many times:'),
                      Text(
                        '$_counter',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ],
                  ),
                )
              ],
            ).expanded(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class Operation {
  final String name;
  double top;
  double left;
  Set<int> inputs;
  double width = 0;
  double height = 0;

  Offset get center => Offset(left + width / 2, top + height / 2);

  Operation(this.name, this.top, this.left, this.inputs);
}

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

class OperationView extends StatelessWidget {
  const OperationView(this.op);

  final Operation op;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
        border: Border.all(width: 1),
      ),
      child: LayoutBuilder(
        builder: (ctx, box) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            final newWidth = ctx.size.width + 40;
            final newHeight = ctx.size.height + 40;
            if (newWidth != op.width || newHeight != op.height) {
              op.width = newWidth;
              op.height = newHeight;
            }
          });

          return Text(op.name);
        },
      ),
    );
  }
}

class ConnectionsPainter extends CustomPainter {
  Map<int, Operation> operations;
  ConnectionsPainter(this.operations);

  @override
  void paint(Canvas canvas, Size size) {
    var _paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

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
