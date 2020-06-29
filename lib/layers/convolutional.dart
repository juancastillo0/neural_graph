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
import 'package:neural_graph/layers/layers.dart';

part 'convolutional.g.dart';

enum ConvPadding { same, valid, causal }
enum ConvDimension { one, two, three }

class Convolutional = _Convolutional with _$Convolutional;

@FormGen(allRequired: true)
abstract class _Convolutional with Store implements Layer {
  static const String _layerId = "Convolutional";
  @override
  String get layerId => _layerId;

  @observable
  ConvDimension dimensions = ConvDimension.two;
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

  @override
  // TODO: implement inputs
  Layer get inputs => throw UnimplementedError();

  @override
  // TODO: implement outputs
  Layer get outputs => throw UnimplementedError();

  @override
  Widget form([Key key]) => DefaultForm(
        child: ConvolutionalForm(key: key, state: this as Convolutional),
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
              return ButtonSelect<ConvDimension>(
                options: ConvDimension.values,
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
            description: "",
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
        ],
      ),
    );
  }
}
