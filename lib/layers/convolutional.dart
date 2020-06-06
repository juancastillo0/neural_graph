import 'package:formgen/formgen.dart';
import 'package:neural_graph/layers/layers.dart';

part 'convolutional.g.dart';

enum ConvPadding { same, valid, causal }

@FormGen(allRequired: true)
class Convolutional implements Layer {
  int dimensions;
  bool useBias;
  List<int> dilationRate;
  double depthMultiplier;
  List<int> strides;
  @EnumField()
  ConvPadding padding;
  List<int> kernelSize;
  int filters;
  bool separable;

  @override
  // TODO: implement inputs
  Layer get inputs => throw UnimplementedError();

  @override
  // TODO: implement outputs
  Layer get outputs => throw UnimplementedError();
}
