// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Node on _Node, Store {
  Computed<Offset> _$centerComputed;

  @override
  Offset get center => (_$centerComputed ??=
          Computed<Offset>(() => super.center, name: '_Node.center'))
      .value;

  final _$nameAtom = Atom(name: '_Node.name');

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  final _$topAtom = Atom(name: '_Node.top');

  @override
  double get top {
    _$topAtom.reportRead();
    return super.top;
  }

  @override
  set top(double value) {
    _$topAtom.reportWrite(value, super.top, () {
      super.top = value;
    });
  }

  final _$leftAtom = Atom(name: '_Node.left');

  @override
  double get left {
    _$leftAtom.reportRead();
    return super.left;
  }

  @override
  set left(double value) {
    _$leftAtom.reportWrite(value, super.left, () {
      super.left = value;
    });
  }

  final _$widthAtom = Atom(name: '_Node.width');

  @override
  double get width {
    _$widthAtom.reportRead();
    return super.width;
  }

  @override
  set width(double value) {
    _$widthAtom.reportWrite(value, super.width, () {
      super.width = value;
    });
  }

  final _$heightAtom = Atom(name: '_Node.height');

  @override
  double get height {
    _$heightAtom.reportRead();
    return super.height;
  }

  @override
  set height(double value) {
    _$heightAtom.reportWrite(value, super.height, () {
      super.height = value;
    });
  }

  final _$_NodeActionController = ActionController(name: '_Node');

  @override
  void move(DragUpdateDetails d) {
    final _$actionInfo =
        _$_NodeActionController.startAction(name: '_Node.move');
    try {
      return super.move(d);
    } finally {
      _$_NodeActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateSize(BuildContext ctx) {
    final _$actionInfo =
        _$_NodeActionController.startAction(name: '_Node.updateSize');
    try {
      return super.updateSize(ctx);
    } finally {
      _$_NodeActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
name: ${name},
top: ${top},
left: ${left},
width: ${width},
height: ${height},
center: ${center}
    ''';
  }
}
