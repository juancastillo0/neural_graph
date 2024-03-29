// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_graph_canvas.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GraphCanvasStore on _GraphCanvasStore, Store {
  Computed<Offset>? _$translateOffsetComputed;

  @override
  Offset get translateOffset => (_$translateOffsetComputed ??= Computed<Offset>(
          () => super.translateOffset,
          name: '_GraphCanvasStore.translateOffset'))
      .value;

  late final _$sizeAtom =
      Atom(name: '_GraphCanvasStore.size', context: context);

  @override
  Size get size {
    _$sizeAtom.reportRead();
    return super.size;
  }

  @override
  set size(Size value) {
    _$sizeAtom.reportWrite(value, super.size, () {
      super.size = value;
    });
  }

  late final _$scaleAtom =
      Atom(name: '_GraphCanvasStore.scale', context: context);

  @override
  double get scale {
    _$scaleAtom.reportRead();
    return super.scale;
  }

  @override
  set scale(double value) {
    _$scaleAtom.reportWrite(value, super.scale, () {
      super.scale = value;
    });
  }

  late final _$mousePositionAtom =
      Atom(name: '_GraphCanvasStore.mousePosition', context: context);

  @override
  Offset? get mousePosition {
    _$mousePositionAtom.reportRead();
    return super.mousePosition;
  }

  @override
  set mousePosition(Offset? value) {
    _$mousePositionAtom.reportWrite(value, super.mousePosition, () {
      super.mousePosition = value;
    });
  }

  @override
  String toString() {
    return '''
size: ${size},
scale: ${scale},
mousePosition: ${mousePosition},
translateOffset: ${translateOffset}
    ''';
  }
}
