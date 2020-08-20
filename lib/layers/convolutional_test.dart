import 'package:mobx/mobx.dart';
import 'package:neural_graph/node.dart';
import 'package:test/test.dart';
import 'package:neural_graph/layers/convolutional.dart';
import 'package:neural_graph/layers/layers.dart';

void main() {
  Node makeNode(Iterable<NodeRef> inputs) {
    return Node('2', "conv2", 20, 20, ObservableSet.of(inputs),
        (n) => Convolutional(n));
  }

  group('Convolutional isValidInput', () {
    test('ConvDimension.two', () {
      final node = makeNode([]);
      final conv = node.data as Convolutional;

      expect(
        conv.isValidInput(const Tensor(DType.float32, [1, 20, 20, 5])),
        true,
      );
      expect(
        conv.isValidInput(const Tensor(DType.string, [1, 20, 20, 5])),
        false,
      );
      expect(
        conv.isValidInput(const Tensor(DType.float32, [1, 20, 5])),
        false,
      );
    });

    test('ConvDimensions.one', () {
      final node = makeNode([]);
      final conv = node.data as Convolutional;
      conv.dimensions = ConvDimensions.one;

      expect(
        conv.isValidInput(const Tensor(DType.float32, [1, 20, 5])),
        true,
      );
      expect(
        conv.isValidInput(const Tensor(DType.string, [1, 20, 5])),
        false,
      );
      expect(
        conv.isValidInput(const Tensor(DType.float32, [1, 20, 20, 5])),
        false,
      );
    });
  });

  group('Convolutional output', () {
    test('ConvPadding.valid', () {
      final node = makeNode([]);
      final conv = node.data as Convolutional;
      conv.padding = ConvPadding.valid;

      expect(
        conv.output(const Tensor(DType.float64, [1, 20, 20, 5])),
        Tensor(DType.float64, [1, 19, 19, conv.filters]),
      );
    });

    test('stride = 2', () {
      final node = makeNode([]);
      final conv = node.data as Convolutional;
      conv.strides = [2];

      expect(
        conv.output(const Tensor(DType.float32, [1, 20, 20, 5])),
        Tensor(DType.float32, [1, 10, 10, conv.filters]),
      );
    });

    test('dilationRate = 2', () {
      final node = makeNode([]);
      final conv = node.data as Convolutional;
      conv.dilationRate = [2];
      conv.filters = 64;

      expect(
        conv.output(const Tensor(DType.float32, [1, 20, 20, 5])),
        const Tensor(DType.float32, [1, 40, 40, 64]),
      );
    });
  });
}
