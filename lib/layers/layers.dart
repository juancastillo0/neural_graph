import 'package:flutter/material.dart';

abstract class Layer {
  Layer get inputs;
  Layer get outputs;

  Widget form([Key key]);
}

enum DType { int32, int64, float32, float64, boolean, string }

class Tensor {
  DType dtype;
  List<int> shape;
}
