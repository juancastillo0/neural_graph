import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show HookWidget, useEffect, useMemoized;
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

  @override
  Widget form([Key key]) =>
      ConvolutionalForm(key: key, state: this as Convolutional);
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
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: maxWidth,
            height: max(minHeight, maxHeight ?? 0),
            child: field,
          ),
        ),
      ),
    ],
  );
}

class FormFieldState<T> {
  final TextEditingController controller;
  final FocusNode focusNode;
  String error;
  final T Function() _getValue;
  final Function(T) _setValue;

  T get value => _getValue();
  set value(T newValue) => _setValue(newValue);

  FormFieldState(
      {@required T Function() getValue,
      @required Function(T) setValue,
      FocusNode focusNode,
      TextEditingController controller})
      : controller = controller ?? TextEditingController(),
        focusNode = focusNode ?? FocusNode(),
        _getValue = getValue,
        _setValue = setValue;

  void dispose() {
    focusNode.dispose();
    controller.dispose();
  }
}

class ConvolutionalFormFields {
  ConvolutionalFormFields(Convolutional state) {
    depthMultiplier = FormFieldState(
      getValue: () => state.depthMultiplier,
      setValue: (v) => state.depthMultiplier = v,
    );
    kernelSize = FormFieldState(
      getValue: () => state.kernelSize,
      setValue: (v) => state.kernelSize = v,
    );
    strides = FormFieldState(
      getValue: () => state.strides,
      setValue: (v) => state.strides = v,
    );
    dilationRate = FormFieldState(
      getValue: () => state.dilationRate,
      setValue: (v) => state.dilationRate = v,
    );
  }
  FormFieldState<double> depthMultiplier;
  FormFieldState<List<int>> dilationRate;
  FormFieldState<List<int>> strides;
  FormFieldState<List<int>> kernelSize;

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
    useEffect(() => () => fields.dispose);

    return Expanded(
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
                  child: FocusTraversalGroup(
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
                            field: fields.dilationRate,
                            state: state,
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
                              controller: fields.depthMultiplier.controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                        tableRow(
                          name: "Strides",
                          description: "",
                          field: ShapeField(
                            field: fields.strides,
                            state: state,
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
                            field: fields.kernelSize,
                            state: state,
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
            ),
          );
        },
      ),
    );
  }
}

class ShapeField extends StatelessWidget {
  const ShapeField({
    Key key,
    @required this.field,
    @required this.state,
  }) : super(key: key);

  final FormFieldState<List<int>> field;
  final Convolutional state;
  // final cc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (ctx) {
        print("field.value ${field.value}");
        final stringValue = shapeToString(field.value);
        if (field.controller.text != stringValue &&
            field.controller.text != "$stringValue,") {
          field.controller.text = stringValue;
        }

        final shapeRegex = shapeRegexFn(state);
        final pattern = shapeRegex.pattern;
        if (!shapeRegex.hasMatch(field.controller.text) &&
            pattern.endsWith("\$")) {
          //"Should be a list of comma separated integers. '2,64,38'"
          final permShapeRegex =
              RegExp(pattern.substring(0, pattern.length - 1));
          field.controller.text =
              permShapeRegex.firstMatch(field.controller.text)?.group(0) ?? "";
          field.value = shapeFromString(field.controller.text);
        }
        return TextFormField(
          controller: field.controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          focusNode: field.focusNode,
          inputFormatters: [
            WhitelistingTextInputFormatter(shapeRegex),
          ],
          onChanged: (value) {
            print(
                "value $value field.value ${field.value} field.controller ${field.controller.text}");

            field.value = shapeFromString(value);
          },
          // onFieldSubmitted: (_) =>
          //     state.focusNode.focusInDirection(TraversalDirection.down),
        );
      },
    );
  }

  List<int> shapeFromString(String value) {
    return value
        .split(",")
        .map((e) => int.tryParse(e))
        .where((e) => e != null)
        .toList();
  }

  String shapeToString(List<int> value) {
    return value.map((v) => v.toString()).join(",");
  }
}

RegExp shapeRegexFn(Convolutional state) {
  //ignore: prefer_interpolation_to_compose_strings
  return RegExp(r"^[1-9]\d*(,[1-9]\d*){0," +
      state.dimensions.index.toString() +
      r"}(,)?$");
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
          color: e == selected ? theme.primaryColor : null,
          child: Text(s),
        );
      }).toList(),
    );
  }
}
