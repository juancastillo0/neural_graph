// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'convolutional_layer.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Convolutional on _Convolutional, Store {
  late final _$dimensionsAtom =
      Atom(name: '_Convolutional.dimensions', context: context);

  @override
  ConvDimensions get dimensions {
    _$dimensionsAtom.reportRead();
    return super.dimensions;
  }

  @override
  set dimensions(ConvDimensions value) {
    _$dimensionsAtom.reportWrite(value, super.dimensions, () {
      super.dimensions = value;
    });
  }

  late final _$useBiasAtom =
      Atom(name: '_Convolutional.useBias', context: context);

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

  late final _$dilationRateAtom =
      Atom(name: '_Convolutional.dilationRate', context: context);

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

  late final _$depthMultiplierAtom =
      Atom(name: '_Convolutional.depthMultiplier', context: context);

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

  late final _$stridesAtom =
      Atom(name: '_Convolutional.strides', context: context);

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

  late final _$paddingAtom =
      Atom(name: '_Convolutional.padding', context: context);

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

  late final _$kernelSizeAtom =
      Atom(name: '_Convolutional.kernelSize', context: context);

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

  late final _$filtersAtom =
      Atom(name: '_Convolutional.filters', context: context);

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

  late final _$separableAtom =
      Atom(name: '_Convolutional.separable', context: context);

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

  late final _$activationAtom =
      Atom(name: '_Convolutional.activation', context: context);

  @override
  Activation get activation {
    _$activationAtom.reportRead();
    return super.activation;
  }

  @override
  set activation(Activation value) {
    _$activationAtom.reportWrite(value, super.activation, () {
      super.activation = value;
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
separable: ${separable},
activation: ${activation}
    ''';
  }
}
