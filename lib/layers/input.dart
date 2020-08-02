import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show HookWidget, useMemoized;
import 'package:neural_graph/fields/button_select_field.dart';
import 'package:neural_graph/fields/form.dart';
import 'package:neural_graph/fields/shape_field.dart';
import 'package:neural_graph/layers/layers.dart';

part 'input.g.dart';

class Input = _Input with _$Input;

abstract class _Input with Store implements Layer {
  static const String _layerId = "Input";
  @override
  String get layerId => _layerId;

  @observable
  DType dtype = DType.float32;

  @observable
  List<int> shape = [32];

  @override
  //  TODO: implement inputs
  Layer get inputs => throw UnimplementedError();

  @override
  // TODO: implement outputs
  Layer get outputs => throw UnimplementedError();

  @override
  Widget form([Key key]) => DefaultForm(
        key: key,
        child: InputForm(state: this as Input),
      );
}

class InputForm extends HookWidget {
  const InputForm({Key key, @required this.state}) : super(key: key);
  final Input state;
  @override
  Widget build(BuildContext ctx) {
    final shapeField = useMemoized(
      () => FormFieldValue<List<int>>(
        getValue: () => state.shape,
        setValue: (v) => state.shape = v,
      ),
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
          1: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          tableRow(
            name: "Data Type",
            description: "The type of data in the tensor",
            field: Observer(builder: (context) {
              return ButtonSelect<DType>(
                options: DType.values,
                selected: state.dtype,
                asString: enumToString,
                onChange: (v) => state.dtype = v,
              );
            }),
          ),
          tableRow(
            name: "Shape",
            description: "Size of the tensor in each dimension",
            field: ShapeField(
              field: shapeField,
              dimensions: null,
            ),
          ),
        ],
      ),
    );
  }
}
