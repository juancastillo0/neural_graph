// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RootStore on _RootStore, Store {
  final _$isDraggingAtom = Atom(name: '_RootStore.isDragging');

  @override
  bool get isDragging {
    _$isDraggingAtom.reportRead();
    return super.isDragging;
  }

  @override
  set isDragging(bool value) {
    _$isDraggingAtom.reportWrite(value, super.isDragging, () {
      super.isDragging = value;
    });
  }

  final _$graphCanvasAtom = Atom(name: '_RootStore.graphCanvas');

  @override
  GraphCanvasStore get graphCanvas {
    _$graphCanvasAtom.reportRead();
    return super.graphCanvas;
  }

  @override
  set graphCanvas(GraphCanvasStore value) {
    _$graphCanvasAtom.reportWrite(value, super.graphCanvas, () {
      super.graphCanvas = value;
    });
  }

  @override
  String toString() {
    return '''
isDragging: ${isDragging},
graphCanvas: ${graphCanvas}
    ''';
  }
}