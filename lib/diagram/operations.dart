import 'package:neural_graph/common/extensions.dart';
import 'package:neural_graph/diagram/node.dart';

List<Node<N>> orderedGraph<N extends NodeData>(Iterable<Node<N>> nodes) {
  final orderedNodes = <Node<N>>[];
  final counts = Map.fromEntries(
    nodes.map((node) {
      final numInputs = node.inputs().length;
      if (numInputs == 0) {
        orderedNodes.add(node);
      }
      return MapEntry(node, numInputs);
    }).where((e) => e.value > 0),
  );

  int numProcessed = 0;
  while (counts.isNotEmpty && orderedNodes.length != numProcessed) {
    for (final k in orderedNodes.sublist(numProcessed)) {
      numProcessed += 1;
      final outs = k.outputs().map((e) => e.to.node);
      if (outs.isEmpty) continue;

      for (final dep in outs) {
        final m = counts.get(dep);
        if (m == 1) {
          counts.remove(dep);
          orderedNodes.add(dep);
        } else {
          counts.set(dep, m! - 1);
        }
      }
    }
  }

  if (counts.isNotEmpty) {
    // CICLE ?
  }
  return orderedNodes;
}
