import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show HookWidget, useState, useTextEditingController;
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
          builder: (ctx, controller) => ListView(
            controller: controller.vertical,
            children: [
              const ButtonSelect(
                options: ConvDimension.values,
                defaultOption: ConvDimension.two,
                asString: enumToString,
              ),
              Switch(
                value: state.useBias,
                onChanged: (v) => state.useBias = v,
              ),
              ShapeField(
                controller: dilationRateCont,
                label: "dilationRate",
              ),
              if (state.separable)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "depthMultiplier",
                  ),
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  controller: depthMultiplierCont,
                  keyboardType: const TextInputType.numberWithOptions(),
                ),
              ShapeField(
                controller: stridesCont,
                label: "strides",
              ),
              const ButtonSelect(
                options: ConvPadding.values,
                defaultOption: ConvPadding.same,
                asString: enumToString,
              ),
              ShapeField(
                controller: kernelSizeCont,
                label: "kernelSize",
              ),
              Switch(
                value: state.separable,
                onChanged: (v) => state.separable = v,
              ),
            ],
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

    return ButtonBar(
      children: options.map((e) {
        final s = asString == null ? e.toString() : asString(e);
        return FlatButton(
          key: Key(s),
          onPressed: () => selected.value = e,
          child: Text(s),
          colorBrightness:
              e == selected.value ? Brightness.dark : Brightness.light,
        );
      }).toList(),
    );
  }
}
