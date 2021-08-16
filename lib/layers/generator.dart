import 'package:neural_graph/common/extensions.dart';
import 'package:neural_graph/diagram/operations.dart';
import 'package:neural_graph/layers/codegen_helper.dart';
import 'package:neural_graph/layers/neural_network.dart';

String generateNeuralNetworkCode(
    NeuralNetwork network, ProgrammingLanguage lang) {
  final graph = network.graph;
  final h = CodeGenHelper(language: lang);

  h.write(lang.isJs
      ? '''
import * as tf from "@tensorflow/tfjs-node";
import { SymbolicTensor, layers } from "@tensorflow/tfjs-node";
import { reduceSingle } from "./reduce-single";

export const makeModel = () => {
'''
      : '''
import tensorflow as tf
from tensorflow.keras import layers

def make_model():
''');

  h.withTab(() {
// ================    INPUTS
    for (final c in network.inputs) {
      h.write("""
${h.defineOutput(c.name)} layers.${h.layerTypeName("input")}(${h.openArgs()}
  ${h.setName(c.name)}
  dtype${h.sep} "${toEnumString(c.dtype)}",
  shape${h.sep} ${c.shape},
${h.closeArgs()});
""");
    }

    h.write("""
${h.defineKeyword}inputs = [
  ${network.inputs.map((c) => c.name + h.outputSuffix).join(',')}
];
""");

// ================    INPUTS

// var sorted = topologicalSort(Input.all);
// TODO:
    final orderedNodes = orderedGraph(graph.nodes.values);

    for (final c in orderedNodes) {
// ================    LAYERS
      h.write(c.data.code(h));

//   LAYERS ================

// else if (c.isTypeOf(Merge)){%]
// [%=c.defineName()%] layers.[%=layerName(c.mergeType.literal.toLowerCase())%]([%=c.setName()%][%=closeArgs()%]);
// [%=c.applyMany()%]

// [%} else if (c.isTypeOf(Concat)){%]
// [%=c.defineName()%] layers.[%=layerName("concatenate")%]([%=c.setName()%] axis[%=sep()%] [%=c.axis%][%=closeArgs()%]);
// [%=c.applyMany()%]

// [%} else if (c.isTypeOf(BinaryOperation) or c.isTypeOf(BinaryLogicalOperation)){%]
// [%=c.defineOutput()%] tf.[%=c.operand%]([%=c.firstInput()%], [%=c.inputs.second().from.name%][%=output%]) [%=castTensor()%];

// [%}
// ================    UNARY

// else if (c.isKindOf(UnaryOperation)){

// if (c.isTypeOf(Activation)){%]
// [%=c.defineName()%] layers.[%=layerName("activation")%]([%=c.setName()%] activation[%=sep()%] "[%=c.type%]"[%=closeArgs()%]);
// [%=c.applyOne()%]
// [%} else if (c.isTypeOf(Normalization)){%]
// [%=c.defineName()%] layers.[%=layerName(c.type)%]Normalization([%=c.setName()%][%=closeArgs()%]);
// [%=c.applyOne()%]
// [%} else if (c.isTypeOf(Reduce)){%]
// [%if (isJS){%]
// [%=c.defineOutput()%] reduceSingle("[%=c.reducer%]", [%=c.axis%], [%=c.keepDims%], "[%=c.name%]").apply([%=c.firstInput()%]) [%=castTensor()%];
// [%}else{%]
// [%=c.defineOutput()%] tf.reduce_[%=c.reducer%]([%=c.firstInput()%], [%=c.axis%], [%=printBool(c.keepDims)%], "[%=c.name%]");
// [%}
// } else if (c.isTypeOf(Reshape)){%]
// [%=c.defineName()%] layers.[%=layerName("reshape")%]([%=c.setName()%] [%=argName("targetShape")%][%=sep()%] [%=c.shape %][%=closeArgs()%]);
// [%=c.applyOne()%]
// [%} else if (c.isTypeOf(Cast)){%]
// [%=c.defineOutput()%] tf.cast([%=c.firstInput()%], "[%=c.dtype%]") [%=castTensor()%];
// [%}%]

//  UNARY ================

    }

    final sep = h.sep;
    h.write("""
${h.defineKeyword}outputs = [
  ${network.outputs.map((e) => e.name).join(',')}
]${h.typeCastTensor};

${h.defineKeyword}model = tf${h.language.isJs ? '.keras' : ''}.${h.layerTypeName("model")}(${h.openArgs()}
  inputs$sep inputs,
  outputs$sep outputs,
  name$sep "${network.name}",
${h.closeArgs()});
""");

    h.write("""
model.compile(${h.openArgs()}
  optimizer$sep "${toEnumString(network.optimizer)}",
  loss$sep [
    ${network.outputs.map((c) => c.loss != null ? h.argName(toEnumString(c.loss)) : "(_yTrue, _yPred) => tf.tensor(0)").join(',')}
  ],
${h.closeArgs()});
 
return model;
""");
  });

  h.write("""
${h.language.isJs ? "};" : ""}
""");

  return h.buffer.toString();
}
