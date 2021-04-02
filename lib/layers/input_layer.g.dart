// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_layer.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Input on _Input, Store {
  Computed<Tensor>? _$tensorComputed;

  @override
  Tensor get tensor => (_$tensorComputed ??=
          Computed<Tensor>(() => super.tensor, name: '_Input.tensor'))
      .value;

  final _$dtypeAtom = Atom(name: '_Input.dtype');

  @override
  DType get dtype {
    _$dtypeAtom.reportRead();
    return super.dtype;
  }

  @override
  set dtype(DType value) {
    _$dtypeAtom.reportWrite(value, super.dtype, () {
      super.dtype = value;
    });
  }

  final _$shapeAtom = Atom(name: '_Input.shape');

  @override
  List<int> get shape {
    _$shapeAtom.reportRead();
    return super.shape;
  }

  @override
  set shape(List<int> value) {
    _$shapeAtom.reportWrite(value, super.shape, () {
      super.shape = value;
    });
  }

  @override
  String toString() {
    return '''
dtype: ${dtype},
shape: ${shape},
tensor: ${tensor}
    ''';
  }
}
