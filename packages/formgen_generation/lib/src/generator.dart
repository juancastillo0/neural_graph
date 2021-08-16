import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:formgen/formgen.dart';
import 'package:source_gen/source_gen.dart';

// import 'package:analyzer/src/dart/element/element.dart';

class FormGenGenerator extends GeneratorForAnnotation<FormGen> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    return '';
    final visitor = ModelVisitor();
    // final enumVisitor = EnumVisitor();

    element.visitChildren(visitor);
    // final source = StringBuffer();

    // final paddingElem = visitor.fields["padding"];
    // print(visitor.fields);
    // print(paddingElem.type.element.toString()); // enum ConvPadding

    // print(paddingElem.metadata); // [@EnumField EnumField()]

    // if (paddingElem.type.element.runtimeType == EnumElementImpl) {
    //   final enumType = paddingElem.type.element as EnumElementImpl;
    //   // [int index, List<ConvPadding> values, ConvPadding same, ConvPadding valid, ConvPadding causal]
    //   print(enumType.fields);
    // }
    // print(
    //     "isEnumElementImpl: ${paddingElem.type.element.runtimeType == EnumElementImpl}");

    // paddingElem.type.element.visitChildren(enumVisitor);
    // // {index: int, values: List<ConvPadding>, same: ConvPadding, valid: ConvPadding, causal: ConvPadding}
    // print(enumVisitor.fields);

    final children = visitor.fields.entries.map((entry) {
      final elem = entry.value.element;
      final annotation = entry.value.annotation;

      return '''\
tableRow(
  name: "${annotation.label ?? entry.key}",
  description: "${annotation.description}",
  field: ShapeField(
    field: fields.kernelSize,
    dimensions: state.dimensions.index,
  ),
)
''';
    }).join(',');
    final name = visitor.className!.getDisplayString(withNullability: false);

    return """

class ${name}FormState {
  ${name}FormState(${name} state) {
    ${visitor.fields.values.map((e) => """
    ${e.element.name} = FormFieldValue(
      get: () => state.${e.element.name},
      set: (v) => state.${e.element.name} = v,
    );""").join("\n")}
  }
  ${visitor.fields.values.map((e) => 'FormFieldValue<${e.element.type.getDisplayString(withNullability: true)}> ${e.element.name};').join("\n")}

  void dispose() {
    ${visitor.fields.values.map((e) => '${e.element.name}.dispose();').join("\n")}
  }
}

class ConvolutionalForm2 extends HookWidget {
  const ConvolutionalForm2({
    Key key,
    @required this.state,
  }) : super(key: key);

  final Convolutional state;

  @override
  Widget build(BuildContext context) {
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
              return ButtonSelect<ConvDimensions>(
                options: ConvDimensions.values,
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
            description: "List of number of omited rows/cols in each dimension",
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
          $children,
        ],
      ),
    );
  }
}
""";
  }
}

class ModelVisitor extends SimpleElementVisitor {
  DartType? className;
  Map<String, _Field> fields = {};

  final _fieldAnnotation = const TypeChecker.fromRuntime(FormInput);

  @override
  dynamic visitConstructorElement(ConstructorElement element) {
    className = element.returnType;
    return super.visitConstructorElement(element);
  }

  @override
  dynamic visitFieldElement(FieldElement element) {
    if (_fieldAnnotation.hasAnnotationOfExact(element)) {
      final annotation = _fieldAnnotation.annotationsOfExact(element).first;
      final _annot = FormInput(
        description: annotation.getField('description')?.toStringValue(),
        label: annotation.getField('label')?.toStringValue(),
        validate: (_) =>
            '', //annotation.getField("validate").toFunctionValue().name,
        width: annotation.getField('width')?.toDoubleValue(),
      );
      fields[element.name] = _Field(element, _annot);
    }
    return super.visitFieldElement(element);
  }
}

class _Field {
  const _Field(this.element, this.annotation);
  final FieldElement element;
  final FormInput annotation;
}

class EnumVisitor extends SimpleElementVisitor {
  DartType? className;
  Map<String, DartType> fields = {};

  @override
  dynamic visitFieldElement(FieldElement element) {
    fields[element.name] = element.type;
    return super.visitFieldElement(element);
  }
}
