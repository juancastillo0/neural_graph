import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:formgen/formgen.dart';
import 'package:source_gen/source_gen.dart';

class ValidatorGenerator extends GeneratorForAnnotation<Validate> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    final annotationValue = annotation.objectValue.extractValue(
      Validate.fieldsSerde,
      (p0) => Validate.fromJson(p0),
    );
    final nullableErrorLists = annotationValue.nullableErrorLists;

    String _fieldIdent(String fieldName) {
      return '${visitor.className}Field.$fieldName';
    }

    final className = visitor.className;

    return '''

enum ${className}Field {
  ${visitor.fields.entries.map((e) {
      return '${e.key},';
    }).join()}
}

class ${className}ValidationFields {
  const ${className}ValidationFields(this.errorsMap);
  final Map<${className}Field, List<ValidationError>> errorsMap;

  ${visitor.fields.entries.map((e) {
      return 'List<ValidationError>${nullableErrorLists ? '?' : ''} get ${e.key} => errorsMap[${_fieldIdent(e.key)}]${nullableErrorLists ? '' : '!'};';
    }).join()}
}

class ${className}Validation {
  const ${className}Validation(this.errorsMap, this.value, this.fields);

  final Map<${className}Field, List<ValidationError>> errorsMap;

  final ${className} value;

  final ${className}ValidationFields fields;
  
}

${className}Validation validate${className}(${className} value) {
  final errors = <${className}Field, List<ValidationError>>{};
  ${visitor.fields.entries.map((e) {
      final isNullable =
          e.value.element.type.nullabilitySuffix == NullabilitySuffix.question;
      final getter = 'value.${e.key}${isNullable ? '!' : ''}';
      final validations = e.value.annotation.validations(getter: getter);
      if (validations.isEmpty) {
        return '';
      }
      final _nullable = isNullable
          ? nullableErrorLists
              ? 'if(value.${e.key} != null) '
              : 'if(value.${e.key} == null) errors[${_fieldIdent(e.key)}] = []; else'
          : '';

      return '${_nullable} errors[${_fieldIdent(e.key)}] = [${validations.map((valid) {
        return 'if (${valid.condition}) ${valid.errorTemplate(e.key, getter)}';
      }).join(",")}];';
    }).join()}
  ${nullableErrorLists ? 'errors.removeWhere((k, v) => v.isEmpty);' : ''}

  return ${className}Validation(errors, value, ${className}ValidationFields(errors),);
}
''';
  }
}

class ModelVisitor extends SimpleElementVisitor {
  DartType? className;
  final fields = <String, _Field>{};
  final validateFunctions = <FieldElement>{};

  static const _listAnnotation = TypeChecker.fromRuntime(ValidateList);
  static const _stringAnnotation = TypeChecker.fromRuntime(ValidateString);
  static const _numAnnotation = TypeChecker.fromRuntime(ValidateNum);
  static const _dateAnnotation = TypeChecker.fromRuntime(ValidateDate);
  static const _functionAnnotation =
      TypeChecker.fromRuntime(ValidationFunction);

  @override
  dynamic visitConstructorElement(ConstructorElement element) {
    className = element.returnType;
    return super.visitConstructorElement(element);
  }

  @override
  dynamic visitFieldElement(FieldElement element) {
    void _addFields({
      required TypeChecker annotation,
      required Map<String, SerdeType> fieldsSerde,
      required ValidateField Function(Map<String, dynamic> map) fromJson,
    }) {
      if (annotation.hasAnnotationOfExact(element)) {
        final annot = annotation.annotationsOfExact(element).first;
        final _annot = annot.extractValue(
          fieldsSerde,
          (map) => fromJson(map),
        );

        fields[element.name] = _Field(element, _annot);
      }
    }

    if (_functionAnnotation.hasAnnotationOfExact(element)) {
      validateFunctions.add(element);
    }

    // Primitives
    _addFields(
      annotation: _stringAnnotation,
      fieldsSerde: ValidateString.fieldsSerde,
      fromJson: (map) => ValidateString.fromJson(map),
    );
    _addFields(
      annotation: _numAnnotation,
      fieldsSerde: ValidateNum.fieldsSerde,
      fromJson: (map) => ValidateNum.fromJson(map),
    );
    // Date and Duration
    _addFields(
      annotation: _dateAnnotation,
      fieldsSerde: ValidateDate.fieldsSerde,
      fromJson: (map) => ValidateDate.fromJson(map),
    );
    _addFields(
      annotation: TypeChecker.fromRuntime(ValidateDuration),
      fieldsSerde: ValidateDuration.fieldsSerde,
      fromJson: (map) => ValidateDuration.fromJson(map),
    );
    // Collections
    _addFields(
      annotation: _listAnnotation,
      fieldsSerde: ValidateList.fieldsSerde,
      fromJson: (map) => ValidateList.fromJson(map),
    );
    _addFields(
      annotation: TypeChecker.fromRuntime(ValidateSet),
      fieldsSerde: ValidateSet.fieldsSerde,
      fromJson: (map) => ValidateSet.fromJson(map),
    );
    _addFields(
      annotation: TypeChecker.fromRuntime(ValidateMap),
      fieldsSerde: ValidateMap.fieldsSerde,
      fromJson: (map) => ValidateMap.fromJson(map),
    );

    return super.visitFieldElement(element);
  }
}

extension ConsumeSerdeType on DartObject {
  T extractValue<T>(
    Map<String, SerdeType> fields,
    T Function(Map<String, Object?>) fromJson,
  ) {
    final jsonMap = fields.map((key, value) {
      final field = this.getField(key);
      if (field == null) {
        return MapEntry(key, null);
      }
      final _value = field.serde(value);
      return MapEntry(key, _value);
    });
    return fromJson(jsonMap);
  }

  Object? serde(SerdeType serde) {
    final _value = serde.when(
        bool: () => this.toBoolValue(),
        str: () => this.toStringValue(),
        num: () => this.toDoubleValue() ?? this.toIntValue(),
        int: () => this.toIntValue(),
        function: () => this.toFunctionValue()?.name,
        duration: () => this.getField('_duration')?.toIntValue(),
        list: (list) =>
            this.toListValue()?.map((e) => e.serde(list.generic)).toList(),
        set: (set) =>
            this.toListValue()?.map((e) => e.serde(set.generic)).toSet(),
        map: (map) => this.toMapValue()?.map(
              (key, value) => MapEntry(
                key?.serde(map.genericKey),
                value?.serde(map.genericValue),
              ),
            ),
        enumV: (enumV) {
          final enumIndex = this.getField('index')?.toIntValue();
          return enumIndex == null ? null : enumV.values[enumIndex];
        },
        nested: (nested) {
          return nested.props.map(
            (key, value) => MapEntry(key, this.getField(key)?.serde(value)),
          );
        },
        union: (union) {
          final discriminator = this.getField(union.discriminator)?.toString();
          final variant = union.variants[discriminator];
          if (variant == null) {
            return null;
          }
          return this.serde(variant);
        },
        unionType: (union) {},
        dynamic: () {
          return this.toBoolValue() ??
              this.toIntValue() ??
              this.toDoubleValue() ??
              this.toStringValue() ??
              this.toListValue() ??
              this.toSetValue() ??
              this.toMapValue();
        });
    return _value;
  }
}

class _Field {
  const _Field(this.element, this.annotation);
  final FieldElement element;
  final ValidateField annotation;
}

extension TemplateValidateField on ValidateField {
  List<ValidationItem> validations({
    required String getter,
  }) {
    final v = this;
    final validations = <ValidationItem>[];

    if (v is ValidateString) {
      validations.addAll(stringValidations(v, getter));
    } else if (v is ValidateNum) {
      if (v.min != null) {
        validations.add(ValidationItem(
          condition: '$getter < ${v.min}',
          defaultMessage: 'Should be at a minimum ${v.min}',
          errorCode: 'ValidateNum.min',
          param: v.min,
        ));
      }
      if (v.max != null) {
        validations.add(ValidationItem(
          condition: '$getter > ${v.max}',
          defaultMessage: 'Should be at a maximum ${v.max}',
          errorCode: 'ValidateNum.max',
          param: v.max,
        ));
      }
      if (v.isInt != null && v.isInt == true) {
        validations.add(ValidationItem(
          condition: '$getter.round() != $getter',
          defaultMessage: 'Should be an integer',
          errorCode: 'ValidateNum.isInt',
          param: null,
        ));
      }
      if (v.comp != null) validations.addAll(compValidations(v.comp!));
    } else if (v is ValidateList) {
      if (v.minLength != null) {
        validations.add(ValidationItem(
          condition: '$getter.length < ${v.minLength}',
          defaultMessage: 'Should be at a minimum ${v.minLength} in length',
          errorCode: 'ValidateList.minLength',
          param: v.minLength,
        ));
      }
      if (v.maxLength != null) {
        validations.add(ValidationItem(
          condition: '$getter.length > ${v.maxLength}',
          defaultMessage: 'Should be at a maximum ${v.maxLength} in length',
          errorCode: 'ValidateList.maxLength',
          param: v.maxLength,
        ));
      }
    } else if (v is ValidateDate) {
      String dateFromStr(String repr) {
        final lowerRepr = repr.toLowerCase();
        if (lowerRepr == 'now') {
          return 'DateTime.now()';
        } else {
          final _p = DateTime.parse(repr);
          return 'DateTime.fromMillisecondsSinceEpoch(${_p.millisecondsSinceEpoch})';
        }
      }

      if (v.min != null) {
        final minDate = dateFromStr(v.min!);
        validations.add(ValidationItem(
          condition: '$minDate.isAfter($getter)',
          defaultMessage: 'Should be at a minimum ${v.min}',
          errorCode: 'ValidateDate.min',
          param: v.min!,
        ));
      }
      if (v.max != null) {
        final maxDate = dateFromStr(v.max!);
        validations.add(ValidationItem(
          condition: '$maxDate.isAfter($getter)',
          defaultMessage: 'Should be at a maximum ${v.max}',
          errorCode: 'ValidateDate.max',
          param: v.max!,
        ));
      }
      if (v.comp != null)
        validations.addAll(compValidations(
          v.comp!,
          dateFromStr,
        ));
    }

    return validations;
  }
}

String _defaultMakeString(Object? obj) => obj.toString();

List<ValidationItem> compValidations<T extends Comparable<T>>(
  ValidateComparison<T> comp, [
  String Function(T) makeString = _defaultMakeString,
]) {
  String comparison(CompVal<T> c) {
    return c.when(ref: (ref) {
      return '$ref';
    }, single: (single) {
      return '';
    }, list: (list) {
      return '';
    });
  }

  return [
    // if (comp.less != null)
    //   ValidationItem(
    //     condition: '$minDate.isAfter($getter)',
    //     defaultMessage: 'Should be at a minimum ${comp.less}',
    //     errorCode: 'ValidateComparable.less',
    //     param: comp.less,
    //   ),
    // if (v.max != null)
    //   ValidationItem(
    //     condition: '$maxDate.isAfter($getter)',
    //     defaultMessage: 'Should be at a maximum ${v.max}',
    //     errorCode: 'ValidateDate.max',
    //     param: v.max!,
    //   ),
  ];
}

List<ValidationItem> stringValidations(ValidateString v, String getter) {
  final validations = <ValidationItem>[];
  if (v.minLength != null) {
    validations.add(ValidationItem(
      condition: '$getter.length < ${v.minLength}',
      defaultMessage: 'Should be at a minimum ${v.minLength} in length',
      errorCode: 'ValidateString.minLength',
      param: v.minLength,
    ));
  }
  if (v.maxLength != null) {
    validations.add(ValidationItem(
      condition: '$getter.length > ${v.maxLength}',
      defaultMessage: 'Should be at a maximum ${v.maxLength} in length',
      errorCode: 'ValidateString.maxLength',
      param: v.maxLength,
    ));
  }
  if (v.isUppercase != null && v.isUppercase == true) {
    validations.add(ValidationItem(
      condition: '$getter.toUpperCase() != $getter',
      defaultMessage: 'Should be uppercase',
      errorCode: 'ValidateString.isUppercase',
      param: null,
    ));
  }
  if (v.isLowercase != null && v.isLowercase == true) {
    validations.add(ValidationItem(
      condition: '$getter.toLowerCase() != $getter',
      defaultMessage: 'Should be lowercase',
      errorCode: 'ValidateString.isLowercase',
      param: null,
    ));
  }
  if (v.isNum != null && v.isNum == true) {
    validations.add(ValidationItem(
      condition: 'double.tryParse($getter) == null',
      defaultMessage: 'Should be a number',
      errorCode: 'ValidateString.isNum',
      param: null,
    ));
  }
  if (v.isBool != null && v.isBool == true) {
    validations.add(ValidationItem(
      condition: '$getter != "true" && $getter != "false"',
      defaultMessage: 'Should be a "true" or "false"',
      errorCode: 'ValidateString.isBool',
      param: null,
    ));
  }
  if (v.contains != null) {
    validations.add(ValidationItem(
      condition: '!$getter.contains(r"${v.contains}")',
      defaultMessage: 'Should contain ${v.contains}',
      errorCode: 'ValidateString.contains',
      param: "r'${v.contains}'",
    ));
  }
  if (v.matches != null) {
    validations.add(ValidationItem(
      condition: '!RegExp(r"${v.matches}").hasMatch($getter)',
      defaultMessage: 'Should match ${v.matches}',
      errorCode: 'ValidateString.matches',
      param: 'RegExp(r"${v.matches}")',
    ));
  }
  return validations;
}

class ValidationItem {
  final String defaultMessage;
  final String condition;
  final String errorCode;
  final Object? param;

  const ValidationItem({
    required this.defaultMessage,
    required this.condition,
    required this.errorCode,
    required this.param,
  });

  String errorTemplate(String fieldName, String getter) {
    return """ValidationError(
        message: r'$defaultMessage',
        errorCode: '$errorCode',
        property: '$fieldName',
        param: $param,
        value: $getter,
      )""";
  }
}
