import 'package:neural_graph/common/extensions.dart';
import 'package:neural_graph/diagram/node.dart';

List<Node<N>> orderedGraph<N extends NodeData>(Iterable<Node<N>> nodes) {
  final connections = nodes.fold<Map<Node<N>, List<Node<N>>>>({}, (p, c) {
    c.inputs().forEach((v) {
      var m = p.get(v.to.node);
      if (m == null) {
        m = [];
        p.set(v.to.node, m);
      }
      m.add(c);
    });
    return p;
  });

  final orderedNodes = <Node<N>>[];
  final counts = Map.fromEntries(
    nodes.map((node) {
      final withDependencies = node.inputs().length;
      if (withDependencies == 0) {
        orderedNodes.add(node);
      }
      return MapEntry(node, withDependencies);
    }).where((e) => e.value > 0),
  );

  int numProcessed = 0;
  while (counts.isNotEmpty && orderedNodes.length != numProcessed) {
    for (final k in orderedNodes.sublist(numProcessed)) {
      numProcessed += 1;
      final outs = connections.get(k);
      if (outs == null) continue;

      for (final dep in outs) {
        final m = counts.get(dep);
        if (m == 1) {
          counts.remove(dep);
          orderedNodes.add(dep);
        } else {
          counts.set(dep, m - 1);
        }
      }
    }
  }

  if (counts.isNotEmpty) {
    // CICLE ?
  }
  return orderedNodes;
}
