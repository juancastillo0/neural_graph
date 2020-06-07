// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'convolutional.dart';

// **************************************************************************
// FormGenGenerator
// **************************************************************************

// Hey! Annotation found!

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Convolutional on _Convolutional, Store {
  final _$dimensionsAtom = Atom(name: '_Convolutional.dimensions');

  @override
  ConvDimension get dimensions {
    _$dimensionsAtom.reportRead();
    return super.dimensions;
  }

  @override
  set dimensions(ConvDimension value) {
    _$dimensionsAtom.reportWrite(value, super.dimensions, () {
      super.dimensions = value;
    });
  }

  final _$useBiasAtom = Atom(name: '_Convolutional.useBias');

  @override
  bool get useBias {
    _$useBiasAtom.reportRead();
    return super.useBias;
  }

  @override
  set useBias(bool value) {
    _$useBiasAtom.reportWrite(value, super.useBias, () {
      super.useBias = value;
    });
  }

  final _$dilationRateAtom = Atom(name: '_Convolutional.dilationRate');

  @override
  List<int> get dilationRate {
    _$dilationRateAtom.reportRead();
    return super.dilationRate;
  }

  @override
  set dilationRate(List<int> value) {
    _$dilationRateAtom.reportWrite(value, super.dilationRate, () {
      super.dilationRate = value;
    });
  }

  final _$depthMultiplierAtom = Atom(name: '_Convolutional.depthMultiplier');

  @override
  double get depthMultiplier {
    _$depthMultiplierAtom.reportRead();
    return super.depthMultiplier;
  }

  @override
  set depthMultiplier(double value) {
    _$depthMultiplierAtom.reportWrite(value, super.depthMultiplier, () {
      super.depthMultiplier = value;
    });
  }

  final _$stridesAtom = Atom(name: '_Convolutional.strides');

  @override
  List<int> get strides {
    _$stridesAtom.reportRead();
    return super.strides;
  }

  @override
  set strides(List<int> value) {
    _$stridesAtom.reportWrite(value, super.strides, () {
      super.strides = value;
    });
  }

  final _$paddingAtom = Atom(name: '_Convolutional.padding');

  @override
  ConvPadding get padding {
    _$paddingAtom.reportRead();
    return super.padding;
  }

  @override
  set padding(ConvPadding value) {
    _$paddingAtom.reportWrite(value, super.padding, () {
      super.padding = value;
    });
  }

  final _$kernelSizeAtom = Atom(name: '_Convolutional.kernelSize');

  @override
  List<int> get kernelSize {
    _$kernelSizeAtom.reportRead();
    return super.kernelSize;
  }

  @override
  set kernelSize(List<int> value) {
    _$kernelSizeAtom.reportWrite(value, super.kernelSize, () {
      super.kernelSize = value;
    });
  }

  final _$filtersAtom = Atom(name: '_Convolutional.filters');

  @override
  int get filters {
    _$filtersAtom.reportRead();
    return super.filters;
  }

  @override
  set filters(int value) {
    _$filtersAtom.reportWrite(value, super.filters, () {
      super.filters = value;
    });
  }

  final _$separableAtom = Atom(name: '_Convolutional.separable');

  @override
  bool get separable {
    _$separableAtom.reportRead();
    return super.separable;
  }

  @override
  set separable(bool value) {
    _$separableAtom.reportWrite(value, super.separable, () {
      super.separable = value;
    });
  }

  @override
  String toString() {
    return '''
dimensions: ${dimensions},
useBias: ${useBias},
dilationRate: ${dilationRate},
depthMultiplier: ${depthMultiplier},
strides: ${strides},
padding: ${padding},
kernelSize: ${kernelSize},
filters: ${filters},
separable: ${separable}
    ''';
  }
}
