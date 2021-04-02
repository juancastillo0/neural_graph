import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/common/extensions.dart';

part 'store_graph_canvas.g.dart';

class GraphCanvasStore = _GraphCanvasStore with _$GraphCanvasStore;

abstract class _GraphCanvasStore with Store {
  @observable
  Size size = const Size(1500, 1000);
  @observable
  double scale = 1;
  @observable
  Offset? mousePosition;

  Offset toCanvasOffset(Offset offset) {
    final _canvasOffset = offset + scrollOffset - globalPaintBounds!.topLeft;
    return _canvasOffset / scale;
  }

  // Offset toCanvasOffset2(Offset offset) {
  //   final bounds = globalPaintBounds;
  //   final ph = horizontal.position;
  //   final pv = vertical.position;
  //   return offset * scale + scrollOffset * scale - globalPaintBounds.topLeft;
  // }

  @computed
  Offset get translateOffset =>
      Offset(size.width / 2, size.height / 2) * (scale - 1);

  final ScrollController vertical = ScrollController();
  final ScrollController horizontal = ScrollController();
  late BuildContext _context;

  void setContext(BuildContext context) {
    this._context = context;
  }

  void setMousePosition(Offset position) {
    this.mousePosition = this.toCanvasOffset(position);
  }

  void onDrag(Offset delta) {
    if (delta.dx != 0) {
      final hp = horizontal.position;
      final dx = (horizontal.offset - delta.dx).clamp(0.0, hp.maxScrollExtent);
      horizontal.jumpTo(dx);
    }

    if (delta.dy != 0) {
      final vp = vertical.position;
      final dy =
          (vertical.offset - delta.dy).clamp(0.0, vp.maxScrollExtent);
      vertical.jumpTo(dy);
    }
  }

  Offset get scrollOffset => Offset(
        horizontal.offset,
        vertical.offset,
      );
  Rect? get globalPaintBounds => _context.globalPaintBounds;

  void onScale(double scale) {
    this.scale = scale.clamp(0.4, 2.5);
    final multiplerH = horizontal.offset <= 0.01 ? 1 : -1;
    final multiplerV = vertical.offset <= 0.01 ? 1 : -1;
    horizontal.jumpTo(horizontal.offset + multiplerH * 0.0001);
    vertical.jumpTo(vertical.offset + multiplerV * 0.0001);
  }

  void dispose() {
    vertical.dispose();
    horizontal.dispose();
  }
}
