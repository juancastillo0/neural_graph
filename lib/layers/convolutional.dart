import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show HookWidget, useMemoized;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:formgen/formgen.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/fields/button_select_field.dart';
import 'package:neural_graph/fields/form.dart';
import 'package:neural_graph/fields/shape_field.dart';
import 'package:neural_graph/layers/codegen_helper.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/node.dart';

part 'convolutional.g.dart';

enum ConvPadding { same, valid, causal }

extension on ConvPadding {
  String toEnumString() => toString().split(".")[1];
}

enum ConvDimensions { one, two, three }

extension on ConvDimensions {
  int toInt() => index + 1;
}

class Convolutional = _Convolutional with _$Convolutional;

@FormGen(allRequired: true)
abstract class _Convolutional extends Layer with Store {
  _Convolutional(Node node) : super(node);

  static const String _layerId = "Convolutional";
  @override
  String get layerId => _layerId;

  @observable
  ConvDimensions dimensions = ConvDimensions.two;
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

  int get outputRank => dimensions.index + 1 + 2;

  int strideAt(int index) => strides.length == 1 ? strides[0] : strides[index];
  int dilationRateAt(int index) =>
      dilationRate.length == 1 ? dilationRate[0] : dilationRate[index];

  @override
  bool isValidInput(Tensor input) {
    return input.dtype.isNumber && outputRank == input.rank;
  }

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

  String code(CodeGenHelper helper) {
    String _layerType = "";
    if (separable) {
      _layerType += "separableConv";
    } else {
      _layerType += "conv";
    }

    _layerType += "${dimensions.toInt().toString()}d";
    _layerType = helper.layerTypeName(_layerType);
    final sep = helper.sep;
    final _separableString = separable
        ? '${helper.argName("depthMultiplier")}$sep $depthMultiplier'
        : '';

    // ignore: leading_newlines_in_multiline_strings
    return """$_layerType(
	  ${helper.layerName(node.name)}
	  filters$sep $filters,
    ${helper.argName('kernelSize')}$sep ${helper.firstOrList(kernelSize)},
    padding$sep ${padding.toEnumString()},
    strides$sep ${helper.firstOrList(strides)},
    ${helper.argName('useBias')}$sep ${helper.printBool(useBias)},
    ${helper.argName('dilationRate')}$sep ${helper.firstOrList(dilationRate)},
    [%=c.setActivation()%]
    $_separableString,
${helper.closeArgs()});
[%=c.applyOne()%]
""";
  }

  @override
  Widget form([Key key]) => DefaultForm(
        key: key,
        child: ConvolutionalForm(state: this as Convolutional),
      );
}

class ConvolutionalFormFields {
  ConvolutionalFormFields(Convolutional state) {
    depthMultiplier = FormFieldValue(
      getValue: () => state.depthMultiplier,
      setValue: (v) => state.depthMultiplier = v,
    );
    kernelSize = FormFieldValue(
      getValue: () => state.kernelSize,
      setValue: (v) => state.kernelSize = v,
    );
    strides = FormFieldValue(
      getValue: () => state.strides,
      setValue: (v) => state.strides = v,
    );
    dilationRate = FormFieldValue(
      getValue: () => state.dilationRate,
      setValue: (v) => state.dilationRate = v,
    );
  }
  FormFieldValue<double> depthMultiplier;
  FormFieldValue<List<int>> dilationRate;
  FormFieldValue<List<int>> strides;
  FormFieldValue<List<int>> kernelSize;

  void dispose() {
    depthMultiplier.dispose();
    dilationRate.dispose();
    strides.dispose();
    kernelSize.dispose();
  }
}

class ConvolutionalForm extends HookWidget {
  const ConvolutionalForm({
    Key key,
    @required this.state,
  }) : super(key: key);

  final Convolutional state;

  @override
  Widget build(BuildContext context) {
    final fields = useMemoized(
      () => ConvolutionalFormFields(state),
      [state],
    );

    return Observer(
      builder: (ctx) => Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(
            width: 10,
            style: BorderStyle.none,
          ),
        ),
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FixedColumnWidth(40),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          tableRow(
            name: "Dimensions",
            description: "Number of dimension in the input tensor",
            field: Observer(builder: (context) {
              return ButtonSelect<ConvDimensions>(
                options: ConvDimensions.values,
                selected: state.dimensions,
                asString: enumToString,
                onChange: (v) => state.dimensions = v,
              );
            }),
          ),
          tableRow(
            name: "Kernel Size",
            description: "Size of the filter in each dimension",
            field: ShapeField(
              field: fields.kernelSize,
              dimensions: state.dimensions.index,
            ),
          ),
          tableRow(
            name: "Padding",
            description: "Border padding behaviour",
            field: Observer(
              builder: (_) => ButtonSelect<ConvPadding>(
                options: ConvPadding.values,
                selected: state.padding,
                onChange: (v) => state.padding = v,
                asString: enumToString,
              ),
            ),
          ),
          tableRow(
            name: "Strides",
            description: "List of number of omited rows/cols in each dimension",
            field: ShapeField(
              field: fields.strides,
              dimensions: state.dimensions.index,
            ),
          ),
          tableRow(
            name: "Dilation Rate",
            description: "List of number of omited rows/cols in each dimension",
            field: ShapeField(
              field: fields.dilationRate,
              dimensions: state.dimensions.index,
            ),
          ),
          tableRow(
            name: "Use Bias",
            description: "Use learnable parameter added to the output",
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
            name: "Separable",
            description:
                "Whether the convolution is separated into pointwise and depthwise or full",
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
              name: "Depth Multiplier",
              description: "Expansion rate in a separable convolution",
              field: TextFormField(
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly,
                  BlacklistingTextInputFormatter.singleLineFormatter,
                ],
                controller: fields.depthMultiplier.controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
