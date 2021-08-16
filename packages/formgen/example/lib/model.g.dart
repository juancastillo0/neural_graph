// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// ValidatorGenerator
// **************************************************************************

enum FormTestField {
  longStr,
  shortStr,
  positiveInt,
  optionalDecimal,
  nonEmptyList,
  identifier,
  nested,
  global,
}

class FormTestValidationFields {
  const FormTestValidationFields(this.errorsMap);
  final Map<FormTestField, List<ValidationError>> errorsMap;

  NestedFieldValidation? get nested {
    final l = errorsMap[FormTestField.nested];
    return (l != null && l.isNotEmpty)
        ? l.first.nestedValidation as NestedFieldValidation?
        : null;
  }

  List<ValidationError>? get longStr => errorsMap[FormTestField.longStr];
  List<ValidationError>? get shortStr => errorsMap[FormTestField.shortStr];
  List<ValidationError>? get positiveInt =>
      errorsMap[FormTestField.positiveInt];
  List<ValidationError>? get optionalDecimal =>
      errorsMap[FormTestField.optionalDecimal];
  List<ValidationError>? get nonEmptyList =>
      errorsMap[FormTestField.nonEmptyList];
  List<ValidationError>? get identifier => errorsMap[FormTestField.identifier];
}

class FormTestValidation extends Validation<FormTest, FormTestField> {
  FormTestValidation(this.errorsMap, this.value, this.fields)
      : super(errorsMap);

  final Map<FormTestField, List<ValidationError>> errorsMap;

  final FormTest value;

  final FormTestValidationFields fields;
}

FormTestValidation validateFormTest(FormTest value) {
  final errors = <FormTestField, List<ValidationError>>{};

  final _nestedValidation = value.nested == null
      ? null
      : validateNestedField(value.nested!).toError(property: 'nested');
  errors[FormTestField.nested] = [
    if (_nestedValidation != null) _nestedValidation
  ];

  errors[FormTestField.global] = [
    ...FormTest._customValidate2(value),
    ...value._customValidate3()
  ];
  errors[FormTestField.longStr] = [
    ..._customValidateStr(value.longStr),
    if (value.longStr.length < 15)
      ValidationError(
        message: r'Should be at a minimum 15 in length',
        errorCode: 'ValidateString.minLength',
        property: 'longStr',
        validationParam: 15,
        value: value.longStr,
      ),
    if (value.longStr.length > 50)
      ValidationError(
        message: r'Should be at a maximum 50 in length',
        errorCode: 'ValidateString.maxLength',
        property: 'longStr',
        validationParam: 50,
        value: value.longStr,
      ),
    if (!RegExp(r"^[a-zA-Z]+$").hasMatch(value.longStr))
      ValidationError(
        message: r'Should match ^[a-zA-Z]+$',
        errorCode: 'ValidateString.matches',
        property: 'longStr',
        validationParam: RegExp(r"^[a-zA-Z]+$"),
        value: value.longStr,
      )
  ];
  errors[FormTestField.shortStr] = [
    if (value.shortStr.length > 20)
      ValidationError(
        message: r'Should be at a maximum 20 in length',
        errorCode: 'ValidateString.maxLength',
        property: 'shortStr',
        validationParam: 20,
        value: value.shortStr,
      ),
    if (!value.shortStr.contains(r"@"))
      ValidationError(
        message: r'Should contain @',
        errorCode: 'ValidateString.contains',
        property: 'shortStr',
        validationParam: r'@',
        value: value.shortStr,
      )
  ];
  errors[FormTestField.positiveInt] = [
    ...FormTest._customValidateNum(value.positiveInt),
    if (value.positiveInt.round() != value.positiveInt)
      ValidationError(
        message: r'Should be an integer',
        errorCode: 'ValidateNum.isInt',
        property: 'positiveInt',
        validationParam: null,
        value: value.positiveInt,
      ),
    if (value.positiveInt < 0)
      ValidationError(
        message: r'Should be at a minimum 0',
        errorCode: 'ValidateNum.min',
        property: 'positiveInt',
        validationParam: 0,
        value: value.positiveInt,
      )
  ];
  if (value.optionalDecimal != null)
    errors[FormTestField.optionalDecimal] = [
      if (value.optionalDecimal!.compareTo(0) >= 0)
        ValidationError(
          message: r'Should be at a minimum 0',
          errorCode: 'ValidateComparable.less',
          property: 'optionalDecimal',
          validationParam: "0",
          value: value.optionalDecimal!,
        ),
      if (value.optionalDecimal!.compareTo(value.positiveInt) < 0)
        ValidationError(
          message: r'Should be at a more than or equal to [positiveInt]',
          errorCode: 'ValidateComparable.moreEq',
          property: 'optionalDecimal',
          validationParam: "[positiveInt]",
          value: value.optionalDecimal!,
        ),
      if (value.optionalDecimal! < 0)
        ValidationError(
          message: r'Should be at a minimum 0',
          errorCode: 'ValidateNum.min',
          property: 'optionalDecimal',
          validationParam: 0,
          value: value.optionalDecimal!,
        ),
      if (value.optionalDecimal! > 1)
        ValidationError(
          message: r'Should be at a maximum 1',
          errorCode: 'ValidateNum.max',
          property: 'optionalDecimal',
          validationParam: 1,
          value: value.optionalDecimal!,
        )
    ];
  errors[FormTestField.nonEmptyList] = [
    if (value.nonEmptyList.length < 1)
      ValidationError(
        message: r'Should be at a minimum 1 in length',
        errorCode: 'ValidateList.minLength',
        property: 'nonEmptyList',
        validationParam: 1,
        value: value.nonEmptyList,
      )
  ];
  errors.removeWhere((k, v) => v.isEmpty);

  return FormTestValidation(
    errors,
    value,
    FormTestValidationFields(errors),
  );
}

enum NestedFieldField {
  timeStr,
  dateWith2021Min,
  optionalDateWithNowMax,
}

class NestedFieldValidationFields {
  const NestedFieldValidationFields(this.errorsMap);
  final Map<NestedFieldField, List<ValidationError>> errorsMap;

  List<ValidationError> get timeStr => errorsMap[NestedFieldField.timeStr]!;
  List<ValidationError> get dateWith2021Min =>
      errorsMap[NestedFieldField.dateWith2021Min]!;
  List<ValidationError> get optionalDateWithNowMax =>
      errorsMap[NestedFieldField.optionalDateWithNowMax]!;
}

class NestedFieldValidation extends Validation<NestedField, NestedFieldField> {
  NestedFieldValidation(this.errorsMap, this.value, this.fields)
      : super(errorsMap);

  final Map<NestedFieldField, List<ValidationError>> errorsMap;

  final NestedField value;

  final NestedFieldValidationFields fields;
}

NestedFieldValidation validateNestedField(NestedField value) {
  final errors = <NestedFieldField, List<ValidationError>>{};

  errors[NestedFieldField.dateWith2021Min] = [
    if (DateTime.fromMillisecondsSinceEpoch(1609459200000)
        .isAfter(value.dateWith2021Min))
      ValidationError(
        message: r'Should be at a minimum 2021-01-01',
        errorCode: 'ValidateDate.min',
        property: 'dateWith2021Min',
        validationParam: "2021-01-01",
        value: value.dateWith2021Min,
      )
  ];
  if (value.optionalDateWithNowMax == null)
    errors[NestedFieldField.optionalDateWithNowMax] = [];
  else
    errors[NestedFieldField.optionalDateWithNowMax] = [
      if (DateTime.now().isAfter(value.optionalDateWithNowMax!))
        ValidationError(
          message: r'Should be at a maximum now',
          errorCode: 'ValidateDate.max',
          property: 'optionalDateWithNowMax',
          validationParam: "now",
          value: value.optionalDateWithNowMax!,
        )
    ];

  return NestedFieldValidation(
    errors,
    value,
    NestedFieldValidationFields(errors),
  );
}
