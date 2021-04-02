import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neural_graph/common/extensions.dart';
import 'package:neural_graph/diagram/node.dart';
import 'package:neural_graph/layers/layers.dart';

class SimpleLayerView extends StatelessWidget {
  const SimpleLayerView({
    Key? key,
    required this.layer,
    required this.outPort,
    required this.inPort,
  }) : super(key: key);

  final Layer layer;
  final Port<Layer>? outPort;
  final Port<Layer>? inPort;

  @override
  Widget build(BuildContext context) {
    final node = layer.node;
    return Observer(
      builder: (context) => Stack(
        // overflow: Overflow.visible,
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: NodeContainer(
              isSelected: node.graph.selectedNodes.contains(node.key),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    layer.layerId,
                    style: context.textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  Observer(builder: (context) => Text(layer.name)),
                ],
              ),
            ),
          ),
          if (outPort != null)
            Positioned(
              right: 0,
              width: 10,
              height: 10,
              child: PortView(
                port: outPort!,
                canBeStart: true,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          if (inPort != null)
            Positioned(
              left: 0,
              width: 10,
              height: 10,
              child: PortView<Layer>(
                port: inPort!,
                canBeEnd: (inputPort) {
                  return inputPort.node != node;
                },
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
