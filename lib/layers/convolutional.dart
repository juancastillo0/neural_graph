import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show HookWidget, useState, useTextEditingController;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:formgen/formgen.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/widgets/scrollable.dart';

part 'convolutional.g.dart';

enum ConvPadding { same, valid, causal }
enum ConvDimension { one, two, three }
String enumToString(dynamic d) => d.toString().split(".")[1];

class Convolutional = _Convolutional with _$Convolutional;

@FormGen(allRequired: true)
abstract class _Convolutional with Store implements Layer {
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
}

TableRow tableRow({
  String name,
  String description,
  Widget field,
  double maxWidth = 250,
  double maxHeight,
}) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(name),
      ),
      Tooltip(
        message: description,
        child: const Icon(Icons.info_outline),
      ),
      Center(
        child: SizedBox(
          width: maxWidth,
          height: maxHeight,
          child: field,
        ),
      ),
    ],
  );
}

class ConvolutionalForm extends HookWidget {
  const ConvolutionalForm({
    Key key,
    @required this.state,
  }) : super(key: key);

  final Convolutional state;

  @override
  Widget build(BuildContext context) {
    final depthMultiplierCont = useTextEditingController();
    final dilationRateCont = useTextEditingController();
    final stridesCont = useTextEditingController();
    final kernelSizeCont = useTextEditingController();

    return Form(
      autovalidate: true,
      child: Expanded(
        child: MultiScrollable(
          builder: (ctx, controller) {
            final theme = Theme.of(ctx);
            return SingleChildScrollView(
              controller: controller.vertical,
              child: DefaultTextStyle(
                style: theme.textTheme.bodyText1.copyWith(fontSize: 16),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Table(
                    border: TableBorder.symmetric(
                      inside: const BorderSide(
                        width: 10,
                        style: BorderStyle.none,
                      ),
                    ),
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: IntrinsicColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      tableRow(
                        name: "Dimensions",
                        description: "Number of dimension in the input tensor",
                        field: const ButtonSelect(
                          options: ConvDimension.values,
                          defaultOption: ConvDimension.two,
                          asString: enumToString,
                        ),
                      ),
                      tableRow(
                        name: "Use Bias",
                        description:
                            "Use learnable parameter added to the output",
                        field: Align(
                          child: Switch(
                            value: state.useBias,
                            onChanged: (v) => state.useBias = v,
                          ),
                        ),
                      ),
                      tableRow(
                          name: "Dilation Rate",
                          description:
                              "List of number of omited rows/cols in each dimension",
                          field: Align(
                            child: SizedBox(
                              width: 200,
                              child: ShapeField(
                                controller: dilationRateCont,
                                label: "dilationRate",
                              ),
                            ),
                          )),
                      if (state.separable)
                        tableRow(
                          name: "Depth Multiplier",
                          description:
                              "Expansion rate in a separable convolution",
                          field: TextFormField(
                            decoration: const InputDecoration(
                              labelText: "depthMultiplier",
                            ),
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            controller: depthMultiplierCont,
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                          ),
                        ),
                      tableRow(
                        name: "Strides",
                        description: "",
                        field: ShapeField(
                          controller: stridesCont,
                          label: "strides",
                        ),
                      ),
                      tableRow(
                        name: "Padding",
                        description: "",
                        field: const ButtonSelect(
                          options: ConvPadding.values,
                          defaultOption: ConvPadding.same,
                          asString: enumToString,
                        ),
                      ),
                      tableRow(
                        name: "Kernel Size",
                        description: "Size of the filter in each dimension",
                        field: ShapeField(
                          controller: kernelSizeCont,
                          label: "kernelSize",
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final shapeRegex = RegExp(r"^[1-9]\d*(,[1-9]\d*){0,2}(,)?$");

class ShapeField extends StatelessWidget {
  const ShapeField({
    Key key,
    @required this.controller,
    this.label,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) {
        if (!shapeRegex.hasMatch(value)) {
          return "Should be a list of comma separated integers. '2,64,38'";
        }
        return null;
      },
      controller: controller,
      keyboardType: TextInputType.number,
    );
  }
}

// @freezed
// class SelectOption{
//   factory SelectOption.enums()
// }

class ButtonSelect<T> extends HookWidget {
  const ButtonSelect({
    Key key,
    @required this.options,
    this.defaultOption,
    this.asString,
  }) : super(key: key);

  final Iterable<T> options;
  final T defaultOption;
  final String Function(T) asString;

  @override
  Widget build(BuildContext ctx) {
    final selected = useState(defaultOption);
    final theme = Theme.of(ctx);
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      buttonPadding: EdgeInsets.zero,
      children: options.map((e) {
        final s = asString == null ? e.toString() : asString(e);
        return FlatButton(
          key: Key(s),
          onPressed: () => selected.value = e,
          child: Text(s),
          color: e == selected.value ? theme.primaryColor : null,
        );
      }).toList(),
    );
  }
}
