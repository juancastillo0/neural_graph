import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neural_graph/fields/form.dart';

RegExp shapeRegexFn(int? dimensions) {
  return RegExp(
      //ignore: prefer_interpolation_to_compose_strings
      r"^[1-9]\d*(,[1-9]\d*){0," + (dimensions ?? 7).toString() + r"}(,)?$");
}

class ShapeField extends StatelessWidget {
  const ShapeField({
    Key? key,
    required this.field,
    required this.dimensions,
  }) : super(key: key);

  final FormFieldValue<List<int>> field;
  final int? dimensions;
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

        final shapeRegex = shapeRegexFn(dimensions);
        final pattern = shapeRegex.pattern;
        print("pattern $pattern");
        if (!shapeRegex.hasMatch(field.controller.text) &&
            pattern.endsWith("\$")) {
          //"Should be a list of comma separated integers. '2,64,38'"
          final permShapeRegex =
              RegExp(pattern.substring(0, pattern.length - 1));
          field.controller.text =
              permShapeRegex.firstMatch(field.controller.text)?.group(0) ?? "";
          print("field.controller.text ${field.controller.text}");
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
            // print(
            //     "value $value field.value ${field.value} field.controller ${field.controller.text}");

            field.value = shapeFromString(value);
            print("value $value field.value ${field.value}");
          },
          // onFieldSubmitted: (_) =>
          //     state.focusNode.focusInDirection(TraversalDirection.down),
        );
      },
    );
  }

  static List<int> shapeFromString(String value) {
    return value
        .split(",")
        .map((e) => int.tryParse(e))
        .where((e) => e != null)
        .toList() as List<int>;
  }

  static String shapeToString(List<int> value) {
    return value.map((v) => v.toString()).join(",");
  }
}
