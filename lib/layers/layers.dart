import 'package:flutter/material.dart';
import 'package:neural_graph/layers/convolutional.dart';
import 'package:neural_graph/layers/input.dart';

abstract class Layer {
  String get layerId;
  Layer get inputs;
  Layer get outputs;

  static final Map<String, Layer Function()> layerConstructors = {
    "Convolutional": () => Convolutional(),
    "Input": () => Input(),
  };

  Widget form([Key key]);
}

enum DType { int32, int64, float32, float64, boolean, string }

class Tensor {
  DType dtype;
  List<int> shape;
}
