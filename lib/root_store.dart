import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/node.dart';

part 'root_store.g.dart';

class RootStore extends _RootStore with _$RootStore {
  static RootStore get instance => GetIt.instance.get<RootStore>();
}

abstract class _RootStore with Store {
  ObservableMap<int, Node> nodes = ObservableMap.of({
    1: Node("conv1", 100, 300, Set()),
    2: Node("conv2", 20, 20, Set()..add(1)),
  });
}

RootStore useRoot() {
  return RootStore.instance;
}
