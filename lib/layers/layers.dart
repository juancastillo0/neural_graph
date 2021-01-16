import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/diagram/connection.dart';
import 'package:neural_graph/layers/convolutional.dart';
import 'package:neural_graph/layers/input.dart';
import 'package:neural_graph/diagram/node.dart';

abstract class Layer implements NodeData {
  Layer(this.node, {String name}) : this._name = Observable(name ?? "");
  final Node node;

  final Observable<String> _name;
  String get name => _name.value;
  void setName(String name) {
    runInAction(() {
      _name.value = name;
    }, name: "setName");
  }

  String get layerId;

  Tensor output(Tensor input);

  static final Map<String, Layer Function(Node)> layerConstructors = {
    "Convolutional": (node) => Convolutional(node as Node<Layer>),
    "Input": (node) => Input(node as Node<Layer>),
  };

  Widget form([Key key]);

  @override
  Widget nodeView() {
    return Observer(builder: (context) => Text(name));
  }

  bool isValidInput(Tensor input);
}

class LayerInputType {}

class Tensor {
  final DType dtype;
  final List<int> shape;

  const Tensor(this.dtype, this.shape);

  int get rank => shape.length;

  @override
  bool operator ==(Object other) {
    if (other is Tensor) {
      return other.dtype == dtype && deepEqualList(shape, other.shape);
    }
    return false;
  }

  @override
  int get hashCode => dtype.hashCode + shape.hashCode;

  @override
  String toString() {
    return "Tensor: ${dtype.toEnumString()} [${shape.join(',')}]";
  }
}

bool deepEqualList<T>(List<T> l1, List<T> l2) {
  return l1.length == l2.length &&
      Iterable<int>.generate(l1.length).every(
        (i) => l1[i] == l2[i],
      );
}

enum DType { int32, int64, float32, float64, boolean, string }

enum Activation { int32, int64, float32, float64, boolean, string }

extension DTypeHelpers on DType {
  String toEnumString() => toString().split(".")[1];

  bool get isNumber {
    switch (this) {
      case DType.float32:
      case DType.int32:
      case DType.int64:
      case DType.float64:
        return true;

      default:
        return false;
    }
  }

  bool get isFloat {
    switch (this) {
      case DType.float32:
      case DType.float64:
        return true;

      default:
        return false;
    }
  }

  bool get isInt {
    switch (this) {
      case DType.int32:
      case DType.int64:
        return true;

      default:
        return false;
    }
  }

  bool get isBool => this == DType.boolean;
  bool get isString => this == DType.string;
}
