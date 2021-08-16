import 'package:flutter/material.dart';
import 'package:neural_graph/diagram/graph.dart';
import 'package:neural_graph/diagram/node.dart';
import 'package:neural_graph/layers/convolutional_layer.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:test/test.dart';

void main() {
  final g = Graph<Layer>();
  Node makeNode() {
    return Node<Layer>(
      graph: g,
      key: '2',
      offset: const Offset(20, 20),
      dataBuilder: (n) => Convolutional(
        n,
        name: 'conv2',
      ),
    );
  }

  group('Convolutional isValidInput', () {
    test('ConvDimension.two', () {
      final node = makeNode();
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
      final node = makeNode();
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
      final node = makeNode();
      final conv = node.data as Convolutional;
      conv.padding = ConvPadding.valid;

      expect(
        conv.output(const Tensor(DType.float64, [1, 20, 20, 5])),
        Tensor(DType.float64, [1, 19, 19, conv.filters]),
      );
    });

    test('stride = 2', () {
      final node = makeNode();
      final conv = node.data as Convolutional;
      conv.strides = [2];

      expect(
        conv.output(const Tensor(DType.float32, [1, 20, 20, 5])),
        Tensor(DType.float32, [1, 10, 10, conv.filters]),
      );
    });

    test('dilationRate = 2', () {
      final node = makeNode();
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
