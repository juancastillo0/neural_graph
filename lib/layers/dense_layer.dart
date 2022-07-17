import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/common/extensions.dart';
import 'package:neural_graph/diagram/connection.dart';
import 'package:neural_graph/diagram/node.dart';
import 'package:stack_portal/fields.dart';
import 'package:neural_graph/fields/form.dart';
import 'package:neural_graph/layers/codegen_helper.dart';
import 'package:neural_graph/layers/layers.dart';
import 'package:neural_graph/layers/node_layer_view.dart';

class DenseLayer extends Layer {
  DenseLayer(Node<Layer> node)
      : inPort = Port<Layer>(node),
        outPort = Port<Layer>(node),
        super(node);

  @override
  String code(CodeGenHelper h) {
    return """
${h.defineName(name)} layers.${h.layerTypeName("dense")}(${h.openArgs()}
  ${h.setName(name)}
  units${h.sep} $units,
  ${h.setActivation(activation)}
  ${h.argName("useBias")}${h.sep} ${h.printBool(useBias)},
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
  Widget form([Key? key]) {
    return DenseForm(
      key: key,
      state: this,
    );
  }

  @override
  bool isValidInput(Tensor input) {
    return true;
  }

  @override
  String get layerId => 'Dense';

  @override
  Tensor? output(Tensor input) {
    return null;
  }

  final Port<Layer> inPort;
  final Port<Layer> outPort;

  @override
  Iterable<Port<Layer>> get ports => [inPort, outPort];

  @override
  Widget nodeView() => SimpleLayerView(
        layer: this,
        outPort: outPort,
        inPort: inPort,
      );

  ///
  ///
  ///

  final unitsObs = Observable<int>(32);
  int get units => unitsObs.value;

  final useBiasObs = Observable<bool>(true);
  bool get useBias => useBiasObs.value;

  final activationObs = Observable<Activation>(Activation.relu);
  Activation get activation => activationObs.value;
}

class DenseForm extends HookWidget {
  const DenseForm({Key? key, required this.state}) : super(key: key);
  final DenseLayer state;

  @override
  Widget build(BuildContext context) {
    return DefaultFormTable(
      children: [
        tableRow(
          name: 'Units',
          description: 'Number of units',
          field: TextFormField(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              FilteringTextInputFormatter.singleLineFormatter,
            ],
            keyboardType: const TextInputType.numberWithOptions(),
            onChanged: (_value) {
              final value = int.tryParse(_value);
              if (value != null && value > 0) {
                state.unitsObs.value = value;
              }
            },
          ),
        ),
        tableRow(
          name: 'Activation',
          description: 'Optional loss to apply to the output',
          field: Observer(builder: (context) {
            return ButtonSelect<Activation>(
              options: Activation.values,
              selected: state.activation,
              asString: toEnumString,
              onChange: (v) => state.activationObs.value = v,
            );
          }),
        ),
        tableRow(
          name: 'Use Bias',
          description: 'Use learnable parameter added to the output',
          field: Align(
            child: Observer(
              builder: (_) => Switch(
                value: state.useBias,
                onChanged: (v) => state.useBiasObs.value = v,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
