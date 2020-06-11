//ignore_for_file: implementation_imports
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
    // final visitor = ModelVisitor();
    // final enumVisitor = EnumVisitor();

    // element.visitChildren(visitor);
    // // final source = StringBuffer();

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

    return "// Hey! Annotation found!";
  }
}

class ModelVisitor extends SimpleElementVisitor {
  DartType className;
  Map<String, FieldElement> fields = Map();

  @override
  dynamic visitConstructorElement(ConstructorElement element) {
    className = element.returnType;
    return super.visitConstructorElement(element);
  }

  @override
  dynamic visitFieldElement(FieldElement element) {
    fields[element.name] = element;
    return super.visitFieldElement(element);
  }
}

class EnumVisitor extends SimpleElementVisitor {
  DartType className;
  Map<String, DartType> fields = Map();

  @override
  dynamic visitFieldElement(FieldElement element) {
    fields[element.name] = element.type;
    return super.visitFieldElement(element);
  }
}
