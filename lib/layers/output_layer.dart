import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/common/extensions.dart';
import 'package:neural_graph/diagram/connection.dart';
import 'package:neural_graph/diagram/node.dart';
import 'package:neural_graph/fields/button_select_field.dart';
import 'package:neural_graph/fields/form.dart';
import 'package:neural_graph/layers/codegen_helper.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/layers/losses.dart';
import 'package:neural_graph/layers/node_layer_view.dart';

class OutputLayer extends Layer {
  OutputLayer(Node<Layer> node)
      : inPort = Port<Layer>(node),
        super(node);

  @override
  String code(CodeGenHelper h) {
    return applyCode(h);
  }

  String applyCode(CodeGenHelper h) {
    final _in = inPort.firstFromData;
    if (_in == null) {
      return '';
    }
    return "${h.defineName(name)} ${_in.name}${h.outputSuffix};\n";
  }

  @override
  Widget form([Key? key]) {
    return OutputForm(
      key: key,
      state: this,
    );
  }

  @override
  Widget nodeView() => SimpleLayerView(
        layer: this,
        outPort: null,
        inPort: inPort,
      );

  @override
  bool isValidInput(Tensor input) {
    return true;
  }

  @override
  String get layerId => 'Output';

  @override
  Tensor output(Tensor input) {
    return input;
  }

  final Port<Layer> inPort;

  @override
  Iterable<Port<Layer>> get ports => [inPort];

  ////
  ///
  ///

  final lossObs = Observable<Loss>(Loss.meanSquaredError);
  Loss get loss => lossObs.value;
}

class OutputForm extends HookWidget {
  const OutputForm({Key? key, required this.state}) : super(key: key);
  final OutputLayer state;

  @override
  Widget build(BuildContext ctx) {
    return DefaultFormTable(
      children: [
        tableRow(
          name: 'Loss',
          description: 'Optional loss to apply to the output',
          field: Observer(builder: (context) {
            return ButtonSelect<Loss>(
              options: Loss.values,
              selected: state.loss,
              asString: toEnumString,
              onChange: (v) => state.lossObs.value = v,
            );
          }),
        ),
      ],
    );
  }
}
