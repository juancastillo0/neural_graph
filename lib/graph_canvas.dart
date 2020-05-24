import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:neural_graph/arrow.dart';
import 'package:neural_graph/node.dart';
import 'package:neural_graph/root_store.dart';

class GraphView extends HookWidget {
  @override
  Widget build(ctx) {
    final root = useRoot();

    return Container(
      height: 500,
      width: 400,
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
    );
  }
}
