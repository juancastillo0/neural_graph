import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:formgen/formgen.dart';
import 'package:source_gen/source_gen.dart';

class ValidatorGenerator extends GeneratorForAnnotation<Validate> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    try {
      final visitor = ModelVisitor();
      element.visitChildren(visitor);
      final _visited = <Element>{element};
      ClassElement? elem = element is ClassElement ? element : null;
      while (elem?.supertype != null) {
        final currelem = elem!.supertype!.element;
        if (_visited.contains(currelem)) {
          elem = null;
          continue;
        }
        _visited.add(currelem);
        currelem.visitChildren(visitor);
        elem = currelem;
      }

      final annotationValue = annotation.objectValue.extractValue(
        Validate.fieldsSerde,
        (p0) => Validate.fromJson(p0),
      );
      final nullableErrorLists = annotationValue.nullableErrorLists;
      final className = visitor.className;

      String _fieldIdent(String fieldName) {
        return '${visitor.className}Field.$fieldName';
      }

      return '''

enum ${className}Field {
  ${visitor.fields.entries.map((e) {
        return '${e.key},';
      }).join()}
  ${visitor.fieldsWithValidate.map((e) => '${e.name},').join()}
  ${visitor.validateFunctions.isNotEmpty ? 'global,' : ''}
}

class ${className}ValidationFields {
  const ${className}ValidationFields(this.errorsMap);
  final Map<${className}Field, List<ValidationError>> errorsMap;

  ${visitor.fieldsWithValidate.map((e) {
        final retType =
            '${e.type.getDisplayString(withNullability: false)}Validation?';
        return '$retType get ${e.name} {'
            'final l = errorsMap[${_fieldIdent(e.name)}];'
            'return (l != null && l.isNotEmpty) ? l.first.nestedValidation as $retType : null;}';
      }).join()}
  ${visitor.fields.entries.map((e) {
        return 'List<ValidationError>${nullableErrorLists ? '?' : ''} get ${e.key} '
            '=> errorsMap[${_fieldIdent(e.key)}]${nullableErrorLists ? '' : '!'};';
      }).join()}
}

class ${className}Validation extends Validation<${className}, ${className}Field> {
  ${className}Validation(this.errorsMap, this.value, this.fields) : super(errorsMap);

  final Map<${className}Field, List<ValidationError>> errorsMap;

  final ${className} value;

  final ${className}ValidationFields fields;
  
}

${className}Validation validate${className}(${className} value) {
  final errors = <${className}Field, List<ValidationError>>{};

  ${visitor.fieldsWithValidate.map((e) {
        final isNullable =
            e.type.nullabilitySuffix == NullabilitySuffix.question;
        return '''
        final _${e.name}Validation = ${isNullable ? 'value.${e.name} == null ? null : ' : ''}
          validate${e.type.getDisplayString(withNullability: false)}(value.${e.name}!).toError(property: '${e.name}');
        errors[${className}Field.${e.name}] = [if (_${e.name}Validation != null) _${e.name}Validation];
        ''';
      }).join()}
  ${visitor.validateFunctions.isEmpty ? '' : 'errors[${className}Field.global] = [${visitor.validateFunctions.map((e) {
              return e.isStatic
                  ? '...${e.enclosingElement.name}.${e.name}(value)'
                  : '...value.${e.name}()';
            }).join(',')}];'}
  ${visitor.fields.entries.map((e) {
        final isNullable = e.value.element.type.nullabilitySuffix ==
            NullabilitySuffix.question;
        final fieldName = '${e.key}${isNullable ? '!' : ''}';
        final getter = 'value.$fieldName';
        final validations = e.value.annotation.validations(
          fieldName: fieldName,
          prefix: 'value.',
        );
        if (validations.isEmpty) {
          return '';
        }
        final _nullable = isNullable
            ? nullableErrorLists
                ? 'if(value.${e.key} != null) '
                : 'if(value.${e.key} == null) errors[${_fieldIdent(e.key)}] = []; else'
            : '';

        String _mapValidationItem(ValidationItem valid) {
          if (valid.iterable != null) {
            return '${valid.iterable} ...[${valid.nested!.map(_mapValidationItem).join(",")}]';
          }
          return 'if (${valid.condition}) ${valid.errorTemplate(e.key, getter)}';
        }

        final _custom = e.value.annotation.customValidateName == null
            ? ''
            : '...${e.value.annotation.customValidateName}($getter),';

        return '${_nullable} errors[${_fieldIdent(e.key)}] = [$_custom${validations.map(_mapValidationItem).join(",")}];';
      }).join()}
  ${nullableErrorLists ? 'errors.removeWhere((k, v) => v.isEmpty);' : ''}

  return ${className}Validation(errors, value, ${className}ValidationFields(errors),);
}
''';
    } catch (e, s) {
      return 'const error = """$e\n$s""";';
    }
  }
}

class ValidationItem {
  final String defaultMessage;
  final String condition;
  final String errorCode;
  final Object? param;
  final String? iterable;
  final List<ValidationItem>? nested;

  const ValidationItem({
    required this.defaultMessage,
    required this.condition,
    required this.errorCode,
    required this.param,
    this.iterable,
    this.nested,
  });

  String errorTemplate(String fieldName, String getter) {
    // ignore: leading_newlines_in_multiline_strings
    return '''ValidationError(
        message: r'$defaultMessage',
        errorCode: '$errorCode',
        property: '$fieldName',
        validationParam: $param,
        value: $getter,
      )''';
  }
}

class ModelVisitor extends SimpleElementVisitor<void> {
  DartType? className;
  final fields = <String, _Field>{};
  final validateFunctions = <MethodElement>{};
  final fieldsWithValidate = <FieldElement>{};

  static const _listAnnotation = TypeChecker.fromRuntime(ValidateList);
  static const _stringAnnotation = TypeChecker.fromRuntime(ValidateString);
  static const _numAnnotation = TypeChecker.fromRuntime(ValidateNum);
  static const _dateAnnotation = TypeChecker.fromRuntime(ValidateDate);
  static const _functionAnnotation =
      TypeChecker.fromRuntime(ValidationFunction);

  @override
  void visitMethodElement(MethodElement element) {
    if (_functionAnnotation.hasAnnotationOfExact(element)) {
      validateFunctions.add(element);
    }
    super.visitMethodElement(element);
  }

  @override
  dynamic visitConstructorElement(ConstructorElement element) {
    className ??= element.returnType;
    return super.visitConstructorElement(element);
  }

  @override
  dynamic visitFieldElement(FieldElement element) {
    void _addFields({
      required TypeChecker annotation,
      required Map<String, SerdeType> fieldsSerde,
      required ValidateField Function(Map<String, Object?> map) fromJson,
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

    final elementType = element.type.element;
    if (elementType != null) {
      final fieldType = const TypeChecker.fromRuntime(Validate)
          .annotationsOfExact(elementType, throwOnUnresolved: false)
          .toList();
      if (fieldType.isNotEmpty) {
        fieldsWithValidate.add(element);
      }
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
      annotation: const TypeChecker.fromRuntime(ValidateDuration),
      fieldsSerde: ValidateDuration.fieldsSerde,
      fromJson: (map) => ValidateDuration.fromJson(map),
    );
    // Collections
    _addFields(
      annotation: _listAnnotation,
      fieldsSerde: ValidateList.fieldsSerde,
      fromJson: (map) => ValidateList<Object?>.fromJson(map),
    );
    _addFields(
      annotation: const TypeChecker.fromRuntime(ValidateSet),
      fieldsSerde: ValidateSet.fieldsSerde,
      fromJson: (map) => ValidateSet<Object?>.fromJson(map),
    );
    _addFields(
      annotation: const TypeChecker.fromRuntime(ValidateMap),
      fieldsSerde: ValidateMap.fieldsSerde,
      fromJson: (map) => ValidateMap<Object?, Object?>.fromJson(map),
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
    final _value = serde.when<Object?>(
      bool: () => this.toBoolValue(),
      str: () => this.toStringValue(),
      num: () => this.toDoubleValue() ?? this.toIntValue(),
      int: () => this.toIntValue(),
      function: () {
        final f = this.toFunctionValue();
        if (f == null) {
          return null;
        }
        final enclosing = f.declaration.enclosingElement.name;
        return '${enclosing == null ? '' : '$enclosing.'}${f.name}';
      },
      duration: () => this.getField('_duration')?.toIntValue(),
      option: (inner) => this.serde(inner),
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
        final eValue = this.getField(union.discriminator);
        final t = eValue?.type;

        final String? discriminator;
        if (t?.element.runtimeType == EnumElementImpl) {
          final index = eValue?.getField('index')?.toIntValue();
          final v = (t?.element as EnumElementImpl).fields[index! + 2];
          discriminator = v.name;
        } else {
          discriminator = eValue?.toStringValue() ??
              eValue?.getField('_inner')?.toStringValue();
        }

        final variant = union.variants[discriminator];
        if (variant == null) {
          return null;
        }
        final result = this.serde(variant);
        if (result is Map && !result.containsKey(union.discriminator)) {
          result[union.discriminator] = discriminator;
        }
        return result;
      },
      unionType: (union) {},
      late: (l) {
        return this.serde(l.func());
      },
      dynamic: () {
        final v = this.toBoolValue() ??
            this.toIntValue() ??
            this.toDoubleValue() ??
            this.toStringValue() ??
            this.toListValue() ??
            this.toSetValue() ??
            this.toMapValue();
        if (v == null) {
          final durMicro = this.getField('_duration')?.toIntValue();
          return durMicro == null ? null : Duration(microseconds: durMicro);
        }
        return v;
      },
    );
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
    required String fieldName,
    required String prefix,
  }) {
    final getter = '$prefix$fieldName';
    final validations = <ValidationItem>[];

    this.when(
      string: (v) {
        validations.addAll(stringValidations(v, getter));
      },
      num: (v) {
        if (v.isInt != null && v.isInt == true) {
          validations.add(ValidationItem(
            condition: '$getter.round() != $getter',
            defaultMessage: 'Should be an integer',
            errorCode: 'ValidateNum.isInt',
            param: null,
          ));
        }
        if (v.comp != null) {
          validations.addAll(compValidations(
            v.comp!,
            prefix: prefix,
            fieldName: fieldName,
          ));
        }
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
      },
      date: (v) {
        String dateFromStr(String repr) {
          final lowerRepr = repr.toLowerCase();
          if (lowerRepr == 'now') {
            return 'DateTime.now()';
          } else {
            final _p = DateTime.parse(repr);
            return 'DateTime.fromMillisecondsSinceEpoch(${_p.millisecondsSinceEpoch})';
          }
        }

        if (v.comp != null) {
          validations.addAll(compValidations(
            v.comp!,
            makeString: dateFromStr,
            prefix: prefix,
            fieldName: fieldName,
          ));
        }

        if (v.min != null) {
          final minDate = dateFromStr(v.min!);
          validations.add(ValidationItem(
            condition: '$minDate.isAfter($getter)',
            defaultMessage: 'Should be at a minimum ${v.min}',
            errorCode: 'ValidateDate.min',
            param: '"${v.min}"',
          ));
        }
        if (v.max != null) {
          final maxDate = dateFromStr(v.max!);
          validations.add(ValidationItem(
            condition: '$maxDate.isAfter($getter)',
            defaultMessage: 'Should be at a maximum ${v.max}',
            errorCode: 'ValidateDate.max',
            param: '"${v.max}"',
          ));
        }
      },
      duration: (v) {
        if (v.comp != null) {
          validations.addAll(compValidations<Duration>(
            v.comp!,
            prefix: prefix,
            makeString: (dur) =>
                'Duration(microseconds: ${dur.inMicroseconds})',
            fieldName: fieldName,
          ));
        }
      },
      list: (v) {
        if (v.each != null) {
          validations.add(ValidationItem(
            defaultMessage: '',
            errorCode: '',
            iterable: 'for (final i in Iterable<int>.generate($getter.length))',
            condition: '',
            param: null,
            nested: v.each!.validations(
              fieldName: '$fieldName[i]',
              prefix: prefix,
            ),
          ));
        }
        validations.addAll(lengthValidations(v, getter));
      },
      set: (v) {
        if (v.each != null) {
          validations.add(ValidationItem(
            defaultMessage: '',
            errorCode: '',
            iterable: 'for (final ${fieldName}Item in $getter)',
            condition: '',
            param: null,
            nested: v.each!.validations(
              fieldName: '${fieldName}Item',
              prefix: '',
            ),
          ));
        }
        validations.addAll(lengthValidations(v, getter));
      },
      map: (v) {
        if (v.eachKey != null) {
          validations.add(ValidationItem(
            defaultMessage: '',
            errorCode: '',
            iterable: 'for (final ${fieldName}Key in $getter.keys)',
            condition: '',
            param: null,
            nested: v.eachKey!.validations(
              fieldName: '${fieldName}Key',
              prefix: '',
            ),
          ));
        }
        if (v.eachValue != null) {
          validations.add(ValidationItem(
            defaultMessage: '',
            errorCode: '',
            iterable: 'for (final ${fieldName}Value in $getter.Values)',
            condition: '',
            param: null,
            nested: v.eachValue!.validations(
              fieldName: '${fieldName}Value',
              prefix: '',
            ),
          ));
        }
        validations.addAll(lengthValidations(v, getter));
      },
    );

    return validations;
  }
}

String _defaultMakeString(Object? obj) => obj.toString();

List<ValidationItem> compValidations<T extends Comparable<T>>(
  ValidateComparison<T> comp, {
  required String fieldName,
  required String prefix,
  String Function(T) makeString = _defaultMakeString,
}) {
  String comparison(CompVal<T> c, String operator) {
    return c.when(ref: (ref) {
      return '$prefix$fieldName.compareTo($prefix$ref) $operator';
    }, single: (single) {
      return '$prefix$fieldName.compareTo(${makeString(single)}) $operator';
    }, list: (list) {
      return list.map((v) => comparison(v, operator)).join(' || ');
    });
  }

  return [
    if (comp.less != null)
      ValidationItem(
        condition: comparison(comp.less!, '>= 0'),
        defaultMessage: 'Should be at a minimum ${comp.less}',
        errorCode: 'ValidateComparable.less',
        param: '"${comp.less}"',
      ),
    if (comp.lessEq != null)
      ValidationItem(
        condition: comparison(comp.lessEq!, '> 0'),
        defaultMessage: 'Should be at a less than or equal to ${comp.lessEq}',
        errorCode: 'ValidateComparable.lessEq',
        param: '"${comp.lessEq}"',
      ),
    if (comp.more != null)
      ValidationItem(
        condition: comparison(comp.more!, '<= 0'),
        defaultMessage: 'Should be at a minimum ${comp.more}',
        errorCode: 'ValidateComparable.more',
        param: '"${comp.more}"',
      ),
    if (comp.moreEq != null)
      ValidationItem(
        condition: comparison(comp.moreEq!, '< 0'),
        defaultMessage: 'Should be at a more than or equal to ${comp.moreEq}',
        errorCode: 'ValidateComparable.moreEq',
        param: '"${comp.moreEq}"',
      ),
  ];
}

List<ValidationItem> lengthValidations(ValidateLength v, String getter) {
  return [
    if (v.minLength != null)
      ValidationItem(
        condition: '$getter.length < ${v.minLength}',
        defaultMessage: 'Should be at a minimum ${v.minLength} in length',
        errorCode: 'ValidateList.minLength',
        param: v.minLength,
      ),
    if (v.maxLength != null)
      ValidationItem(
        condition: '$getter.length > ${v.maxLength}',
        defaultMessage: 'Should be at a maximum ${v.maxLength} in length',
        errorCode: 'ValidateList.maxLength',
        param: v.maxLength,
      ),
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
