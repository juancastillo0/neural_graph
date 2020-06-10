import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show HookWidget, useMemoized;
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
  double minHeight = 52,
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
          height: max(minHeight, maxHeight ?? 0),
          child: field,
        ),
      ),
    ],
  );
}

class FormFieldState {
  final TextEditingController controller;
  final FocusNode focusNode;
  String error;

  FormFieldState({FocusNode focusNode, TextEditingController controller})
      : controller = controller ?? TextEditingController(),
        focusNode = focusNode ?? FocusNode();
}

class ConvolutionalFormFields {
  final depthMultiplierCont = FormFieldState();
  final dilationRateCont = FormFieldState();
  final stridesCont = FormFieldState();
  final kernelSizeCont = FormFieldState();
}

class ConvolutionalForm extends HookWidget {
  const ConvolutionalForm({
    Key key,
    @required this.state,
  }) : super(key: key);

  final Convolutional state;

  @override
  Widget build(BuildContext context) {
    final fields = useMemoized(() => ConvolutionalFormFields());

    return FocusTraversalGroup(
      child: Form(
        autovalidate: true,
        child: Expanded(
          child: MultiScrollable(
            builder: (ctx, controller) {
              final theme = Theme.of(ctx);
              return SingleChildScrollView(
                controller: controller.vertical,
                child: Theme(
                  data: theme.copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                    isDense: true,
                    // contentPadding: EdgeInsets.only(top: 3, bottom: 3, left: 10),
                    labelStyle: TextStyle(fontSize: 18),
                  )),
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
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          tableRow(
                            name: "Dimensions",
                            description:
                                "Number of dimension in the input tensor",
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
                            name: "Use Bias",
                            description:
                                "Use learnable parameter added to the output",
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
                            name: "Dilation Rate",
                            description:
                                "List of number of omited rows/cols in each dimension",
                            field: ShapeField(
                              state: fields.dilationRateCont,
                            ),
                          ),
                          if (state.separable)
                            tableRow(
                              name: "Depth Multiplier",
                              description:
                                  "Expansion rate in a separable convolution",
                              field: TextFormField(
                                inputFormatters: [
                                  WhitelistingTextInputFormatter.digitsOnly,
                                  BlacklistingTextInputFormatter
                                      .singleLineFormatter,
                                ],
                                controller:
                                    fields.depthMultiplierCont.controller,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                              ),
                            ),
                          tableRow(
                            name: "Strides",
                            description: "",
                            field: ShapeField(
                              state: fields.stridesCont,
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
                            name: "Kernel Size",
                            description: "Size of the filter in each dimension",
                            field: ShapeField(
                              state: fields.kernelSizeCont,
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

final shapeRegex = RegExp(r"^[1-9]\d*(,[1-9]\d*){0,2}(,)?$");

class ShapeField extends StatelessWidget {
  const ShapeField({
    Key key,
    @required this.state,
  }) : super(key: key);

  final FormFieldState state;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: state.controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      focusNode: state.focusNode,
      inputFormatters: [
        WhitelistingTextInputFormatter(shapeRegex),
      ],
      onChanged: (value) {
        final pattern = shapeRegex.pattern;
        if (!shapeRegex.hasMatch(value) && pattern.endsWith("\$")) {
          //"Should be a list of comma separated integers. '2,64,38'"
          final permShapeRegex =
              RegExp(pattern.substring(0, pattern.length - 1));
          state.controller.text =
              permShapeRegex.firstMatch(value)?.group(0) ?? "";
        }
      },
      // onFieldSubmitted: (_) =>
      //     state.focusNode.focusInDirection(TraversalDirection.down),
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
    @required this.selected,
    @required this.onChange,
    this.asString,
  }) : super(key: key);

  final Iterable<T> options;
  final T selected;
  final String Function(T) asString;
  final void Function(T) onChange;

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx);
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      buttonPadding: EdgeInsets.zero,
      children: options.map((e) {
        final s = asString == null ? e.toString() : asString(e);
        return FlatButton(
          key: Key(s),
          onPressed: () => onChange(e),
          child: Text(s),
          color: e == selected ? theme.primaryColor : null,
        );
      }).toList(),
    );
  }
}
