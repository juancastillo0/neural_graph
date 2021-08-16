import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show HookWidget, useMemoized;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:formgen/formgen.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/common/extensions.dart';
import 'package:neural_graph/diagram/node.dart';
import 'package:neural_graph/fields/button_select_field.dart';
import 'package:neural_graph/fields/form.dart';
import 'package:neural_graph/fields/shape_field.dart';
import 'package:neural_graph/layers/codegen_helper.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/layers/node_layer_view.dart';

part 'convolutional_layer.g.dart';

enum ConvPadding { same, valid, causal }

enum ConvDimensions { one, two, three }

extension on ConvDimensions {
  int toInt() => index + 1;
}

class Convolutional = _Convolutional with _$Convolutional;

@FormGen(allRequired: true)
abstract class _Convolutional extends Layer with Store {
  _Convolutional(Node<Layer> node, {String? name})
      : this.outPort = Port<Layer>(node),
        this.inPort = Port<Layer>(node),
        super(node, name: name);

  static const String _layerId = 'Convolutional';
  @override
  String get layerId => _layerId;

  @observable
  ConvDimensions dimensions = ConvDimensions.two;
  @FormInput(label: 'Kernel Size', description: 'daaaa')
  @observable
  bool useBias = true;
  @observable
  List<int> dilationRate = [1];
  @observable
  double depthMultiplier = 1;
  @observable
  List<int> strides = [1];
  @observable
  @EnumField()
  ConvPadding padding = ConvPadding.same;
  @observable
  List<int> kernelSize = [3];
  @observable
  int filters = 32;
  @observable
  bool separable = false;
  @observable
  Activation activation = Activation.relu;

  int get outputRank => dimensions.index + 1 + 2;

  int strideAt(int index) => strides.length == 1 ? strides[0] : strides[index];
  int dilationRateAt(int index) =>
      dilationRate.length == 1 ? dilationRate[0] : dilationRate[index];

  @override
  bool isValidInput(Tensor input) {
    return input.dtype.isNumber && outputRank == input.rank;
  }

  final Port<Layer> outPort;
  final Port<Layer> inPort;

  @override
  Iterable<Port<Layer>> get ports => [inPort, outPort];

  @override
  Tensor output(Tensor input) {
    return Tensor(
      input.dtype,
      [input.shape[0], ..._innerShape(input.shape), filters],
    );
  }

  Iterable<int> _innerShape(List<int> input) {
    int index = 1;
    return input.getRange(1, input.length - 1).map(
          (e) => ((padding == ConvPadding.same ? e : e - 1) /
                  strideAt(index) *
                  dilationRateAt(index++))
              .floor(),
        );
  }

  @override
  String code(CodeGenHelper h) {
    String _layerType = '';
    if (separable) {
      _layerType += 'separableConv';
    } else {
      _layerType += 'conv';
    }

    _layerType += '${dimensions.toInt().toString()}d';
    _layerType = h.layerTypeName(_layerType);
    final sep = h.sep;
    final _separableString = separable
        ? '\n    ${h.argName("depthMultiplier")}$sep $depthMultiplier,'
        : '';

    // ignore: leading_newlines_in_multiline_strings
    return """
${h.defineName(name)} layers.$_layerType(${h.openArgs()}
    ${h.setName(this.name)},
    filters$sep $filters,
    ${h.argName('kernelSize')}$sep ${h.firstOrList(kernelSize)},
    padding$sep "${toEnumString(padding)}",
    strides$sep ${h.firstOrList(strides)},
    ${h.argName('useBias')}$sep ${h.printBool(useBias)},
    ${h.argName('dilationRate')}$sep ${h.firstOrList(dilationRate)},
    ${h.setActivation(activation)},$_separableString
${h.closeArgs()});
${applyCode(h)}
""";
  }

  String applyCode(CodeGenHelper h) {
    final _in = inPort.firstFromData;
    if (_in == null) {
      return '';
    }
    return '${h.applyOne(name, _in.name)}\n';
  }

  @override
  Widget form([Key? key]) => DefaultForm(
        key: key,
        child: ConvolutionalForm(state: this as Convolutional),
      );

  @override
  Widget nodeView() => SimpleLayerView(
        layer: this,
        outPort: outPort,
        inPort: inPort,
      );
}

class ConvolutionalFormFields {
  ConvolutionalFormFields(Convolutional state) {
    depthMultiplier = FormFieldValue(
      get: () => state.depthMultiplier,
      set: (v) => state.depthMultiplier = v,
    );
    kernelSize = FormFieldValue(
      get: () => state.kernelSize,
      set: (v) => state.kernelSize = v,
    );
    strides = FormFieldValue(
      get: () => state.strides,
      set: (v) => state.strides = v,
    );
    dilationRate = FormFieldValue(
      get: () => state.dilationRate,
      set: (v) => state.dilationRate = v,
    );
  }
  late final FormFieldValue<double> depthMultiplier;
  late final FormFieldValue<List<int>> dilationRate;
  late final FormFieldValue<List<int>> strides;
  late final FormFieldValue<List<int>> kernelSize;

  void dispose() {
    depthMultiplier.dispose();
    dilationRate.dispose();
    strides.dispose();
    kernelSize.dispose();
  }
}

class ConvolutionalForm extends HookWidget {
  const ConvolutionalForm({
    Key? key,
    required this.state,
  }) : super(key: key);

  final Convolutional state;

  @override
  Widget build(BuildContext context) {
    final fields = useMemoized(
      () => ConvolutionalFormFields(state),
      [state],
    );

    return DefaultFormTable(
      children: [
        tableRow(
          name: 'Dimensions',
          description: 'Number of dimension in the input tensor',
          field: Observer(builder: (context) {
            return ButtonSelect<ConvDimensions>(
              options: ConvDimensions.values,
              selected: state.dimensions,
              asString: toEnumString,
              onChange: (v) => state.dimensions = v,
            );
          }),
        ),
        tableRow(
          name: 'Kernel Size',
          description: 'Size of the filter in each dimension',
          field: ShapeField(
            field: fields.kernelSize,
            dimensions: state.dimensions.index,
          ),
        ),
        tableRow(
          name: 'Padding',
          description: 'Border padding behaviour',
          field: Observer(
            builder: (_) => ButtonSelect<ConvPadding>(
              options: ConvPadding.values,
              selected: state.padding,
              onChange: (v) => state.padding = v,
              asString: toEnumString,
            ),
          ),
        ),
        tableRow(
          name: 'Strides',
          description: 'List of number of omited rows/cols in each dimension',
          field: ShapeField(
            field: fields.strides,
            dimensions: state.dimensions.index,
          ),
        ),
        tableRow(
          name: 'Dilation Rate',
          description: 'List of number of omited rows/cols in each dimension',
          field: ShapeField(
            field: fields.dilationRate,
            dimensions: state.dimensions.index,
          ),
        ),
        tableRow(
          name: 'Use Bias',
          description: 'Use learnable parameter added to the output',
          field: Align(
            child: Observer(
              builder: (_) => Switch(
                value: state.useBias,
                onChanged: (v) => state.useBias = v,
              ),
            ),
          ),
        ),
        tableRow(
          name: 'Separable',
          description:
              'Whether the convolution is separated into pointwise and depthwise or full',
          field: Align(
            child: Observer(
              builder: (ctx) => Switch(
                value: state.separable,
                onChanged: (v) => state.separable = v,
              ),
            ),
          ),
        ),
        if (state.separable)
          tableRow(
            name: 'Depth Multiplier',
            description: 'Expansion rate in a separable convolution',
            field: TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.singleLineFormatter,
              ],
              controller: fields.depthMultiplier.controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ),
      ],
    );
  }
}
