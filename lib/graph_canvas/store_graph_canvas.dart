import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/widgets/scrollable.dart';

part 'store_graph_canvas.g.dart';

class GraphCanvasStore = _GraphCanvasStore with _$GraphCanvasStore;

abstract class _GraphCanvasStore with Store {
  @observable
  Size size = const Size(1500, 1000);
  @observable
  double scale = 1;
  @observable
  Offset mousePosition;

  MultiScrollController controller;

  Offset toCanvasOffset(Offset offset) {
    final bounds = controller.globalPaintBounds;
    final _canvasOffset = offset +
        Offset(
          controller.horizontal.offset,
          controller.vertical.offset,
        ) -
        bounds.topLeft;
    return _canvasOffset / scale;
  }

  @computed
  Offset get translateOffset =>
      Offset(size.width / 2, size.height / 2) * (scale - 1);
}
