import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


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


class OperationView extends StatelessWidget {
  const OperationView(this.op);

  final Operation op;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
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